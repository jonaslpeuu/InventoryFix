//
//  WalkthroughView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftUI

/// A scripted tutorial that guides the user through the app's core flows using simulated views.
struct WalkthroughView: View {
  @Binding var hasCompletedWalkthrough: Bool
  @State private var step: Int = 0

  // Animation States
  @State private var showHand = false
  @State private var typedName = ""
  @State private var typedDesc = ""
  @State private var showPhoto = false
  @State private var typedItemName = ""
  @State private var typedItemTags = ""
  @State private var showItemPhoto = false

  var body: some View {
    ZStack {
      // Background (Shared)
      DesignSystem.Colors.background.ignoresSafeArea()

      // Content based on step
      Group {
        switch step {
        case 0:
          // Step 1: Container List & Create Button
          mockContainerListView(showPulse: true)
            .overlay(alignment: .topTrailing) {
              instructionBubble(text: "Hier erstellst du deinen ersten Container.", arrowDirection: .top, alignment: .trailing)
                .padding(.top, 90)
                .padding(.trailing, 20)
                .frame(maxWidth: 200) // Limit width to ensure it stays on the right
            }

        case 1:
          // Step 2: Edit Container View
          mockEditContainerView()
            .overlay(alignment: .center) {
              if typedName.isEmpty {
                instructionBubble(text: "Hier wird der Name und das Foto automatisch erklärt.", arrowDirection: .bottom)
              }
            }

        case 2:
          // Step 3: Container Created -> Enter it
          mockContainerListView(hasItem: true, showPulse: true)
            .overlay(alignment: .center) {
              instructionBubble(text: "Dein Container ist fertig! Tippe ihn an.", arrowDirection: .bottom)
                .offset(y: -40)
            }

        case 3:
          // Step 4: Empty Item List -> Add Item
          mockItemListView(showPulse: true)
            .overlay(alignment: .topTrailing) {
              instructionBubble(text: "Hier erstellst du einen neuen Gegenstand.", arrowDirection: .top, alignment: .trailing)
                .padding(.top, 90)
                .padding(.trailing, 20)
                .frame(maxWidth: 200)
            }

        case 4:
          // Step 5: Edit Item View -> Recognition
          mockEditItemView()
            .overlay(alignment: .bottom) {
              instructionBubble(text: "Foto machen und die KI erkennt den Rest!", arrowDirection: .top)
                .padding(.bottom, 100)
            }

        case 5:
          // Step 6: Success / Finish
          successView()

        default:
          EmptyView()
        }
      }

      // Navigation Controls
      VStack {
        Spacer()
        HStack {
            if step > 0 {
                Button("Zurück") {
                    withAnimation {
                        step -= 1
                        resetStepState()
                    }
                }
                .font(DesignSystem.Fonts.caption)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            Spacer()
            if step == 5 {
                Button("App Starten") {
                    withAnimation { hasCompletedWalkthrough = true }
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 150)
            } else {
                Button("Weiter") {
                    withAnimation {
                        step += 1
                        simulateStepActions()
                    }
                }
                .disabled(step == 0 || step == 2 || step == 3)
                .opacity(0.0) // Versteckt, wir nutzen simulierte Klicks oder Timer

            }
        }
        .padding()
      }
    }
    .onAppear {
        simulateStepActions()
    }
  }
    
    private func resetStepState() {
        typedName = ""
        typedDesc = ""
        showPhoto = false
        typedItemName = ""
        typedItemTags = ""
        showItemPhoto = false
    }

  private func simulateStepActions() {
    // Reset state for the new step
    resetStepState()

    if step == 1 {
      // Type in container name simulation
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        typeText("Werkzeugkiste", into: $typedName)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        withAnimation { showPhoto = true } // Simulate photo taken
      }
    }
    
    if step == 4 {
        // Compose Item simulation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showItemPhoto = true } // Snap
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            typeText("Hammer", into: $typedItemName)
            typeText("Werkzeug, Handwerk", into: $typedItemTags)
        }
    }
  }

  private func typeText(_ text: String, into binding: Binding<String>) {
    binding.wrappedValue = ""
    for (index, char) in text.enumerated() {
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
        binding.wrappedValue += String(char)
      }
    }
  }
    
  // MARK: - Mock Views

  @ViewBuilder
  func mockContainerListView(hasItem: Bool = false, showPulse: Bool = false) -> some View {
    VStack(spacing: 20) {
      HStack {
        Text("Your\nInventory")
          .font(DesignSystem.Fonts.title)
          .foregroundStyle(DesignSystem.Colors.textPrimary)
        Spacer()
        Image(systemName: "archivebox.circle.fill")
          .font(.system(size: 60))
          .foregroundStyle(DesignSystem.Colors.primary)
      }
      .padding(.top, 20)
      .padding(.horizontal, DesignSystem.Dimensions.padding)

      if hasItem {
          HStack(spacing: 16) {
              RoundedRectangle(cornerRadius: 16)
                  .fill(Color.gray.opacity(0.2))
                  .frame(width: 80, height: 80)
                  .overlay { Image(systemName: "shippingbox").foregroundStyle(.gray) }
              VStack(alignment: .leading) {
                  Text("Werkzeugkiste")
                      .font(DesignSystem.Fonts.header)
                      .foregroundStyle(DesignSystem.Colors.textPrimary)
                  Text("Rote Kiste")
                      .font(DesignSystem.Fonts.body)
                      .foregroundStyle(DesignSystem.Colors.textSecondary)
              }
              Spacer()
          }
          .cardStyle()
          .padding(.horizontal)
          .onTapGesture {
              if step == 2 { withAnimation { step += 1; simulateStepActions() } }
          }
          .overlay {
              if step == 2 {
                  RoundedRectangle(cornerRadius: 20)
                      .stroke(DesignSystem.Colors.accent, lineWidth: 4)
                      .scaleEffect(showHand ? 1.05 : 1.0)
                      .opacity(showHand ? 0.0 : 1.0)
                      .onAppear { withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) { showHand = true } }
              }
          }
          Spacer()
      } else {
          Spacer()
          VStack(spacing: 16) {
             Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundStyle(DesignSystem.Colors.textSecondary.opacity(0.3))
             Text("No Containers")
                .font(DesignSystem.Fonts.title)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
          }
          Spacer()
      }
    }
    .overlay(alignment: .topTrailing) {
      // Plus Button Mock
        Image(systemName: "plus.circle.fill")
          .font(.system(size: 44)) // Explicit size matching app
          .symbolRenderingMode(.hierarchical) // Matching app style
          .foregroundStyle(DesignSystem.Colors.primary)
          .padding()
          .padding(.top, 50) // Adjust for safe area
          .onTapGesture {
              if step == 0 { withAnimation { step += 1; simulateStepActions() } }
          }
          // Removing pulse for cleaner look if desired, or keeping it subtle
          .scaleEffect(showPulse ? 1.1 : 1.0)
          .animation(showPulse ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: showPulse)
          .onAppear { if step == 0 { showPulseState() } }
    }
  }

  @State private var pulse = false
  func showPulseState() { withAnimation { pulse = true } }

  @ViewBuilder
  func mockEditContainerView() -> some View {
    VStack(spacing: 24) {
      // Photo
      RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius)
        .fill(DesignSystem.Colors.background)
        .frame(height: 200)
        .overlay {
            if showPhoto {
                Image(systemName: "shippingbox.fill")
                    .resizable().scaledToFit().padding(50).foregroundStyle(DesignSystem.Colors.primary)
                    .transition(.opacity)
            } else {
                Image(systemName: "camera.fill")
                    .font(.largeTitle)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
        .cardStyle()

      // Inputs
      VStack(alignment: .leading, spacing: 8) {
        Text("Name").font(DesignSystem.Fonts.caption).foregroundStyle(DesignSystem.Colors.primary)
        Text(typedName.isEmpty ? "Container Name" : typedName)
          .font(DesignSystem.Fonts.header)
          .foregroundStyle(typedName.isEmpty ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.textPrimary)
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(DesignSystem.Colors.cardBackground)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
      }
      .padding(.horizontal)
        
        Button("Create Container") {
            if step == 1 { withAnimation { step += 1; simulateStepActions() } }
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding()
        .disabled(typedName.isEmpty)
        
        Spacer()
    }
    .padding(.top, 60)
  }
    
    @ViewBuilder
    func mockItemListView(showPulse: Bool = false) -> some View {
        VStack {
            // Header
            VStack(spacing: 4) {
               Text("Werkzeugkiste")
                  .font(DesignSystem.Fonts.title)
                  .foregroundStyle(DesignSystem.Colors.textPrimary)
               Text("Description") // Or specific text
                  .font(DesignSystem.Fonts.body)
                  .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            .padding(.top, 20)
            
            Spacer()
            VStack(spacing: 16) {
               Image(systemName: "tray")
                  .font(.system(size: 60))
                  .foregroundStyle(DesignSystem.Colors.textSecondary.opacity(0.3))
               Text("No Items")
                  .font(DesignSystem.Fonts.title)
                  .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
          // Plus Button Mock
            Image(systemName: "plus.circle.fill")
              .font(.system(size: 44))
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(DesignSystem.Colors.primary)
              .padding()
              .padding(.top, 50)
              .onTapGesture {
                  if step == 3 { withAnimation { step += 1; simulateStepActions() } }
              }
              .scaleEffect(showPulse ? 1.1 : 1.0)
              .animation(showPulse ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: showPulse)
        }
    }
    
    @ViewBuilder
    func mockEditItemView() -> some View {
      VStack(spacing: 24) {
        // Photo w/ Analysis
        RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius)
          .fill(DesignSystem.Colors.background)
          .frame(height: 200)
          .overlay {
              if showItemPhoto {
                  ZStack {
                      Image(systemName: "hammer.fill")
                          .resizable().scaledToFit().padding(50).foregroundStyle(DesignSystem.Colors.primary)
                      if typedItemName.isEmpty { // Analysis overlay simulation
                          Color.black.opacity(0.4)
                          VStack {
                              ProgressView().tint(.white)
                              Text("Analyzing...").foregroundStyle(.white).font(.caption)
                          }
                      }
                  }
              } else {
                  Image(systemName: "camera.fill").foregroundStyle(.gray)
              }
          }
          .cardStyle()

        // Inputs
        VStack(alignment: .leading) {
          Text("Name").font(DesignSystem.Fonts.caption)
          Text(typedItemName.isEmpty ? "Item Name" : typedItemName)
            .font(DesignSystem.Fonts.header)
            .foregroundStyle(typedItemName.isEmpty ? .gray : .black)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
          Text("Tags").font(DesignSystem.Fonts.caption)
          Text(typedItemTags.isEmpty ? "Tags" : typedItemTags)
            .font(DesignSystem.Fonts.body)
            .foregroundStyle(typedItemTags.isEmpty ? .gray : .black)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
          
          Button("Save Item") {
              if step == 4 { withAnimation { step += 1; simulateStepActions() } }
          }
          .buttonStyle(PrimaryButtonStyle())
          .padding()
          .disabled(typedItemName.isEmpty)
          
        Spacer()
      }
      .padding(.top, 60)
    }
    
    @ViewBuilder
    func successView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(DesignSystem.Colors.primary)
                .symbolEffect(.bounce)
            
            Text("Alles bereit!")
                .font(DesignSystem.Fonts.title)
            
            Text("Du hast gelernt wie man Container und Gegenstände erstellt. Viel Spaß!")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
    }

  @ViewBuilder
  func instructionBubble(text: String, arrowDirection: Edge, alignment: HorizontalAlignment = .center) -> some View {
    VStack(alignment: alignment, spacing: 0) {
      if arrowDirection == .bottom {
        Text(text)
          .font(DesignSystem.Fonts.caption)
          .foregroundStyle(.white)
          .padding(12)
          .background(DesignSystem.Colors.primary)
          .cornerRadius(12)
        
        Image(systemName: "arrowtriangle.down.fill")
          .font(.caption)
          .foregroundStyle(DesignSystem.Colors.primary)
          .padding(alignment == .trailing ? .trailing : (alignment == .leading ? .leading : .init()), 20)
          .offset(y: -3)
      } else {
        Image(systemName: "arrowtriangle.up.fill")
          .font(.caption)
          .foregroundStyle(DesignSystem.Colors.primary)
          .padding(alignment == .trailing ? .trailing : (alignment == .leading ? .leading : .init()), 20)
          .offset(y: 3)
          
        Text(text)
          .font(DesignSystem.Fonts.caption)
          .foregroundStyle(.white)
          .padding(12)
          .background(DesignSystem.Colors.primary)
          .cornerRadius(12)
      }
    }
    .shadow(radius: 5)
  }
}

#Preview {
    WalkthroughView(hasCompletedWalkthrough: .constant(false))
}
