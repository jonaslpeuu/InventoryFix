//
//  ItemListView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftData
import SwiftUI

struct ItemListView: View {
  @Bindable var container: Container
  @Environment(\.modelContext) private var modelContext
  @State private var showingAddItem = false
  @State private var newItemToEdit: Item?

  var body: some View {
    ZStack {
      DesignSystem.Colors.background.ignoresSafeArea()

      ScrollView {
        VStack(spacing: 20) {
          // Container Header
          VStack(spacing: 16) {
            if let data = container.imageData, let uiImage = UIImage(data: data) {
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: DesignSystem.Colors.primary.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
              RoundedRectangle(cornerRadius: 24)
                .fill(DesignSystem.Colors.cardBackground)
                .frame(width: 120, height: 120)
                .overlay {
                  Image(systemName: "shippingbox.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(DesignSystem.Colors.primary.opacity(0.4))
                }
            }

            VStack(spacing: 8) {
              Text(container.name)
                .font(DesignSystem.Fonts.title)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)

              if !container.desc.isEmpty {
                Text(container.desc)
                  .font(DesignSystem.Fonts.body)
                  .foregroundStyle(DesignSystem.Colors.textSecondary)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal)
              }
            }
          }
          .padding(.top, 20)

          // Items Grid/List
          LazyVStack(spacing: 16) {
            if let items = container.items, !items.isEmpty {
              ForEach(items) { item in
                NavigationLink {
                  EditItemView(item: item)
                } label: {
                  ItemCardView(item: item)
                }
                .contextMenu {
                  Button(role: .destructive) {
                    modelContext.delete(item)
                  } label: {
                    Label("Delete", systemImage: "trash")
                  }
                }
                .buttonStyle(.plain)
              }
            } else {
              ContentUnavailableView {
                Label("No Items", systemImage: "tray")
              } description: {
                Text("Add items to this container")
              }
              .foregroundStyle(DesignSystem.Colors.textSecondary)
              .padding(.top, 40)
            }
          }
          .padding(DesignSystem.Dimensions.padding)
        }
      }
    }
    .navigationTitle("")  // Hide default title
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(action: addItem) {
          Image(systemName: "plus.circle.fill")
            .font(.title2)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(DesignSystem.Colors.primary)
        }
      }
    }
    .navigationDestination(item: $newItemToEdit) { item in
      EditItemView(item: item)
    }
  }

  // Quick Add for verification
  private func addItem() {
    withAnimation {
      let newItem = Item(name: "New Item", tags: "")
      newItem.container = container
      modelContext.insert(newItem)
      newItemToEdit = newItem
    }
  }

  private func deleteItems(offsets: IndexSet) {
    guard let items = container.items else { return }
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

#Preview {
  do {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Container.self, Item.self, configurations: config)
    let exampleContainer = Container(name: "Box 1", desc: "My stuff")
    container.mainContext.insert(exampleContainer)
    return ItemListView(container: exampleContainer)
      .modelContainer(container)
  } catch {
    return Text("Failed to create preview: \(error.localizedDescription)")
  }
}
