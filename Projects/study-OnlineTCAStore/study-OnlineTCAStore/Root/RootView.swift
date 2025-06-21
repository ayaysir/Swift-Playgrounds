//
//  RootView.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
  // 구버전 문법
  // @Perception.Bindable var store: StoreOf<RootDomain>
  
  @Bindable var store: StoreOf<RootDomain>
  
  var body: some View {
    WithPerceptionTracking {
      TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
        Text("ProductListView")
          .tabItem {
            Image(systemName: "list.bullet")
            Text("Products")
          }
          .tag(RootDomain.Tab.products)
        
        Text("ProfileView")
          .tabItem {
            Image(systemName: "person.fill")
            Text("Profile")
          }
          .tag(RootDomain.Tab.profile)
      }
    }
  }
}

#Preview {
  RootView(
    store: Store(
      initialState: RootDomain.State(),
      reducer: { RootDomain() },
      withDependencies: { dependencyValue in
        // apiClient, uuid, etc.
      }
    )
  )
}
