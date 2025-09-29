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
      // ProductDomain.Reduce.didTapMinusButton 에서 0 미만 안되도록 처리
      // ProductDomain에도 count가 있으며
      // get { addToCartState.count } 이런 식으로 하위 도메인의 상태에서 가져옴
      // if state.count > 0 {
      //   state.count -= 1
      // }
      state.count -= 1
      return .none
    }
  }
}
