//
//  Item.swift
//  study-BackgroundTasks
//
//  Created by 윤범태 on 9/30/24.
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
