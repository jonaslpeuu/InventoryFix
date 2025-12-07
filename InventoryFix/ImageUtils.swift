//
//  ImageUtils.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import UIKit

struct ImageUtils {

  /// Resizes the image to fit within maxDimension and compresses it to JPEG data.
  static func processImage(
    _ image: UIImage, maxDimension: CGFloat = 800, compressionQuality: CGFloat = 0.6
  ) -> Data? {
    // 1. Calculate new size
    let newSize = calculateSize(for: image.size, maxDimension: maxDimension)

    // 2. Resize image
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let resizedImage = renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: newSize))
    }

    // 3. Compress to Data
    return resizedImage.jpegData(compressionQuality: compressionQuality)
  }

  private static func calculateSize(for currentSize: CGSize, maxDimension: CGFloat) -> CGSize {
    let width = currentSize.width
    let height = currentSize.height

    if width <= maxDimension && height <= maxDimension {
      return currentSize
    }

    let aspectRatio = width / height

    if width > height {
      return CGSize(width: maxDimension, height: maxDimension / aspectRatio)
    } else {
      return CGSize(width: maxDimension * aspectRatio, height: maxDimension)
    }
  }
}
