//
//  ScreenC.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 1/30/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ScreenCDomain {
  @ObservableState
  struct State: Equatable {
    var number = 0 // Screen A의 팩트 넘버
    var isTimerRunning = false
  }

  enum Action {
    case startButtonTapped
    case stopButtonTapped
    case timerTick
  }
  
  enum CancelID {
    case timer
  }

  @Dependency(\.mainQueue) var mainQueue

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .startButtonTapped:
        state.isTimerRunning = true
        return .run { send in
          for await _ in self.mainQueue.timer(interval: 1) {
            await send(.timerTick)
          }
        }
        .cancellable(id: CancelID.timer)
        .concatenate(with: .send(.stopButtonTapped))

      case .stopButtonTapped:
        state.isTimerRunning = false
        return .cancel(id: CancelID.timer)

      case .timerTick:
        state.number += 1
        return .none
      }
    }
  }
}

struct ScreenCView: View {
  let store: StoreOf<ScreenCDomain>

  var body: some View {
    Form {
      Text(
        """
        This screen demonstrates that if you start a long-living effects in a stack, then it \
        will automatically be torn down when the screen is dismissed.
        
        이 화면은 스택에서 오래 지속되는 효과(예: 타이머)를 시작하면 화면이 닫힐 때 해당 효과가 자동으로 제거됨을 보여줍니다.
        """
      )
      Section {
        Text("Fact Number: #\(store.number)")
        if store.isTimerRunning {
          Button("Stop timer") { store.send(.stopButtonTapped) }
        } else {
          Button("Start timer") { store.send(.startButtonTapped) }
        }
      }

      Section {
        NavigationLink(
          "Go to screen A",
          state: EtcDomain.Path.State.screenA(ScreenADomain.State(number: store.number))
        )
        NavigationLink(
          "Go to screen B",
          state: EtcDomain.Path.State.screenB(ScreenBDomain.State())
        )
        NavigationLink(
          "Go to screen C",
          state: EtcDomain.Path.State.screenC(ScreenCDomain.State())
        )
      }
    }
    .navigationTitle("Screen C")
  }
}

#Preview {
  ScreenCView(
    store: Store(
      initialState: ScreenCDomain.State(),
      reducer: { ScreenCDomain() }
    )
  )
}
