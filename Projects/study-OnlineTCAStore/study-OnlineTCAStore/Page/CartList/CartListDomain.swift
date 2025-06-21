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
    // ...
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
