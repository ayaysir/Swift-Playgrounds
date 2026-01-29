//
//  ScreenB.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 1/30/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ScreenBDomain {
  @ObservableState
  struct State: Equatable {
    
  }
  
  enum Action: Equatable {
    case screenAButtonTapped
    case screenBButtonTapped
    case screenCButtonTapped
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      return .none
    }
  }
}

struct ScreenBView: View {
  let store: StoreOf<ScreenBDomain>

  var body: some View {
    Form {
      Section {
        Text(
          """
          This screen demonstrates how to navigate to other screens without needing to compile \
          any symbols from those screens. You can send an action into the system, and allow the \
          root feature to intercept that action and push the next feature onto the stack.
          
          이 화면은 다른 화면으로 이동할 때 해당 화면의 심볼을 컴파일할 필요 없이 이동하는 방법을 보여줍니다.
          시스템에 액션을 전송하고 루트 기능이 해당 액션을 가로채서 다음 기능을 스택에 푸시하도록 할 수 있습니다.
          """
        )
      }
      Button("Decoupled navigation to screen A\n화면 A로 이동하는 분리형 탐색") {
        store.send(.screenAButtonTapped)
      }
      Button("Decoupled navigation to screen B\n화면 B로 이동하는 분리형 탐색") {
        store.send(.screenBButtonTapped)
      }
      Button("Decoupled navigation to screen C\n화면 C로 이동하는 분리형 탐색") {
        store.send(.screenCButtonTapped)
      }
    }
    .navigationTitle("Screen B")
  }
}

