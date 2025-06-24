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
  struct State: Equatable {
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
  
  @Dependency(\.apiClient.fetchUserProfile) var fetchUserProfile
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .fetchUserProfile:
      if state.dataState == .complete || state.dataState == .loading {
        return .none
      }
      
      state.dataState = .loading
      // 비동기 작업 실행
      return Effect.run { send in
        // 결과(fetched UserProfile)를 다음 액션(fetchUserProfileResp...success...profile)에 보냄
        await send(.fetchUserProfileResponse(
          TaskResult {
            try await self.fetchUserProfile()
          }
        ))
      }
    case .fetchUserProfileResponse(.success(let profile)):
      // fetchUserProfile에서 fetch 성공한 경우 여기서 처리
      state.dataState = .complete
      state.profile = profile
      return .none
    case .fetchUserProfileResponse(.failure(let error)):
      state.dataState = .complete
      print("fetchUserProfileResponse Error: \(error)")
      return .none
    }
  }
}

