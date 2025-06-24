//
//  CartListView.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//


import SwiftUI
import ComposableArchitecture

struct CartListView: View {
  let store: StoreOf<CartListDomain>
  
  var body: some View {
    WithPerceptionTracking {
      ZStack {
        NavigationStack {
          Group {
            if store.cartItems.isEmpty {
              Text("Oops, your cart is empty! \n")
                  .font(.custom("AmericanTypewriter", size: 25))
            } else {
              CartListArea
            }
          }
        }
        .alert(
          store: store.scope(
            // $: @PresentationState에 바인딩된 상태를 참조
            // => @PresentationState var alert: AlertState<Action.Alert>?를 프로퍼티 래퍼로 감싼 채로 접근
            // @PresentationState는 TCA 1.3+에서 alert, sheet, fullScreenCover 같은 뷰 전환 상태를 표현하기 위한 속성 래퍼
            // 내부적으로는 옵셔널 상태 (AlertState?)
            // \.$alert는 KeyPath<State, PresentationState<AlertState<...>>?>를 의미
            // TCA에서 PresentationState를 쓸 때:
            // - View에서 .alert(store:)를 사용하려면
            // - 내부적으로 alert 상태가 presentation lifecycle과 연결되어야 하고
            // - 이를 위해 “presentation용 KeyPath”, 즉 \.$alert가 필요합니다
            state: \.$alert,
            action: \.alert
          )
        )
        .navigationTitle("Cart")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              store.send(.didPressCloseButton)
            } label: {
              Text("Close")
            }
          }
        }
        .onAppear {
          store.send(.getTotalPrice)
        }
      }
      if store.isRequestInProcess {
        Color.black
          .opacity(0.2)
          .ignoresSafeArea()
        ProgressView()
      }
    }
  }
}

extension CartListView {
  private var CartListArea: some View {
    List {
      // let scope = store.scope(state: \.cartItems, action: \.cartItem)
      // ForEach(scope, id: \.id) { store in // 왜 이건 안됨?
      // => 이 표현은 내부적으로 ForEachStore DSL과 동일하게 동작함, ForEach에 특화된 overload가 존재하기 때문에 작동함
      ForEach(store.scope(state: \.cartItems, action: \.cartItem), id: \.id) { store in // 이건 되는데
        CartCell(store: store)
      }
    }
    // safeAreaInset(edge:content:)는 safe area 안쪽에 추가 UI를 삽입하는 데 사용하는 뷰 수정자(modifier)입니다.
    // 특정 edge(예: .bottom, .top, .leading, .trailing)의 safe area 안에 공간을 추가하고, 그 공간에 콘텐츠를 삽입합니다.
    // 이 버튼을 화면 하단 safe area 내부에 고정해서 띄워라, 스크롤 가능한 List가 위에 있어도, 이 버튼은 항상 아래에 고정됨
    .safeAreaInset(edge: .bottom) {
      Button {
        store.send(.didPressPayButton)
      } label: {
        HStack(alignment: .center) {
          Spacer()
          Text("Pay \(store.totalPriceString)")
            .font(.custom("AmericanTypewriter", size: 30))
            .foregroundColor(.white)
          Spacer()
        }
      }
      .frame(maxWidth: .infinity, minHeight: 60)
      .background(store.isPayButtonDisable ? Color.gray : Color.teal)
      .clipShape(.buttonBorder)
      .padding()
      .disabled(store.isPayButtonDisable)
    }
  }
}

#Preview {
  let store = Store(
    initialState: CartListDomain.State(
      cartItems: IdentifiedArrayOf(uniqueElements: CartItem.sample.map {
        CartItemDomain.State(id: UUID(), cartItem: $0)
      })
    ),
    reducer: { CartListDomain() },
    withDependencies: {
      $0.apiClient.sendOrder = { _ in "OK"}
    }
  )
  CartListView(store: store)
}
