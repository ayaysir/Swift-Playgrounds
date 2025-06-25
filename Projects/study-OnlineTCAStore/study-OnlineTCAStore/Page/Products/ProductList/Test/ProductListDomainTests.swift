//
//  ProductListDomainTests.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/25/25.
//

import ComposableArchitecture
import XCTest

@testable import study_OnlineTCAStore

@MainActor
class ProductListDomainTests: XCTestCase {
  private let products: [Product] = [
    .init(
      id: 1,
      title: "Inchon",
      price: 10.5,
      description: "Very good!",
      category: "Wind Orchestra",
      imageString: "image.png"
    ),
    .init(
      id: 1,
      title: "Summon the Heroes",
      price: 10.5,
      description: "Very good!",
      category: "Full Orchestra",
      imageString: "image2.png"
    ),
  ]
  
  private let productId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
  private let productId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
  
  override func setUp() async throws {
    UUID.uuIdTestCounter = 0
  }
  
  func testFetchProductsSuccess() async {
    let store = TestStore(
      initialState: ProductListDomain.State(),
      reducer: { ProductListDomain() }
    ) {
      $0.apiClient.fetchProducts = { self.products }
      $0.uuid = .incrementing
    }
    
    let identifiedArray = IdentifiedArrayOf(uniqueElements: [
      ProductDomain.State(id: productId1, product: products[0]),
      ProductDomain.State(id: productId2, product: products[1])
    ])
    
    await store.send(\.fetchProducts) {
      $0.dataLoadingStatus = .loading
    }
    
    await store.receive(\.fetchProductsResponse, .success(products)) {
      $0.productList = identifiedArray
      $0.dataLoadingStatus = .success
    }
  }
  
  func testFetchProductsFailure() async {
    let error = APIClient.Failure()
    let store = TestStore(
      initialState: ProductListDomain.State(),
      reducer: { ProductListDomain() }
    ) {
      $0.apiClient.fetchProducts = { throw error }
      $0.uuid = .incrementing
    }
    
    await store.send(\.fetchProducts) {
      $0.dataLoadingStatus = .loading
    }
    
    await store.receive(\.fetchProductsResponse, .failure(error)) {
      $0.productList = []
      $0.dataLoadingStatus = .error
    }
  }
  
  func testResetProductsToZeroAfterPayingOrder() async {
    let identifiedProducts = IdentifiedArrayOf(uniqueElements: [
      ProductDomain.State(id: productId1, product: products[0]),
      ProductDomain.State(id: productId2, product: products[1])
    ])
    
    let store = TestStore(
      initialState: ProductListDomain.State(productList: identifiedProducts),
      reducer: { ProductListDomain() }
    ) {
      $0.uuid = .incrementing
    }

    // 상품 1에 대해 plus 버튼을 누르면
    await store.send(\.product[id: productId1].addToCart.didTapPlusButton) { [self] in
      $0.productList[id: productId1]?.addToCartState.count = 1
    }
    
    await store.send(\.product[id: productId1].addToCart.didTapPlusButton) { [self] in
      $0.productList[id: productId1]?.addToCartState.count = 2
    }
    
    let expectedCartItems = [
      CartItemDomain.State(
        id: productId1,
        cartItem: CartItem(
          product: products.first!,
          quantity: 2
        )
      )
    ]
    let expectedCartState = CartListDomain.State(
      cartItems: IdentifiedArrayOf(uniqueElements: expectedCartItems)
    )
    
    await store.send(\.setCartView, true) { // true: isPresented
      $0.cartState = expectedCartState
    }
  }
  
  func testItemRemovedFromCart() async {
    // 장바구니에서 상품을 제거했을 때, 상태가 올바르게 초기화되는지 확인하는 유닛 테스트
    
    let numberOfItems = 2
    
    let identifiedProducts = IdentifiedArrayOf(
      uniqueElements: [
        ProductDomain.State(
          id: productId1,
          product: products[0],
          addToCartState: AddToCartDomain.State(count: numberOfItems)
        ),
        // This item should not be added: count = 0
        ProductDomain.State(
          id: productId2,
          product: products[1],
          addToCartState: AddToCartDomain.State(count: 0)
        ),
      ]
    )
    
    let store = TestStore(
        initialState: ProductListDomain.State(productList: identifiedProducts),
        reducer: { ProductListDomain() }
    ) {
        $0.uuid = .incrementing
    }
    
    let expectedCartItems = [
      CartItemDomain.State(
        id: productId1,
        cartItem: CartItem(
          product: products.first!,
          quantity: numberOfItems
        )
      )
    ]
    let expectedCartState = CartListDomain.State(
      cartItems: IdentifiedArray(
        uniqueElements: expectedCartItems
      )
    )
    
    // cartView를 true로 열면서, count > 0인 상품만 장바구니 항목으로 변환됨
    await store.send(\.setCartView, true) {
      $0.cartState = expectedCartState
    }
    
    // 장바구니에서 해당 상품 제거
    let element: IdentifiedActionOf<CartItemDomain> = .element(
      id: productId1,
      action: .deleteCartItem(product: products[0])
    )
    let cartItem: CartListDomain.Action = .cartItem(element)
    let presented: PresentationAction<CartListDomain.Action> = .presented(cartItem)
    await store.send(.cart(presented)) {
      $0.cartState?.cartItems = []
    }
    
    // 총 가격이 0으로 갱신되고 버튼 비활성화
    await store.receive(\.cart.getTotalPrice) {
      $0.cartState?.totalPrice = 0
      $0.cartState?.isPayButtonDisable = true
    }
    
    // productList의 해당 상품 count가 0으로 리셋됨
    await store.receive(\.resetProduct, products[0]) { [self] in
      $0.productList = identifiedProducts
      $0.productList[id: productId1]?.count = 0
    }
  }
}

extension UUID {
  // uuIdTestCounter needs to be set to 0 on setUp() method
  static var uuIdTestCounter: UInt = 0
  
  static var newUUIDForTest: UUID {
    defer {
      uuIdTestCounter += 1
    }
    return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuIdTestCounter))")!
  }
}
