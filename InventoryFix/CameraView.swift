import AVFoundation
import Combine
import SwiftUI

struct CameraView: View {
  @Binding var selectedImage: UIImage?
  @Environment(\.dismiss) var dismiss
  @StateObject private var model = CameraModel()

  var body: some View {
    ZStack {
      // Camera Preview
      CameraPreview(session: model.session)
        .ignoresSafeArea()
        .onAppear { model.checkPermissions() }

      // UI Overlay
      VStack {
        // Top Controls
        HStack {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark")
              .font(.title2.bold())
              .foregroundStyle(.white)
              .padding(12)
              .background(.black.opacity(0.5))
              .clipShape(Circle())
          }

          Spacer()

          Button(action: { model.toggleFlash() }) {
            Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
              .font(.title2.bold())
              .foregroundStyle(model.isFlashOn ? .yellow : .white)
              .padding(12)
              .background(.black.opacity(0.5))
              .clipShape(Circle())
          }
        }
        .padding()

        Spacer()

        // Bottom Controls (Shutter)
        HStack {
          Spacer()
          Button(action: { model.capturePhoto() }) {
            ZStack {
              Circle()
                .strokeBorder(.white, lineWidth: 4)
                .frame(width: 80, height: 80)

              Circle()
                .fill(DesignSystem.Colors.primary)
                .frame(width: 70, height: 70)
                .padding(5)
            }
          }
          Spacer()
        }
        .padding(.bottom, 30)
      }
    }
    .background(.black)
    .onChange(of: model.capturedImage) { _, newImage in
      if let newImage {
        selectedImage = newImage
        dismiss()
      }
    }
    .onDisappear {
      model.stopSession()
    }
  }
}

// MARK: - Camera Model
class CameraModel: NSObject, ObservableObject {
  @Published var session = AVCaptureSession()
  @Published var isFlashOn = false
  @Published var capturedImage: UIImage?

  private let output = AVCapturePhotoOutput()
  private let queue = DispatchQueue(label: "camera_queue")

  override init() {
    super.init()
  }

  func checkPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { granted in
        if granted { self.setupSession() }
      }
    case .authorized:
      self.setupSession()
    default:
      break
    }
  }

  private func setupSession() {
    queue.async {
      guard !self.session.isRunning else { return }

      self.session.beginConfiguration()

      // Input
      guard
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
        let input = try? AVCaptureDeviceInput(device: device)
      else {
        return
      }

      if self.session.canAddInput(input) {
        self.session.addInput(input)
      }

      // Output
      if self.session.canAddOutput(self.output) {
        self.session.addOutput(self.output)
      }

      self.session.commitConfiguration()
      self.session.startRunning()
    }
  }

  func toggleFlash() {
    isFlashOn.toggle()
  }

  func capturePhoto() {
    let settings = AVCapturePhotoSettings()
    settings.flashMode = isFlashOn ? .on : .off
    output.capturePhoto(with: settings, delegate: self)
  }
  
  func stopSession() {
    queue.async {
      if self.session.isRunning {
        self.session.stopRunning()
      }
    }
  }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
  func photoOutput(
    _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?
  ) {
    guard let data = photo.fileDataRepresentation(),
      let image = UIImage(data: data)
    else { return }
    
    // Stop session on background queue to avoid UI freeze
    queue.async {
      self.session.stopRunning()
    }

    DispatchQueue.main.async {
      self.capturedImage = image
    }
  }
}

// MARK: - Preview View
struct CameraPreview: UIViewRepresentable {
  let session: AVCaptureSession

  func makeUIView(context: Context) -> VideoPreviewView {
    let view = VideoPreviewView()
    view.videoPreviewLayer.session = session
    view.videoPreviewLayer.videoGravity = .resizeAspectFill
    return view
  }

  func updateUIView(_ uiView: VideoPreviewView, context: Context) {}

  class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
      AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
      return layer as! AVCaptureVideoPreviewLayer
    }
  }
}
