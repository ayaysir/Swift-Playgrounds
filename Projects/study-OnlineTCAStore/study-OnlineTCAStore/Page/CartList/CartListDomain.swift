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
    @CasePathable
    enum Alert {
      case didConfirmPurchase
      case didCancelConfirmation
      case dismissSuccessAlert
      case dismissErrorAlert
    }
  }
}

extension AlertState where Action == CartListDomain.Action.Alert {
  
}
