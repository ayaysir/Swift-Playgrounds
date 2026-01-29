//
//  ScreenA.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 1/29/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ScreenADomain {
  @ObservableState
  struct State: Equatable {
    var number = 0
    var fact: String?
    var isLoading = false
  }
  
  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
    case dismissButtonTapped
    case factButtonTapped
    case factResponse(Result<String, any Error>)
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.factClient) var factClient
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.number -= 1
        return .none
        
      case .incrementButtonTapped:
        state.number += 1
        return .none
        
      case .dismissButtonTapped:
        return .run { _ in
          await self.dismiss()
        }
        
      case .factButtonTapped:
        state.isLoading = true
        return .run { [count = state.number] send in
          await send(.factResponse(Result {
            try await self.factClient.fetch(count)
          }))
        }
        
      case .factResponse(.success(let fact)):
        state.isLoading = false
        state.fact = fact
        return .none
        
      case .factResponse(.failure):
        state.isLoading = false
        state.fact = nil
        return .none
      }
    }
  }
}

struct ScreenAView: View {
  let store: StoreOf<ScreenADomain>

  var body: some View {
    Form {
      Text(
        """
        This screen demonstrates a basic feature hosted in a navigation stack.
        
        이 화면은 내비게이션 스택에 호스팅된 기본 기능을 보여줍니다.

        You can also have the child feature dismiss itself, which will communicate back to the \
        root stack view to pop the feature off the stack.
        
        자식 기능이 스스로 닫히도록 설정할 수도 있으며, 이 경우 루트 스택 뷰에 해당 기능을 스택에서 제거하라는 신호가 전달됩니다.
        """
      )

      Section {
        HStack {
          Text("Fact Number: #\(store.number)")
          Spacer()
          Button {
            store.send(.decrementButtonTapped)
          } label: {
            Image(systemName: "minus")
          }
          Button {
            store.send(.incrementButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
        .buttonStyle(.borderless)

        Button {
          store.send(.factButtonTapped)
        } label: {
          HStack {
            Text("Get fact")
            if store.isLoading {
              Spacer()
              ProgressView()
            }
          }
        }

        if let fact = store.fact {
          Text(fact)
        }
      }

      Section {
        Button("Dismiss") {
          store.send(.dismissButtonTapped)
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
          state: EtcDomain.Path.State.screenC(ScreenCDomain.State(number: store.number))
        )
      }
    }
    .navigationTitle("Screen A")
  }
}

#Preview {
  ScreenAView(
    store: Store(
      initialState: ScreenADomain.State(),
      reducer: { ScreenADomain() },
      withDependencies: { dependencyValues in
        dependencyValues.factClient.fetch = { "Test #\($0)" }
      }
    )
  )
}
