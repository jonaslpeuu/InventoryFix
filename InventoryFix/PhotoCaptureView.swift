//
//  PhotoCaptureView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import PhotosUI
import SwiftUI

struct PhotoCaptureView: View {
  @Binding var imageData: Data?

  @State private var selectedItem: PhotosPickerItem?
  @State private var showingCamera = false
  @State private var cameraImage: UIImage?

  var body: some View {
    VStack(spacing: 20) {
      // Display Image
      if let imageData, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(height: 200)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      } else {
        ContentUnavailableView("No Photo", systemImage: "photo.badge.plus")
          .frame(height: 200)
          .foregroundStyle(DesignSystem.Colors.textSecondary)
          .background(DesignSystem.Colors.cardBackground.opacity(0.5))
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
          )
      }

      HStack(spacing: 20) {
        // Photo Library Selection
        PhotosPicker(selection: $selectedItem, matching: .images) {
          Label("Select Photo", systemImage: "photo.on.rectangle")
            .font(DesignSystem.Fonts.body.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
              Capsule()
                .fill(DesignSystem.Colors.primary)
                .shadow(color: DesignSystem.Colors.primary.opacity(0.4), radius: 8, y: 4)
            }
        }
        .onChange(of: selectedItem) { oldItem, newItem in
          Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data)
            {
              processAndSetImage(uiImage)
            }
          }
        }

        // Camera Button
        Button {
          showingCamera = true
        } label: {
          Label("Take Photo", systemImage: "camera")
            .font(DesignSystem.Fonts.body.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
              Capsule()
                .fill(DesignSystem.Colors.primary)
                .shadow(color: DesignSystem.Colors.primary.opacity(0.4), radius: 8, y: 4)
            }
        }
        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
        .opacity(UIImagePickerController.isSourceTypeAvailable(.camera) ? 1 : 0.5)
      }
      .buttonStyle(.plain)
    }
    .sheet(isPresented: $showingCamera) {
      CameraView(selectedImage: $cameraImage)
    }
    .onChange(of: cameraImage) { oldValue, newValue in
      if let newValue {
        processAndSetImage(newValue)
      }
    }
  }

  private func processAndSetImage(_ image: UIImage) {
    if let processedData = ImageUtils.processImage(image) {
      imageData = processedData
    }
  }
}

#Preview {
  PhotoCaptureView(imageData: .constant(nil))
}
