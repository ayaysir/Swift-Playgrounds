//
//  EtcView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 1/29/26.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
  This screen demonstrates how to use `NavigationStack` with Composable Architecture applications.
  
  이 화면은 구성 가능한 아키텍처 애플리케이션에서 `NavigationStack`을 사용하는 방법을 보여줍니다.
  """

// MARK: - Main
struct EtcView: View {
  @Bindable var store: StoreOf<EtcDomain>
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      // == Root View ==
      Form {
        Section {
          Text(verbatim: readMe)
        }
        
        Section {
          NavigationLink(
            "스크린 A로",
            state: EtcDomain.Path.State.screenA(ScreenADomain.State())
          )
          NavigationLink(
            "스크린 B로",
            state: EtcDomain.Path.State.screenB(ScreenBDomain.State())
          )
          NavigationLink(
            "스크린 C로",
            state: EtcDomain.Path.State.screenC(ScreenCDomain.State())
          )
        }
        
        Section {
          Button("스크린 A -> B -> C로") {
            store.send(.goToABCButtonTapped)
          }
        }
      }
      .navigationTitle("Navigation Root")
    } destination: { store in
      // == Destination ==
      switch store.case {
      case .screenA(let store):
        ScreenAView(store: store)
      case .screenB(let store):
        ScreenBView(store: store)
      case .screenC(let store):
        ScreenCView(store: store)
      }
    }
    .safeAreaInset(edge: .bottom) {
      FloatingMenuView(store: store)
    }
  }
}

// MARK: - View elements (fragments)
extension EtcView {
  
}

// MARK: - View elements (Group)
extension EtcView {
  
}

// MARK: - Init/View related methods/vars
extension EtcView {
  
}

// MARK: - Utility methods
extension EtcView {
  
}

// MARK: - #Preview
#Preview {
  return EtcView(
    store: Store(
      initialState: EtcDomain.State(),
      reducer: { EtcDomain() },
      withDependencies: { dpValues in
        dpValues.factClient.fetch = { number in
          fetchTrivia(factNumber: number)
        }
      }
    )
  )
}

