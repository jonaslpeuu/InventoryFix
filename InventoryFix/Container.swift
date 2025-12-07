//
//  Container.swift
//  InventoryFix
//
//  Created by Jonas Hoppe on 05.12.25.
//

import Foundation
import SwiftData

@Model
final class Container {
    var name: String
    var desc: String // "Beschreibung"
    @Attribute(.externalStorage) var imageData: Data?
    
    @Relationship(deleteRule: .cascade) var items: [Item]? = []
    
    init(name: String, desc: String, imageData: Data? = nil) {
        self.name = name
        self.desc = desc
        self.imageData = imageData
    }
}
