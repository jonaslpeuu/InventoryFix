//
//  ContainerListView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftData
import SwiftUI

struct ContainerListView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var containers: [Container]
  @State private var isEditing = false
  @State private var containerToEdit: Container?
  @State private var isShowingAddContainer = false

  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        DesignSystem.Colors.background.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 20) {
            // Header
            HStack {
              Text("Your\nInventory")
                .font(DesignSystem.Fonts.title)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.leading)
              Spacer()
              Image(systemName: "archivebox.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(DesignSystem.Colors.primary)
                .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, DesignSystem.Dimensions.padding)
            .padding(.top, 20)

            // Container List
            LazyVStack(spacing: 16) {
              ForEach(containers) { container in
                Group {
                  if isEditing {
                    Button {
                      containerToEdit = container
                    } label: {
                      ContainerCardContent(container: container)
                        .overlay(alignment: .topTrailing) {
                          Image(systemName: "pencil.circle.fill")
                            .font(.title)
                            .foregroundStyle(DesignSystem.Colors.accent)
                            .padding(8)
                            .shadow(radius: 2)
                        }
                    }
                    .contextMenu {
                      Button(role: .destructive) {
                        modelContext.delete(container)
                      } label: {
                        Label("Delete", systemImage: "trash")
                      }
                    }
                  } else {
                    NavigationLink {
                      ItemListView(container: container)
                    } label: {
                      ContainerCardContent(container: container)
                    }
                    .contextMenu {
                      Button(role: .destructive) {
                        modelContext.delete(container)
                      } label: {
                        Label("Delete", systemImage: "trash")
                      }
                    }
                  }
                }
                .buttonStyle(.plain)
                .buttonStyle(.plain)
              }
            }
            .padding(.horizontal, DesignSystem.Dimensions.padding)
            .animation(.spring, value: containers)
            .animation(.easeInOut, value: isEditing)
          }
          .padding(.bottom, 80)  // Space for floating button if needed
        }
      }
      .navigationTitle("")  // Hidden default title
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(isEditing ? "Done" : "Edit") {
            withAnimation { isEditing.toggle() }
          }
          .fontWeight(.bold)
          .foregroundStyle(DesignSystem.Colors.primary)
        }
        ToolbarItem(placement: .primaryAction) {
          Button(action: { isShowingAddContainer = true }) {
            Image(systemName: "plus.circle.fill")
              .font(.title2)
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(DesignSystem.Colors.primary)
          }
        }
      }
      .sheet(isPresented: $isShowingAddContainer) {
        EditContainerView()
      }
      .sheet(item: $containerToEdit) { container in
        EditContainerView(container: container)
      }
      .toolbarColorScheme(.light, for: .navigationBar)
      .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }

  // Component extracted to avoid duplication
  struct ContainerCardContent: View {
    let container: Container
    var body: some View {
      HStack(spacing: 16) {
        if let data = container.imageData, let uiImage = UIImage(data: data) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
          RoundedRectangle(cornerRadius: 16)
            .fill(DesignSystem.Colors.background)
            .frame(width: 80, height: 80)
            .overlay {
              Image(systemName: "shippingbox")
                .font(.largeTitle)
                .foregroundStyle(DesignSystem.Colors.primary.opacity(0.4))
            }
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(container.name)
            .font(DesignSystem.Fonts.header)
            .foregroundStyle(DesignSystem.Colors.textPrimary)
          Text(container.desc)
            .font(DesignSystem.Fonts.body)
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineLimit(2)
        }
        Spacer()
      }
      .cardStyle()
    }
  }

}
