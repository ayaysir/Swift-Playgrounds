//
//  AddToCartDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//


import Foundation
import ComposableArchitecture

@Reducer
struct AddToCartDomain {
  @ObservableState
  struct State: Equatable {
    var count = 0
  }
  
  enum Action: Equatable {
    case didTapPlusButton
    case didTapMinusButton
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    /*
     tap Plus/Minus 버튼을 누르면 1을 증가/감소 시키고 이펙트 반환 없이 종료
     */
    switch action {
    case .didTapPlusButton:
      state.count += 1
      return .none
    case .didTapMinusButton:
      if state.count > 0 {
        state.count -= 1
      }
      return .none
    }
  }
}
