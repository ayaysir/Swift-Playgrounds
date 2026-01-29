//
//  FloatingMenuView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 1/30/26.
//

import SwiftUI
import ComposableArchitecture

struct FloatingMenuView: View {
  let store: StoreOf<EtcDomain>

  struct ViewState: Equatable {
    struct Screen: Equatable, Identifiable {
      let id: StackElementID
      let name: String
    }

    var currentStack: [Screen]
    var total: Int
    init(state: EtcDomain.State) {
      self.total = 0
      self.currentStack = []
      for (id, element) in zip(state.path.ids, state.path) {
        switch element {
        case let .screenA(screenAState):
          self.total += screenAState.number
          self.currentStack.insert(Screen(id: id, name: "Screen A"), at: 0)
        case .screenB:
          self.currentStack.insert(Screen(id: id, name: "Screen B"), at: 0)
        case let .screenC(screenCState):
          self.total += screenCState.number
          self.currentStack.insert(Screen(id: id, name: "Screen C"), at: 0)
        }
      }
    }
  }

  var body: some View {
    let viewState = ViewState(state: store.state)
    if viewState.currentStack.count > 0 {
      VStack(alignment: .center) {
        Text("Total count: \(viewState.total)")
        Text("")
        Button("Pop to root") {
          store.send(.popToRoot, animation: .default)
        }
        Menu("Current stack") {
          ForEach(viewState.currentStack) { screen in
            Button("\(String(describing: screen.id))) \(screen.name)") {
              store.send(.goBackToScreen(id: screen.id))
            }
            .disabled(screen == viewState.currentStack.first)
          }
          Button("Root") {
            store.send(.popToRoot, animation: .default)
          }
        }
      }
      .padding()
      .background(Color(.systemBackground))
      .padding(.bottom, 1)
      .transition(.opacity.animation(.default))
      // .clipped()
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
    }
  }
}
