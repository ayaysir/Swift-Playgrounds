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
        ProductListView(
          store: store.scope(
            state: \.productListState, // RootDomain, ProductListDomain.State()
            action: \.productList // RootDomain, productList(ProductListDomain.Action)
          )
        )
        .tabItem {
          Image(systemName: "list.bullet")
          Text("Products")
        }
        .tag(RootDomain.Tab.products)
        
        // // Cannot convert value of type 'KeyPath<RootDomain.State, ProductListDomain.State>'
        // // to expected argument type 'KeyPath<RootDomain.State, ProfileDomain.State>'
        // ProfileView(
        //   store: store.scope(
        //     state: \.productListState,
        //     action: \.productList
        //   )
        // )
        
        ProfileView(
          // 이 도메인(RootView)의 store: StoreOf<RootDomain>
          // 대상 store: StoreOf<ProfileDomain>
          store: store.scope(
            state: \.profileState, // RootDomain.State에 정의됨
            action: \.profile // RootDomain.Action에 정의됨
          )
        )
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
        dependencyValue.apiClient.fetchProducts = { Product.sample }
        dependencyValue.apiClient.sendOrder = { _ in "OK" }
        dependencyValue.apiClient.fetchUserProfile = { UserProfile.sample }
        dependencyValue.uuid = .incrementing
      }
    )
  )
}
