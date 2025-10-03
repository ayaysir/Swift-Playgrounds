//
//  RootView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
  @Bindable var store: StoreOf<RootDomain>
  
  var body: some View {
    // 'WithPerceptionTracking' was deprecated in iOS 17: 'WithPerceptionTracking' is no longer needed in iOS 17+.
    
    TabView(selection: $store.selectedTab.sending(\.selectTab)) {
      PlannerView(
        store: store.scope(
          state: \.plannerSt,
          action: \.plannerAct
        )
      )
      .tabItem {
        Label("Planner", systemImage: "list.bullet.indent")
      }
      .tag(RootDomain.Tab.planner)

      Text("ETC")
        .tabItem {
          Label("etc", systemImage: "info.circle")
        }
        .tag(RootDomain.Tab.etc)
    }
    .onAppear {
      store.send(.appStarted)
    }
  }
}

#Preview {
  RootView(
    store: Store(
      initialState: RootDomain.State(),
      reducer: { RootDomain() },
      withDependencies: { dependencyValue in
        
      }
    )
  )
}
