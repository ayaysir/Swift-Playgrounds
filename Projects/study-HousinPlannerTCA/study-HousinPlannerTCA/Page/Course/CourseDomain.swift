//
//  CourseDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CourseDomain {
  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID
    let course: Course
    var adjustLevelState = AdjustLevelDomain.State()
  }
  
  enum Action {
    case adjustLevel(AdjustLevelDomain.Action)
  }
  
  var body: some ReducerOf<Self> {
    // RootAction.addToCart(하위 액션) 구조를 자동으로 추론하여, 하위 도메인 액션을 연결
    Scope(state: \.adjustLevelState, action: \.adjustLevel) {
      AdjustLevelDomain()
    }
    
    Reduce { state, action in
      let maxLevel = state.course.effects.count
      
      switch action {
      case .adjustLevel(.didTapPlusButton):
        state.adjustLevelState.level = min(state.adjustLevelState.level, maxLevel)
        return .none

      case .adjustLevel(.didTapMinusButton):
        state.adjustLevelState.level = max(state.adjustLevelState.level, 0)
        return .none

      case .adjustLevel:
        return .none
      }
    }
  }
}
