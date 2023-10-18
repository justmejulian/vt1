//
//  Item.swift
//  vt1
//
//  Created by Julian Visser on 16.10.2023.
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
