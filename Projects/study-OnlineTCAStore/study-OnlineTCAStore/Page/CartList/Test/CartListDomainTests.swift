//
//  CartListDomainTests.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/25/25.
//


import ComposableArchitecture
import XCTest

@testable import study_OnlineTCAStore

@MainActor
class CartListDomainTests: XCTestCase {
  let cartItemId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
  let cartItemId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
  let itemQuantity = 2
 
  var cartItems: IdentifiedArrayOf<CartItemDomain.State> {
    [
      .init(
        id: cartItemId1,
        cartItem: CartItem.init(
          product: Product.sample[0],
          quantity: itemQuantity
        )
      ),
      .init(
        id: cartItemId2,
        cartItem: CartItem.init(
          product: Product.sample[1],
          quantity: itemQuantity
        )
      ),
    ]
  }
  
  var store: TestStore<CartListDomain.State, CartListDomain.Action>!
  
  override func setUp() {
    store = TestStore(
      initialState: CartListDomain.State(cartItems: cartItems),
      reducer: { CartListDomain() }
    )
  }
  
  func testRemoveItemFromCart() async {
    // 카트 아이템 1을 지우면 카트 아이템 2만 남아야 한다
    await store.send(
      \.cartItem[id: cartItemId1].deleteCartItem,
       Product.sample[0]
    ) { [self] state in
      state.cartItems = [
        .init(
          id: cartItemId2,
          cartItem: .init(
            product: Product.sample[1],
            quantity: itemQuantity
          )
        )
      ]
    }
    
    // 예상 가격: 상품 가격 * 수량
    let expectedPrice = Product.sample[1].price * Double(itemQuantity)
    await store.receive(\.getTotalPrice) {
      $0.totalPrice = expectedPrice
    }
  }

  func testRemoveAllItemsFromCart() async {
    // 1번 상품 삭제
    await store.send(
      \.cartItem[id: cartItemId1].deleteCartItem,
       Product.sample[0]
    ) { [self] state in
      state.cartItems = [
        .init(
          id: cartItemId2,
          cartItem: .init(
            product: Product.sample[1],
            quantity: itemQuantity
          )
        )
      ]
    }
    
    let expectedPrice = Product.sample[1].price * Double(itemQuantity)
    await store.receive(\.getTotalPrice) {
      $0.totalPrice = expectedPrice
    }
    
    // 2번 상품 삭제
    await store.send(
      \.cartItem[id: cartItemId2].deleteCartItem,
       Product.sample[1]
    ) { state in
      state.cartItems = []
    }
    
    await store.receive(\.getTotalPrice) {
      $0.totalPrice = 0
      $0.isPayButtonDisable = true
    }
  }
  
  func testSendOrderSuccessfully() async {
    let store = TestStore(
      initialState: CartListDomain.State(cartItems: cartItems),
      reducer: { CartListDomain() },
      withDependencies: {
        $0.apiClient.sendOrder = { _ in "Send:SUCCESS" }
      }
    )
    
    await store.send(\.didPressPayButton) {
      $0.alert = .confirmationAlert(totalPriceString: "$0.0")
    }
    
    await store.send(\.alert.didConfirmPurchase) {
      $0.alert = nil
      $0.dataLoadingStatus = .loading
    }
    
    await store.receive(\.didReceivePurchaseResponse, .success("Send:SUCCESS")) {
      $0.dataLoadingStatus = .success
      $0.alert = .successAlert
    }
  }
  
  func testSendOrderWithError() async {
    let store = TestStore(
      initialState: CartListDomain.State(cartItems: cartItems),
      reducer: { CartListDomain() },
      withDependencies: {
        $0.apiClient.sendOrder = { _ in throw APIClient.Failure() }
      }
    )
    
    await store.send(\.didPressPayButton) {
      $0.alert = .confirmationAlert(totalPriceString: "$0.0")
    }
    
    await store.send(\.alert.didConfirmPurchase) {
      $0.alert = nil
      $0.dataLoadingStatus = .loading
    }
    
    await store.receive(\.didReceivePurchaseResponse, .failure(APIClient.Failure())) {
      $0.dataLoadingStatus = .error
      $0.alert = .errorAlert
    }
  }
  
}
