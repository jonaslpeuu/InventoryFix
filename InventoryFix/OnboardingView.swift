//
//  OnboardingView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftUI

struct OnboardingView: View {
  @Binding var hasLaunchedBefore: Bool
  @State private var selection = 0

  var body: some View {
    ZStack {
      DesignSystem.Colors.background.ignoresSafeArea()

      VStack {
        TabView(selection: $selection) {
          OnboardingSlide(
            imageName: "archivebox.circle.fill",
            title: "Chaos beseitigen",
            description: "Nie wieder suchen müssen. Organisiere deine Werkstatt und behalte den vollen Überblick über all deine Gegenstände."
          )
          .tag(0)

          OnboardingSlide(
            imageName: "camera.macro.circle.fill",
            title: "KI-Erfassung",
            description: "Mach einfach ein Foto. Unsere KI erkennt automatisch den Namen und passende Tags für deine Gegenstände."
          )
          .tag(1)

          OnboardingSlide(
            imageName: "magnifyingglass.circle.fill",
            title: "Ordnung Finden",
            description: "Finde jeden Container und jeden Gegenstand in Sekunden durch die intelligente Suche."
          )
          .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))

        // Navigation / Finish Button
        VStack {
            if selection == 2 {
            Button(action: {
              withAnimation {
                hasLaunchedBefore = true
              }
            }) {
              Text("Loslegen")
                .font(DesignSystem.Fonts.body.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(DesignSystem.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 10, y: 5)
            }
            .transition(.opacity)
          } else {
              Button(action: {
                  withAnimation {
                      selection += 1
                  }
              }) {
                  Text("Weiter")
                      .font(DesignSystem.Fonts.body.weight(.medium))
                      .foregroundStyle(DesignSystem.Colors.primary)
              }
          }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 50)
        .frame(height: 100)
      }
    }
  }
}

struct OnboardingSlide: View {
  let imageName: String
  let title: String
  let description: String

  var body: some View {
    VStack(spacing: 20) {
      Spacer()
      Image(systemName: imageName)
        .resizable()
        .scaledToFit()
        .frame(width: 150, height: 150)
        .foregroundStyle(DesignSystem.Colors.primary)
        .symbolEffect(.bounce, value: true) // iOS 17 animation if available, otherwise ignored

      Text(title)
        .font(DesignSystem.Fonts.title)
        .foregroundStyle(DesignSystem.Colors.textPrimary)

      Text(description)
        .font(DesignSystem.Fonts.body)
        .multilineTextAlignment(.center)
        .foregroundStyle(DesignSystem.Colors.textSecondary)
        .padding(.horizontal, 32)
      Spacer()
    }
  }
}

#Preview {
  OnboardingView(hasLaunchedBefore: .constant(false))
}
