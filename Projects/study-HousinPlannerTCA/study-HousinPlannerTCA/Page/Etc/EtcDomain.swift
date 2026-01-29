//
//  EtcDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 1/29/26.
//

import Foundation
import ComposableArchitecture

extension EtcDomain.Path.State: Equatable {}

@Reducer
struct EtcDomain {
  @Reducer
  enum Path {
    case screenA(ScreenADomain)
    case screenB(ScreenBDomain)
    case screenC(ScreenCDomain)
  }
  
  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
  }
  
  enum Action {
    case goBackToScreen(id: StackElementID)
    case goToABCButtonTapped
    case path(StackActionOf<Path>)
    case popToRoot
  }
  
  // Enter dependencies if exists...
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .goBackToScreen(let id):
        state.path.pop(to: id)
        return .none
        
      case .goToABCButtonTapped:
        state.path.append(.screenA(ScreenADomain.State()))
        state.path.append(.screenB(ScreenBDomain.State()))
        state.path.append(.screenC(ScreenCDomain.State()))
        return .none
        
      case .path(let action):
        switch action {
        case .element(id: _, action: .screenB(.screenAButtonTapped)):
          state.path.append(.screenA(ScreenADomain.State()))
          return .none
        case .element(id: _, action: .screenB(.screenBButtonTapped)):
          state.path.append(.screenB(ScreenBDomain.State()))
          return .none
        case .element(id: _, action: .screenB(.screenCButtonTapped)):
          state.path.append(.screenC(ScreenCDomain.State()))
          return .none
        default:
          return .none
        }
      case .popToRoot:
        state.path.removeAll()
        return .none
      }
    }
    .forEach(\.path, action: \.path)

    
    // Scopes
    // Scope(state: \.productListState, action: \.productList) { ProductListDomain() }
  }
}

