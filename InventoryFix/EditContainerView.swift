//
//  EditContainerView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftData
import SwiftUI

struct EditContainerView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var name: String = ""
  @State private var desc: String = ""
  @State private var imageData: Data?

  var container: Container?

  // Initializer for editing existing container
  init(container: Container? = nil) {
    self.container = container
    if let container {
      _name = State(initialValue: container.name)
      _desc = State(initialValue: container.desc)
      _imageData = State(initialValue: container.imageData)
    }
  }

  var body: some View {
    PlatformAwareNavigationStack {
      ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {
            // Photo Section
            PhotoCaptureView(imageData: $imageData)
              .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius))
              .shadow(color: DesignSystem.Colors.primary.opacity(0.1), radius: 10, x: 0, y: 5)

            // Info Section
            VStack(spacing: 16) {
              VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                  .font(DesignSystem.Fonts.caption)
                  .foregroundStyle(DesignSystem.Colors.primary)
                  .padding(.leading, 4)

                ZStack(alignment: .leading) {
                  if name.isEmpty {
                    Text("Container Name")
                      .font(DesignSystem.Fonts.header)
                      .foregroundStyle(DesignSystem.Colors.textSecondary)
                      .padding(.horizontal)
                      .allowsHitTesting(false)
                  }
                  TextField("", text: $name)
                    .font(DesignSystem.Fonts.header)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .padding()
                }
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
              }

              VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                  .font(DesignSystem.Fonts.caption)
                  .foregroundStyle(DesignSystem.Colors.primary)
                  .padding(.leading, 4)

                ZStack(alignment: .leading) {
                  if desc.isEmpty {
                    Text("Description")
                      .font(DesignSystem.Fonts.body)
                      .foregroundStyle(DesignSystem.Colors.textSecondary)
                      .padding(.horizontal)
                      .allowsHitTesting(false)
                  }
                  TextField("", text: $desc)
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

            // Primary Action Button (Prominent)
            Button(action: save) {
              Text(container == nil ? "Create Container" : "Save Changes")
                .font(DesignSystem.Fonts.body.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                  name.isEmpty ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.primary
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                  color: (name.isEmpty
                    ? Color.clear : DesignSystem.Colors.primary.opacity(0.3)), radius: 10, y: 5)
            }
            .disabled(name.isEmpty)
            .padding(.horizontal, DesignSystem.Dimensions.padding)
            .padding(.top, 10)
          }
          .padding(.vertical, 20)
        }
      }
      .navigationTitle(container == nil ? "New Container" : "Edit Container")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarColorScheme(.light, for: .navigationBar)
      .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }

      }
    }
  }

  // Helper for conditional navigation stack if needed
  @ViewBuilder
  private func PlatformAwareNavigationStack<Content: View>(@ViewBuilder content: () -> Content)
    -> some View
  {
    if #available(iOS 16.0, *) {
      NavigationStack { content() }
    } else {
      NavigationView { content() }
    }
  }

  private func save() {
    if let container {
      container.name = name
      container.desc = desc
      container.imageData = imageData
    } else {
      let newContainer = Container(name: name, desc: desc, imageData: imageData)
      modelContext.insert(newContainer)
    }
    dismiss()
  }
}

#Preview {
  EditContainerView()
}
