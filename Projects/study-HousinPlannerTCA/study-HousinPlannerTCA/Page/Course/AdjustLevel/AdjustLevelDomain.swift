//
//  AdjustLevel.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/29/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AdjustLevelDomain {
  @ObservableState
  struct State: Equatable {
    var level: Int = 0
    var maxLevel: Int = 10
  }
  
  enum Action: Equatable {
    case didTapPlusButton
    case didTapMinusButton
  }
  
  var body: some ReducerOf<Self> {
    // some scopes...
    
    Reduce { state, action in
      switch action {
      case .didTapPlusButton:
        state.level += 1
        return .none
      case .didTapMinusButton:
        state.level -= 1
        return .none
      }
    }
  }
}
