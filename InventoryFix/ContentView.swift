//
//  ContentView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
  @AppStorage("hasCompletedWalkthrough") var hasCompletedWalkthrough: Bool = false

  var body: some View {
    if !hasLaunchedBefore {
      OnboardingView(hasLaunchedBefore: $hasLaunchedBefore)
        .transition(.move(edge: .leading))
    } else if !hasCompletedWalkthrough {
      WalkthroughView(hasCompletedWalkthrough: $hasCompletedWalkthrough)
        .transition(.opacity)
    } else {
      MainTabView()
        .transition(.move(edge: .trailing))
    }
  }
}

struct MainTabView: View {
  var body: some View {
    TabView {
      ContainerListView()
        .tabItem {
          Label("Browse", systemImage: "archivebox")
        }

      GlobalSearchView()
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
    }
  }
}

#Preview {
    ContentView()
        .modelContainer(for: Container.self, inMemory: true)
}
