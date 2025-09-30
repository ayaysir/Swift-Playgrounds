//
//  Category.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import SwiftUI

enum Category: String, CaseIterable {
  case idol
  case live
  case event
  case sales
  case etc
  
  var bgColor: Color {
    switch self {
    case .idol:
        .cyan
    case .live:
        .blue
    case .event:
        .purple
    case .sales:
        .green
    case .etc:
        .orange
    }
  }
}
