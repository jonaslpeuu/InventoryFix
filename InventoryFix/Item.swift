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
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
