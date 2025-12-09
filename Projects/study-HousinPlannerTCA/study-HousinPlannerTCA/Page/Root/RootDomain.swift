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
    var selectedTab: Tab = .randomSelector
    /*
     TCA에서 scope를 사용하려면, RootDomain.State 안에 PlannerDomain.State를 포함시키고,
     RootDomain.Action에도 PlannerFeature.Action을 위임할 케이스를 추가해야 합니다.
     */
    var plannerSt = PlannerDomain.State()
    
    var randomSelectorSt = RandomSelectorDomain.State()
  }
  
  // 세부 종류
  
  enum Tab {
    case planner
    case etc
    case randomSelector
  }
  
  // MARK: - Action
  
  enum Action {
    case appStarted
    case selectTab(Tab)
    case plannerAct(PlannerDomain.Action)
    case randomSelectorAct(RandomSelectorDomain.Action)
  }
  
   // MARK: - Reducer
  
  var body: some ReducerOf<Self> {
    // PlannerDomain 를 scope로 연결
    Scope(
      state: \.plannerSt, // RootDomain.State.plannerSt
      action: \.plannerAct, // RootDomain.Action.plannerAct
      child: { PlannerDomain() }
    )
    
    // RandomSelectorDomain을 Scope로 연결
    Scope(
      state: \.randomSelectorSt,
      action: \.randomSelectorAct,
      child: { RandomSelectorDomain() }
    )
    
    Reduce { state, action in
      switch action {
      case .selectTab(let tab):
        state.selectedTab = tab
        return .none
      case .plannerAct:
        return .none
      case .randomSelectorAct:
        return .none
      case .appStarted:
        let draftObjects = RealmService.shared.fetchAllDraftObjects()
        if draftObjects.isEmpty {
          _ = RealmService.shared.createDraftObject(name: "Draft 1")
        }
        return .none
      }
    }
  }
}
