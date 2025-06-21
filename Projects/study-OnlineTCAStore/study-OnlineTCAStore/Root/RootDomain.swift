//
//  RootDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootDomain {
  @ObservableState
  struct State: Equatable {
    var selectedTab = Tab.products
    var productListState = ProductListDomain.State()
    // var profileState = ProfileDomain.State()
  }
  
  enum Tab {
    case products
    case profile
  }
  
  enum Action: Equatable {
    case tabSelected(Tab)
    case productList(ProductListDomain.Action)
    // case profile(ProfileDomain.Action)
  }
}
