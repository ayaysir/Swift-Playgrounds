//
//  AddToCartDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//


import Foundation
import ComposableArchitecture

@Reducer
struct AddToCartDomain {
  @ObservableState
  struct State: Equatable {
    var count = 0
  }
  
  enum Action: Equatable {
    case didTapPlusButton
    case didTapMinusButton
  }
}
