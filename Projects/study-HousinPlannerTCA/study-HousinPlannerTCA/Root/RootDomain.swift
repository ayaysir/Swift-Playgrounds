//
//  RootDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootDomain {
  
  // MARK: - State
  
  @ObservableState
  struct State: Equatable {
    var selectedTab: Tab = .planner
  }
  
  // 세부 종류
  
  enum Tab {
    case planner
    case etc
  }
  
  // MARK: - Action
  
  enum Action {
    case selectTab(Tab)
  }
  
   // MARK: - Reducer
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .selectTab(let tab):
        state.selectedTab = tab
        return .none
      }
    }
  }
}
