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
      switch action {
      case .adjustLevel:
        state.adjustLevelState.level = max(0, state.adjustLevelState.level)
        return .none
      }
    }
  }
}
