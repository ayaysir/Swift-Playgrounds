//
//  Double+.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/7/25.
//

import Foundation

extension Double {
  var percentString: String {
    String(format: "%.0f%%", self * 100)
  }
}
