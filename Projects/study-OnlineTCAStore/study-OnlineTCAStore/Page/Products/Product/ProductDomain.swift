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
    /*
     * RootAction.addToCart(하위 액션) 구조를 자동으로 추론하여, 하위 도메인 액션을 연결
     * ProductDomain 리듀서 안에서 아래와 같은 방식으로 AddToCartDomain이 연결돼 있음.
      → AddToCartButton에서 .didTapPlusButton을 보내면 → AddToCartDomain이 count를 증가시킴
      → 이 값이 그대로 ProductDomain.State.addToCartState.count에 반영됨.
     
     AddToCartDomain은 로컬 상태(count)만 관리합니다.
       •  이 상태는 ProductDomain의 하위 상태로 들어있고,
     상위(ProductListDomain)에서 필요한 순간(예: 장바구니 열기 버튼 누를 때) count > 0인 상품만 골라 CartItem으로 변환
     */
    Scope(state: \.addToCartState, action: \.addToCart) {
      AddToCartDomain() // 구조체 AddToCartDomain 초기화
    }
    
    Reduce { state, action in
      switch action {
      case .addToCart(.didTapPlusButton):
        // 나머지는 하위 어쩌구가 할것임
        return .none
      case .addToCart(.didTapMinusButton):
        // 마이너스 1은 AddToCartDomain에서 적용됨
        state.addToCartState.count = max(0, state.addToCartState.count)
        return .none
      }
    }
  }
}
