//
//  ProductListDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProductListDomain {
  @ObservableState
  struct State: Equatable {
    var dataLoadingStatus = DataLoadingStatus.notStarted
    @Presents var cartState: CartListDomain.State?
    var productList: IdentifiedArrayOf<ProductDomain.State> = []
    
    var shouldShowError: Bool {
      dataLoadingStatus == .error
    }
    
    var isLoading: Bool {
      dataLoadingStatus == .loading
    }
  }
}
