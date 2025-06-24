//
//  ProfileView.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//


import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
  let store: StoreOf<ProfileDomain>
  
  var body: some View {
    WithPerceptionTracking {
      NavigationStack {
        ZStack {
          Form {
            Section {
              Text(store.profile.fullName.capitalized)
            } header: {
              Text("Full name")
            }
            
            Section {
              Text(store.profile.email)
            } header: {
              Text("Email")
            }
            
            if store.isLoading {
              ProgressView()
            }
          }
        }
        .task {
          // store.send(.***): fetchUserProfile, fetchUserProfileResponse (from ProfileDomain)
          store.send(.fetchUserProfile) // 유저 프로필 가져와라 (send Action)
        }
        .navigationTitle("Profile")
      }
    }
  }
}

#Preview {
  let store = Store(
    initialState: ProfileDomain.State(),
    reducer: { ProfileDomain() },
    withDependencies: {
      $0.apiClient.fetchUserProfile = { .sample }
    }
  )
  ProfileView(store: store)
}
