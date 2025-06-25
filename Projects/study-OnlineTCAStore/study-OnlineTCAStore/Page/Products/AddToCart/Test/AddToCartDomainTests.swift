//
//  AddToCartDomainTests.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/25/25.
//

import ComposableArchitecture
import XCTest

@testable import study_OnlineTCAStore

@MainActor
class AddToCartDomainTests: XCTestCase {
  var store: TestStore<AddToCartDomain.State, AddToCartDomain.Action>!
  
  override func setUp() {
    store = TestStore(
      initialState: AddToCartDomain.State(),
      reducer: { AddToCartDomain() }
    )
  }
  
  func testIncreaseCounterTappingPlusButtonOnce() async {
    await store.send(\.didTapPlusButton) {
      $0.count = 1
    }
  }
  
  func testIncreaseCounterTappingPlusButtonThreeTimes() async {
    await store.send(\.didTapPlusButton) { $0.count = 1 }
    await store.send(\.didTapPlusButton) { $0.count = 2 }
    await store.send(\.didTapPlusButton) { $0.count = 3 }
  }
  
  func testDecreaseCounterTappingPlusButtonOnce() async {
    // Minus를 방지하는 로직은 ProductDomain에 들어가 있으며
    // AddToCartDomain에는 적용되지 않았으므로 -값이 나와야 함
    await store.send(\.didTapMinusButton) {
      $0.count = -1
    }
  }
  
  func testDecreaseCounterTappingPlusButtonThreeTimes() async {
    await store.send(\.didTapMinusButton) { $0.count = -1 }
    await store.send(\.didTapMinusButton) { $0.count = -2 }
    await store.send(\.didTapMinusButton) { $0.count = -3 }
  }
  
  func testUpdatingCounterTappingPlusAndMinusButtons() async {
    await store.send(\.didTapMinusButton) { $0.count = -1 }
    await store.send(\.didTapPlusButton) { $0.count = 0 }
    await store.send(\.didTapMinusButton) { $0.count = -1 }
  }
}
