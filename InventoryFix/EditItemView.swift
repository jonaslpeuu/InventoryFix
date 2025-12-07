//
//  EditItemView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftData
import SwiftUI

struct EditItemView: View {
  @Bindable var item: Item
  @State private var isAnalyzing = false
  @State private var analysisTask: Task<Void, Never>?

  var body: some View {
    PlatformAwareNavigationStack {
      ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {
            // Photo Section
            ZStack {
              PhotoCaptureView(imageData: $item.imageData)
                .onChange(of: item.imageData) { _, newValue in
                  analyzeImage(data: newValue)
                }

              if isAnalyzing {
                RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius)
                  .fill(.black.opacity(0.4))
                  .frame(height: 200)
                  .overlay {
                    VStack(spacing: 12) {
                      ProgressView()
                        .tint(.white)
                      Text("Analyzing...")
                        .font(DesignSystem.Fonts.caption)
                        .foregroundStyle(.white)
                    }
                  }
              }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius))
            .shadow(color: DesignSystem.Colors.primary.opacity(0.1), radius: 10, x: 0, y: 5)

            // Details Section
            VStack(spacing: 16) {
              VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                  .font(DesignSystem.Fonts.caption)
                  .foregroundStyle(DesignSystem.Colors.primary)
                  .padding(.leading, 4)

                ZStack(alignment: .leading) {
                  if item.name.isEmpty {
                    Text("Item Name")
                      .font(DesignSystem.Fonts.header)
                      .foregroundStyle(DesignSystem.Colors.textSecondary)
                      .padding(.horizontal)
                      .allowsHitTesting(false)
                  }
                  TextField("", text: $item.name)
                    .font(DesignSystem.Fonts.header)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .padding()
                }
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
              }

              VStack(alignment: .leading, spacing: 8) {
                Text("Tags")
                  .font(DesignSystem.Fonts.caption)
                  .foregroundStyle(DesignSystem.Colors.primary)
                  .padding(.leading, 4)

                ZStack(alignment: .leading) {
                  if item.tags.isEmpty {
                    Text("Tags (comma separated)")
                      .font(DesignSystem.Fonts.body)
                      .foregroundStyle(DesignSystem.Colors.textSecondary)
                      .padding(.horizontal)
                      .allowsHitTesting(false)
                  }
                  TextField("", text: $item.tags)
                    .font(DesignSystem.Fonts.body)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .padding()
                }
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
              }
            }
            .padding(.horizontal, DesignSystem.Dimensions.padding)
          }
          .padding(.vertical, 20)
        }
      }
      .navigationTitle("Edit Item")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarColorScheme(.light, for: .navigationBar)
      .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }

  @ViewBuilder
  private func PlatformAwareNavigationStack<Content: View>(@ViewBuilder content: () -> Content)
    -> some View
  {
    if #available(iOS 16.0, *) {
      content()
    } else {
      NavigationView { content() }
    }
  }

  private func analyzeImage(data: Data?) {
    guard let data, let uiImage = UIImage(data: data) else { return }

    // Cancel previous task if any
    analysisTask?.cancel()

    isAnalyzing = true
    analysisTask = Task {
      do {
        let result = try await VisionService.shared.classify(image: uiImage)

        if !Task.isCancelled {
          // Update Item Logic using structured result
          item.name = result.name
          item.tags = result.tags.joined(separator: ", ")
        }
      } catch {
        print("Vision Analysis Failed: \(error.localizedDescription)")
      }

      isAnalyzing = false
    }
  }
}
