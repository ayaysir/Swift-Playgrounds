//
//  ProductDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProductDomain {
  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID
    let product: Product
    var addToCartState = AddToCartDomain.State()
    
    // 예) viewStore.count += 1
    // 실제로는 addToCartState.count += 1 와 동일
    var count: Int {
      get { addToCartState.count }
      set { addToCartState.count = newValue }
    }
  }
  
  enum Action: Equatable {
    case addToCart(AddToCartDomain.Action)
  }
  
  // ReducerOf<Self>는 Reducer<State, Action>과 같으며,
  // 자신(Self)의 상태와 액션을 처리하는 리듀서를 의미합니다.
  // 즉, 이 도메인의 리듀서 구현 본체임을 나타냅니다.
  var body: some ReducerOf<Self> {
    // RootAction.addToCart(하위 액션) 구조를 자동으로 추론하여, 하위 도메인 액션을 연결
    Scope(state: \.addToCartState, action: \.addToCart) {
      AddToCartDomain() // 구조체 AddToCartDomain 초기화
    }
    
    Reduce { state, action in
      switch action {
      case .addToCart(.didTapPlusButton):
        return .none
      case .addToCart(.didTapMinusButton):
        return .none
      }
    }
  }
}
