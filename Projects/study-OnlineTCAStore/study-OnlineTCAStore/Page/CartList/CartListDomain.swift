//
//  CartListDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CartListDomain {
  @ObservableState
  struct State: Equatable {
    //  Alert도 상태로 관리합니다:
    //  @PresentationState는 TCA 1.3+에서 alert, sheet, fullScreenCover 같은 뷰 전환 상태를 표현하기 위한 속성 래퍼
    @Presents var alert: AlertState<Action.Alert>?
    
    var dataLoadingStatus = DataLoadingStatus.notStarted
    var cartItems: IdentifiedArrayOf<CartItemDomain.State> = []
    var totalPrice: Double = 0.0
    var isPayButtonDisable = false
    
    var totalPriceString: String {
      let roundedValue = round(totalPrice * 100) / 100.0
      return "$\(roundedValue)"
    }
    
    var isRequestInProcess: Bool {
      dataLoadingStatus == .loading
    }
  }
  
  enum Action: Equatable {
    case didPressCloseButton
    // IdentifiedActionOf는 TCA에서 IdentifiedArray로 관리되는 하위 도메인에 대한 액션을 전달할 때 사용하는 타입입니다.
    // 배열로 관리되는 여러 개의 하위 상태 중에서 “어떤 ID를 가진 도메인의 액션인지 명시”할 수 있게 해주는 래퍼입니다.
    /*
     var cartItems: IdentifiedArrayOf<CartItemDomain.State>
     enum Action {
       case cartItem(id: UUID, action: CartItemDomain.Action)
     }
     
     =>
     
     case cartItem(IdentifiedActionOf<CartItemDomain>)
     */
    case cartItem(IdentifiedActionOf<CartItemDomain>)
    case getTotalPrice
    case didPressPayButton
    case didReceivePurchaseResponse(TaskResult<String>)
    
    // MARK: - Alert Action
    
    // PresentationAction은 알림(alert) 등 일시적 상태를 처리할 때 쓰는 구조
    // SwiftUI의 .alert(...)과 연동될 수 있음
    case alert(PresentationAction<Alert>)
    
    @CasePathable
    enum Alert {
      case didConfirmPurchase
      case didCancelConfirmation
      case dismissSuccessAlert
      case dismissErrorAlert
    }
  }
  
  @Dependency(\.apiClient.sendOrder) var sendOrder
  
  private func verifyPayButtonVisibility(state: inout State) -> Effect<Action> {
    state.isPayButtonDisable = state.totalPrice == 0.0
    return .none
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        // case .alert(.presented(let alertAction)): 와 동일
        // case let .alert(.presented(alertAction)):
      case .alert(.presented(let alertAction)):
        return switchAlertAction(state: &state, alertAction: alertAction)
        
      case .alert:
        return .none
        
      case .didPressCloseButton:
        return .none
        
        // case let .cartItem(.element(id: id, action: action)):와 동일
      case .cartItem(.element(id: let id, action: let action)):
        return switchCartItemAction(
          state: &state,
          cartItemId: id,
          cartItemAction: action
        )
        
      case .getTotalPrice:
        // state.cartItems 배열의 각 요소에서 "cartItem이라는 속성만 추출"해서 새 배열을 만든다
        // state.cartItems.map { $0.cartItem } 와 동일
        let items = state.cartItems.map(\.cartItem)
        state.totalPrice = items.reduce(0.0) { partialResult, cartItem in
          partialResult + (cartItem.product.price * Double(cartItem.quantity))
        }
        return verifyPayButtonVisibility(state: &state)
        
      case .didPressPayButton:
        state.alert = .confirmationAlert(totalPriceString: state.totalPriceString)
        return .none
        
      case .didReceivePurchaseResponse(.success(let message)):
        state.dataLoadingStatus = .success
        state.alert = .successAlert
        print("didReceivePurchaseResponse: Success:", message)
        return .none
        
      case .didReceivePurchaseResponse(.failure(let error)):
        state.dataLoadingStatus = .error
        state.alert = .errorAlert
        print("[didReceivePurchaseResponse] Error sending your order:", error.localizedDescription)
        return .none
      }
    }
    // ifLet: 옵셔널 상태(alert)r가 존재할 떄만 하위 리듀서를 활성화
    // 상태에 선언된 @PresentationState var alert: AlertState<Action.Alert>? (optional state)에 대응
    // alert가 nil이 아니면 Alert 관련 액션을 처리할 수 있도록 연결
    // 앞은 state의 $alert, 뒤는 action의 alert
    .ifLet(\.$alert, action: \.alert)
    // CartItemDomain 리듀서가 각 아이템에 대한 액션을 처리할수 있게 함
    // 전자는 state의 배열, 후자는 액션에 정의됨
    // 장바구니 항목들 각각에 하위 리듀서(CartItemDomain()) 연결
    .forEach(\.cartItems, action: \.cartItem) {
      CartItemDomain()
    }
  }
  
  private func switchAlertAction(
    state: inout Self.State,
    alertAction: Action.Alert
  ) -> Effect<Action> {
    switch alertAction {
    case .didConfirmPurchase:
      state.dataLoadingStatus = .loading
      let items = state.cartItems.map { $0.cartItem }
      return .run { send in
        let taskResult = await TaskResult {
          try await sendOrder(items)
        }
        await send(.didReceivePurchaseResponse(taskResult))
      }
    case .didCancelConfirmation, .dismissSuccessAlert, .dismissErrorAlert:
      state.alert = nil
      return .none
    }
  }
  
  private func switchCartItemAction(
    state: inout Self.State,
    cartItemId: UUID,
    cartItemAction: CartItemDomain.Action
  ) -> Effect<Action> {
    switch cartItemAction {
    case .deleteCartItem:
      state.cartItems.remove(id: cartItemId)
      // 삭제 후 총합을 다시 계산하라는 액션(getTotalPrice 액션)을 리턴
      return .send(.getTotalPrice)
    }
  }
}

// `Action` 타입이 `CartListDomain.Action.Alert`인 경우
extension AlertState where Action == CartListDomain.Action.Alert {
  /*
   이렇게 정의된 AlertState는 View에서 다음처럼 바인딩됩니다:
   .alert(store: store.scope(state: \.alert, action: \.alert))
   
   ✅ 버튼 누르면 액션 흐름
     1.  버튼 누름
     2.  alert(.presented(.didConfirm)) 액션 발생
     3.  switch action에서 .alert(.presented(.didConfirm)) 처리
     4.  후속 로직 실행
   */
  static func confirmationAlert(totalPriceString: String) -> AlertState {
    AlertState {
      TextState("Confirm your purchase")
    } actions: {
      ButtonState(action: .didConfirmPurchase) {
        TextState("Pay \(totalPriceString)")
      }
      ButtonState(role: .cancel, action: .didCancelConfirmation) {
        TextState("Cancel")
      }
    } message: {
      TextState("Do you want to proceed with your purchase of \(totalPriceString)?")
    }
  }
  
  static var successAlert: AlertState {
    AlertState {
      TextState("Thank you!")
    } actions: {
      ButtonState(action: .dismissSuccessAlert)  {
        TextState("Done")
      }
    } message: {
      TextState("Your order is in process.")
    }
  }
  
  static var errorAlert: AlertState {
    AlertState {
      TextState("Oops!")
    } actions: {
      ButtonState(action: .dismissSuccessAlert)  {
        TextState("Done")
      }
    } message: {
      TextState("Unable to send order, try again later.")
    }
  }
}
