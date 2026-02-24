//
//  AlertExampleDomain.swift
//  TCACaseStudies
//
//  Created by 윤범태 on 2/4/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AlertExampleDomain {
  @ObservableState
  struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
  }
  
  enum Action {
    case alertButtonTapped
    // PresentationAction은 알림(alert) 등 일시적 상태를 처리할 때 쓰는 구조
    case alert(PresentationAction<Alert>)
    
    @CasePathable
    enum Alert {
      case dismissAlert
      case confirmAlert
    }
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .alertButtonTapped:
        state.alert = AlertState(title: {
          TextState("얼럿 제목")
        }, actions: {
          ButtonState(role: .cancel, action: .dismissAlert) {
            TextState("취소")
          }
          ButtonState(role: .destructive, action: .confirmAlert) {
            TextState("처리")
          }
        }, message: {
          TextState("물건을 구매하시겠습니까?")
        })
        return .none
        
      case .alert(.presented(let alertAction)):
        switch alertAction {
        case .dismissAlert:
          state.alert = nil
          return .none
        case .confirmAlert:
          state.alert = AlertState(title: { TextState("구매 완료되었습니다.") })
          return .none
        }
        
      case .alert:
        return .none
      
      }
    }
    .ifLet(\.alert, action: \.alert)
  }
}

