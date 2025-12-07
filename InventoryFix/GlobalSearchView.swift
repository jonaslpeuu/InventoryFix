//
//  GlobalSearchView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftData
import SwiftUI

struct GlobalSearchView: View {
  @State private var searchText = ""
  @Query private var items: [Item]

  var filteredItems: [Item] {
    if searchText.isEmpty {
      return []
    } else {
      return items.filter { item in
        item.name.localizedCaseInsensitiveContains(searchText)
          || item.tags.localizedCaseInsensitiveContains(searchText)
      }
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 16) {
            if filteredItems.isEmpty && !searchText.isEmpty {
              ContentUnavailableView.search(text: searchText)
            } else if searchText.isEmpty {
              VStack(spacing: 20) {
                Image(systemName: "magnifyingglass.circle.fill")
                  .font(.system(size: 80))
                  .foregroundStyle(DesignSystem.Colors.primary.opacity(0.8))
                  .shadow(color: DesignSystem.Colors.primary.opacity(0.2), radius: 10, x: 0, y: 5)

                Text("Search Items")
                  .font(DesignSystem.Fonts.title)
                  .foregroundStyle(.black)

                Text("Find anything by name or tags")
                  .font(DesignSystem.Fonts.body)
                  .foregroundStyle(DesignSystem.Colors.textSecondary)
              }
              .padding(.top, 60)
            } else {
              ForEach(filteredItems) { item in
                NavigationLink {
                  EditItemView(item: item)
                } label: {
                  ItemCardView(item: item)
                }
                .buttonStyle(.plain)
              }
            }
          }
          .padding(DesignSystem.Dimensions.padding)
        }
      }
      .navigationTitle("Search")
      .searchable(
        text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Search Items"
      )
      .toolbarColorScheme(.light, for: .navigationBar)
      .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }
}

#Preview {
  GlobalSearchView()
    .modelContainer(for: Item.self, inMemory: true)
}
