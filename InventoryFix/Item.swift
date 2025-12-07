//
//  Item.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import Foundation
import SwiftData

@Model
final class Item {
  var name: String
  var tags: String  // Comma separated tags
  @Attribute(.externalStorage) var imageData: Data?

  var container: Container?

  init(name: String, tags: String = "", imageData: Data? = nil) {
    self.name = name
    self.tags = tags
    self.imageData = imageData
  }
}
