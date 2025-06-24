//
//  ProductListView.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//


import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
  @Bindable var store: StoreOf<ProductListDomain>
  
  var body: some View {
    // WithPerceptionTracking: 뷰 상태 추적기 (@Bindable store 사용)
    WithPerceptionTracking {
      NavigationStack {
        Group {
          if store.isLoading {
            ProgressView()
              .frame(width: 100, height: 100)
          } else if store.shouldShowError {
            ErrorView(
              message: "Oops, we couldn't fetch product list",
              retryAction: { store.send(.fetchProducts) }
            )
          } else {
            ProductListArea
          }
        }
        .task { store.send(.fetchProducts) }
        .navigationTitle("Products")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              store.send(.setCartView(isPresented: true)) // ProductListDomain.Action에 있음
            } label: {
              Text("Go to Cart")
            }
          }
        }
        .sheet(item: $store.scope(state: \.cartState, action: \.cart)) { store in
          CartListView(store: store)
        }
      }
    }
  }
}

extension ProductListView {
  private var ProductListArea: some View {
    WithPerceptionTracking {
      List {
        ForEach(
          store.scope(
            state: \.productList,
            action: \.product
          ),
          id: \.id
        ) { store in
          ProductCell(store: store)
            .id(store.id)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    ProductListView(
      store: Store(
        initialState: ProductListDomain.State(),
        reducer: {
          ProductListDomain()
        },
        withDependencies: { dependencyValues in
          // 이부분에서 별도로 지정하지 않으면 실제 네트워크에서 자료를 가져온다
          dependencyValues.apiClient.fetchProducts = { Product.sample }
          dependencyValues.apiClient.sendOrder = { _ in "OK" }
        }
      )
    )
  }
}
