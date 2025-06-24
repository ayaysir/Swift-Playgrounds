//
//  ProfileDomain.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileDomain {
  @ObservableState
  struct state: Equatable {
    var profile: UserProfile = .default
    fileprivate var dataState = DataState.notStarted
    var isLoading: Bool {
      dataState == .loading
    }
  }
  
  fileprivate enum DataState {
    case notStarted
    case loading
    case complete
  }
  
  enum Action: Equatable {
    case fetchUserProfile
    case fetchUserProfileResponse(TaskResult<UserProfile>) // TaskResult is deprecated.
    // case fetchUserProfileResponse(Result<UserProfile, Never>)
  }
  
  // func reduce(into state: inout State, action: Action) -> Effect<Action> {
  //   switch action {
  //   case .fetchUserProfile:
  //     if state.dataState == .complete || state.dataState == DataState.loading {
  //       return .none
  //     }
  //     
  //     state.dataState == .loading
  //   case .fetchUserProfileResponse(let result):
  //     return .none
  //   }
  // }
}

