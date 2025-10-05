//
//  PlannerLocale.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/5/25.
//

import Foundation
import ComposableArchitecture

enum PlannerLocale: String, CaseIterable {
  case ja
  case ko
}

/// 다국어 문자열 테이블을 관리하는 유틸리티
struct AppLocaleTextProvider {
  /// 주어진 key와 locale에 해당하는 문자열을 반환
  static func localizedText(dictText: String, for key: String, locale: PlannerLocale) -> String {
    let lines = dictText.split(separator: "\n").map { String($0) }
    guard let header = lines.first else {
      print(#function, "not found header")
      return key
    }

    // 헤더 확인 (keyName ja ko)
    let headerColumns = header.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
    guard headerColumns.count == 3,
          headerColumns[0] == "keyName",
          headerColumns[1] == "ja",
          headerColumns[2] == "ko"
    else {
      print(#function, "not valid header", headerColumns.count, headerColumns)
      return key
    }
    
    // 행 탐색
    for line in lines.dropFirst() {
      let columns = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
      guard columns.count >= 3 else { continue }
      let keyName = columns[0]
      if keyName == key {
        switch locale {
        case .ja: return columns[1]
        case .ko: return columns[2]
        }
      }
    }
    
    return key // fallback
  }
}
