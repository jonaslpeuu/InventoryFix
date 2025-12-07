//
//  DesignSystem.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftUI

/// The central source of truth for the app's "Bold & Playful" design system.
struct DesignSystem {
    
    struct Colors {
        /// Key Brand Color (Vibrant Indigo)
        static let primary = Color(red: 0.4, green: 0.35, blue: 0.95) // #6659F2
        
        /// Secondary Background (Soft Lavender)
        static let background = Color(red: 0.95, green: 0.95, blue: 1.0)
        
        /// High energy accent (Electric Yellow)
        static let accent = Color(red: 1.0, green: 0.85, blue: 0.0)
        
        /// Text Primary (Dark Navy)
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.2)
        
        /// Text Secondary (Slate)
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.5)
        
        /// Card Background (White)
        static let cardBackground = Color.white
    }
    
    struct Dimensions {
        static let cornerRadius: CGFloat = 20
        static let padding: CGFloat = 16
        static let shadowRadius: CGFloat = 8
    }
    
    struct Fonts {
        static let title = Font.system(.largeTitle, design: .rounded).weight(.black)
        static let header = Font.system(.title2, design: .rounded).weight(.bold)
        static let body = Font.system(.body, design: .rounded).weight(.medium)
        static let caption = Font.system(.caption, design: .rounded).weight(.semibold)
    }
}

// MARK: - View Modifiers

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Fonts.header)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Dimensions.padding)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius))
            .shadow(color: Color.black.opacity(0.05), radius: DesignSystem.Dimensions.shadowRadius, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func appBackground() -> some View {
        self.background(DesignSystem.Colors.background.ignoresSafeArea())
    }
}
