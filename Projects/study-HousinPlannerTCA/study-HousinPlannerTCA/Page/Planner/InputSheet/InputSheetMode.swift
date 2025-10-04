//
//  InputSheetMode.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/4/25.
//

import SwiftUI

enum InputSheetMode {
  case userSetTotalCount
  case newDraftName
}

extension InputSheetMode {
  var sheetTitle: String {
    switch self {
    case .userSetTotalCount: "총 숫자 설정"
    case .newDraftName: "새 드래프트 이름 설정"
    }
  }
  
  var sheetHeaderText: String {
    switch self {
    case .userSetTotalCount: "총 숫자를 입력하세요"
    case .newDraftName: "새 드래프트의 이름을 입력하세요"
    }
  }
  
  var placeholder: String {
    switch self {
    case .userSetTotalCount: "숫자 입력"
    case .newDraftName: "드래프트 이름"
    }
  }
  
  var keyboardType: UIKeyboardType {
    switch self {
    case .userSetTotalCount: .numberPad
    case .newDraftName: .default
    }
  }
}
