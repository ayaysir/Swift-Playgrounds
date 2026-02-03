//
//  RootDomain.swift
//  TCACaseStudies
//
//  Created by 윤범태 on 2/4/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootDomain {
  enum Tab {
    case alertExample
  }
  @ObservableState
  struct State: Equatable {
    var selectedTab: Tab = .alertExample
    
    // 각 페이지 상태
    var alertExample = AlertExampleDomain.State()
  }
  
  enum Action {
    case tabSelected(Tab)
    
    // 각 페이지에 대한 액션
    case alertExample(AlertExampleDomain.Action)
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .tabSelected(let tab):
        state.selectedTab = tab
        return .none
      case .alertExample:
        return .none
      }
    }
    
    Scope(state: \.alertExample, action: \.alertExample) {
      AlertExampleDomain()
    }
  }
}

