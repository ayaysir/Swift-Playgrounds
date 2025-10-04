//
//  DateFormatter+.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/4/25.
//

import Foundation

extension DateFormatter {
  static let ymdhm: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter
  }()
}

extension Date {
  var ymdhm: String {
    DateFormatter.ymdhm.string(from: self)
  }
}
