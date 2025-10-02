//
//  DetailSheetDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/2/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DetailSheetDomain {
  @ObservableState
  struct State: Equatable {
    var course: Course
    var adjustLevelState: AdjustLevelDomain.State
  }
  
  enum Action: Equatable {
    case dismiss
    case adjustLevel(AdjustLevelDomain.Action)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .dismiss:
        return .none
      case .adjustLevel(_):
        return .none
      }
    }
  }
}
