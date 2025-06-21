//
//  CartItemDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation
import ComposableArchitecture

/*
 @Reducer: 도메인의 상태/액션/리듀서를 하나의 구조체에 묶어 선언
 - 별도로 ReducerProtocol을 채택하거나 body를 구현하지 않아도 됩니다.
 - 내부에 @ObservableState, enum Action, func reduce(...) 등을 작성하면 TCA가 자동으로 리듀서를 생성합니다.
 */

@Reducer
struct CartItemDomain {
  /*
   @ObservableState: SwiftUI에서 상태 바인딩이 가능한 상태 구조체로 만들기 위한 선언,
   - TCA 내부에서 @Bindable을 사용하는 뷰와 연결될 수 있음,
   - Identifiable 채택 → 리스트 등에서 .id로 자동 인식 가능
   */
  
  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID
    // 실제 장바구니 아이템 정보. 예: 제품, 수량, 가격 등
    let cartItem: CartItem
  }
  
  enum Action: Equatable {
    // “카트에서 특정 제품을 삭제”
    case deleteCartItem(product: Product)
  }
  
  // reduce: 액션을 처리할 로직을 구현
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
      // 연관값을 사용하지 않을때 (let product) 생략
    case .deleteCartItem(let product):
      print("삭제 요청: \(product.title)")
      return .none
    }
  }
}
