//
//  ItemCardView.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import SwiftUI

struct ItemCardView: View {
  let item: Item

  var body: some View {
    HStack(spacing: DesignSystem.Dimensions.padding) {
      // Item Image
      if let data = item.imageData, let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: 70, height: 70)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(DesignSystem.Colors.background, lineWidth: 2)
          )
      } else {
        RoundedRectangle(cornerRadius: 16)
          .fill(DesignSystem.Colors.background)
          .frame(width: 70, height: 70)
          .overlay {
            Image(systemName: "photo")
              .font(.title2)
              .foregroundStyle(DesignSystem.Colors.primary.opacity(0.4))
          }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(item.name)
          .font(DesignSystem.Fonts.header)
          .foregroundStyle(DesignSystem.Colors.textPrimary)
          .lineLimit(1)

        if let containerName = item.container?.name {
          HStack(spacing: 4) {
            Image(systemName: "box.truck")
              .font(.caption2)
            Text(containerName)
              .font(DesignSystem.Fonts.caption)
          }
          .foregroundStyle(DesignSystem.Colors.textSecondary)
          .padding(.vertical, 4)
          .padding(.horizontal, 8)
          .background(DesignSystem.Colors.background)
          .clipShape(Capsule())
        } else {
          Text("No Container")
            .font(DesignSystem.Fonts.caption)
            .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.system(size: 14, weight: .bold, design: .rounded))
        .foregroundStyle(DesignSystem.Colors.primary.opacity(0.3))
    }
    .cardStyle()
  }
}
