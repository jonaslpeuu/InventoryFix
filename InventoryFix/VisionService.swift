//
//  VisionService.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import CoreML
import UIKit
import Vision

/// A structured result containing the name and relevant tags.
struct VisionAnalysisResult {
  let name: String
  let tags: [String]
}

class VisionService {
  static let shared = VisionService()

  // Persistent, thread-safe model instances
  private let yoloModel: VNCoreMLModel?
  private let mobileNetModel: VNCoreMLModel?

  private init() {
     // Use .cpuAndGPU to prevent ANE (Neural Engine) crashes on some devices.
     let config = MLModelConfiguration()
     config.computeUnits = .cpuAndGPU
     
     do {
       if let url = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") {
         let model = try MLModel(contentsOf: url, configuration: config)
         self.yoloModel = try VNCoreMLModel(for: model)
       } else {
         print("VisionService: YOLOv3 model not found in bundle.")
         self.yoloModel = nil
       }
     } catch {
       print("VisionService: Failed to load YOLOv3: \(error.localizedDescription)")
       self.yoloModel = nil
     }
     
     do {
       if let url = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc") {
         let model = try MLModel(contentsOf: url, configuration: config)
         self.mobileNetModel = try VNCoreMLModel(for: model)
       } else {
         print("VisionService: MobileNetV2 model not found in bundle.")
         self.mobileNetModel = nil
       }
     } catch {
       print("VisionService: Failed to load MobileNetV2: \(error.localizedDescription)")
       self.mobileNetModel = nil
     }
  }

  /// Analyzes the image using YOLOv3, MobileNetV2 and OCR.
  /// Executes entirely on a background thread.
  func classify(image: UIImage) async throws -> VisionAnalysisResult {
    guard let cgImage = image.cgImage else {
      throw NSError(
        domain: "VisionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"]
      )
    }

    // Handle Orientation upfront
    let orientation = self.cgImageOrientation(from: image.imageOrientation)
    
    // Capture strong references to models for the task
    let yolo = self.yoloModel
    let mob = self.mobileNetModel
    
    // Perform all heavy lifting in a detached task (background thread)
    return try await Task.detached(priority: .userInitiated) {

      // Data structures to collect results
      struct ScoredTag: Hashable {
        let identifier: String
        let confidence: Float
      }
      
      var allTags: [ScoredTag] = []
      
      // Define a partial result type for aggregator
      enum VisionTaskResult {
        case tags([ScoredTag])
        case ocr([String]) // Kept for completeness/debugging, though requirements prioritize ML
      }

      // Execute Requests in Parallel
      try await withThrowingTaskGroup(of: VisionTaskResult.self) { group in
        
        // YOLOv3 (Object Detection)
        if let yolo = yolo {
          group.addTask {
            var resultsVec: [ScoredTag] = []
            let request = VNCoreMLRequest(model: yolo) { request, _ in
              if let results = request.results as? [VNRecognizedObjectObservation] {
                 let tags = results
                    .flatMap { $0.labels }
                    .map { ScoredTag(identifier: $0.identifier, confidence: $0.confidence) }
                 resultsVec.append(contentsOf: tags)
              }
            }
            request.imageCropAndScaleOption = .scaleFill
            
            do {
              let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
              try handler.perform([request])
              return .tags(resultsVec)
            } catch {
              print("VisionService: YOLO failed - \(error.localizedDescription)")
              return .tags([])
            }
          }
        }
        
        // MobileNetV2 (Classification)
        if let mob = mob {
          group.addTask {
            var resultsVec: [ScoredTag] = []
            let request = VNCoreMLRequest(model: mob) { request, _ in
              if let results = request.results as? [VNClassificationObservation] {
                 // Take top 10 raw results to have a pool to choose from
                 let tags = results
                    .prefix(10)
                    .map { ScoredTag(identifier: $0.identifier, confidence: $0.confidence) }
                 resultsVec.append(contentsOf: tags)
              }
            }
            request.imageCropAndScaleOption = .centerCrop
            
            do {
              let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
              try handler.perform([request])
              return .tags(resultsVec)
            } catch {
              print("VisionService: MobileNet failed - \(error.localizedDescription)")
              return .tags([])
            }
          }
        }
        
        // OCR (Text Recognition) - used for backup/validation
        group.addTask {
          var texts: [String] = []
          let request = VNRecognizeTextRequest { request, _ in
             if let results = request.results as? [VNRecognizedTextObservation] {
                texts = results.compactMap { $0.topCandidates(1).first?.string }
             }
          }
          request.recognitionLevel = .accurate
          
          do {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            try handler.perform([request])
            return .ocr(texts)
          } catch {
            print("VisionService: OCR failed - \(error.localizedDescription)")
            return .ocr([])
          }
        }
        
        // Aggregate Results
        for try await result in group {
          switch result {
          case .tags(let tags):
            allTags.append(contentsOf: tags)
          case .ocr(let texts):
             // Route OCR results via allTags using a magic confidence score (100.0) to separate later
             // This avoids changing the TaskGroup return structure while enabling data extraction.
             let ocrAsTags = texts.map { ScoredTag(identifier: $0, confidence: 100.0) }
             allTags.append(contentsOf: ocrAsTags)
          }
        }
      }

      // 4. Fusion and Selection Logic
      
      // Separate ML Tags (<= 1.0) from OCR (100.0)
      let mlTags = allTags.filter { $0.confidence <= 1.0 }
      let ocrCandidates = allTags.filter { $0.confidence == 100.0 }.map { $0.identifier }
      
      // Sort ML tags by confidence
      let sortedMLTags = mlTags.sorted { $0.confidence > $1.confidence }
      
      // Helper for Validation
      func isConsistent(ocr: String, tags: [ScoredTag]) -> Bool {
        let ocrLower = ocr.lowercased()
        
        // Check for specific ignored phrases
        if ocrLower.contains("not found") || ocrLower.contains("no item") { return false }
        
        // Check for semantic match with top ML tags (loose check)
        // We check against top 10 tags to increase hit rate
        let topTags = tags.prefix(10)
        
        for tag in topTags {
            let tagLower = tag.identifier.lowercased()
            // Check substrings both ways
            if ocrLower.contains(tagLower) || tagLower.contains(ocrLower) { return true }
            
            // Check intersection of words (Split by space)
            let ocrWords = Set(ocrLower.split(separator: " ").map { String($0) })
            let tagWords = Set(tagLower.split(separator: " ").map { String($0) })
            if !ocrWords.isDisjoint(with: tagWords) { return true }
        }
        
        return false
      }
      
      var finalName: String?
      
      // Priority 1: Validated OCR Result
      // Find the "best" OCR candidate that passes validation.
      // We prioritize longer text among valid candidates.
      let validOCRCandidates = ocrCandidates
        .filter { $0.count > 4 }
        .filter { isConsistent(ocr: $0, tags: sortedMLTags) }
      
      if let bestOCR = validOCRCandidates.max(by: { $0.count < $1.count }) {
         finalName = bestOCR.capitalized
      }
      
      // Priority 2: Highest Confidence ML Tag (Fallback)
      if finalName == nil {
        if let bestMatch = sortedMLTags.first {
          finalName = bestMatch.identifier.capitalized
        }
      }
      
      let nameToUse = finalName ?? "New Item"
      
      // Tags: Top 5 unique ML tags
      var uniqueTags: [String] = []
      var seen: Set<String> = []
      
      for tagObj in sortedMLTags {
        let tagStr = tagObj.identifier.capitalized
        let tagLower = tagStr.lowercased()
        
        if !seen.contains(tagLower) {
          seen.insert(tagLower)
          uniqueTags.append(tagStr)
        }
        
        if uniqueTags.count >= 5 {
          break
        }
      }

      return VisionAnalysisResult(name: nameToUse, tags: uniqueTags)
    }.value
  }

  // MARK: - Helpers

  private func cgImageOrientation(from uiOrientation: UIImage.Orientation)
    -> CGImagePropertyOrientation
  {
    switch uiOrientation {
    case .up: return .up
    case .down: return .down
    case .left: return .left
    case .right: return .right
    case .upMirrored: return .upMirrored
    case .downMirrored: return .downMirrored
    case .leftMirrored: return .leftMirrored
    case .rightMirrored: return .rightMirrored
    @unknown default: return .up
    }
  }
}
