//
//  ProductDomainTests.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/25/25.
//

import ComposableArchitecture
import XCTest

@testable import study_OnlineTCAStore

@MainActor
final class ProductDomainTests: XCTestCase {
  let product = Product(
      id: 1,
      title: "Inchon",
      price: 10.5,
      description: "Very good!",
      category: "Wind Orchestra",
      imageString: "image.png"
  )
  
  var store: TestStore<ProductDomain.State, ProductDomain.Action>!
  
  override func setUp() {
    store = TestStore(
      initialState: ProductDomain.State(id: UUID(), product: product),
      reducer: { ProductDomain() }
    )
  }
  
  func testIncreaseProductCounterTappingPlusButtonOnce() async {
    // 플러스 버튼을 한 번 눌렀을 때 counter가 1 증가해야 함
    await store.send(\.addToCart.didTapPlusButton) { state in
      state.addToCartState = AddToCartDomain.State(count: 1)
    }
  }
  
  func testIncreaseProductCounterTappingPlusButtonThreeTimes() async {
    // 플러스 버튼을 세 번 눌렀을 때 counter가 1, 2, 3 이렇게 증가해야 함
    await store.send(\.addToCart.didTapPlusButton) {
      $0.addToCartState = AddToCartDomain.State(count: 1)
    }
    
    await store.send(\.addToCart.didTapPlusButton) {
      $0.addToCartState = AddToCartDomain.State(count: 2)
    }
    
    await store.send(\.addToCart.didTapPlusButton) {
      $0.addToCartState = AddToCartDomain.State(count: 3)
    }
  }
  
  func testIncreaseProductCounterTappingMinusButtonOnce() async {
    await store.send(\.addToCart.didTapMinusButton) // 상태 변화 없어야 함
  }
  
  func testIncreaseProductCounterTappingMinusButtonThreeTimes() async {
    await store.send(\.addToCart.didTapMinusButton)
    await store.send(\.addToCart.didTapMinusButton)
    await store.send(\.addToCart.didTapMinusButton)
  }
  
  func testIncreaseProductCounterTappingMinusTwoTimesAndPlusOnce() async {
    await store.send(\.addToCart.didTapMinusButton)
    await store.send(\.addToCart.didTapMinusButton)
    
    await store.send(\.addToCart.didTapPlusButton) {
      $0.addToCartState = AddToCartDomain.State(count: 1)
    }
  }
  
  func testIncreaseProductCounterTappingPlusTwoTimesAndMinusOnce() async {
    await store.send(\.addToCart.didTapPlusButton) {
      $0.addToCartState = AddToCartDomain.State(count: 1)
    }
    
    await store.send(\.addToCart.didTapPlusButton) {
      $0.addToCartState = AddToCartDomain.State(count: 2)
    }
    
    await store.send(\.addToCart.didTapMinusButton) {
      $0.addToCartState = AddToCartDomain.State(count: 1)
    }
  }
}
