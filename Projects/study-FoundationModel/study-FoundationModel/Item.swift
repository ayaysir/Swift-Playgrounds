//
//  Item.swift
//  study-FoundationModel
//
//  Created by 윤범태 on 5/21/26.
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
