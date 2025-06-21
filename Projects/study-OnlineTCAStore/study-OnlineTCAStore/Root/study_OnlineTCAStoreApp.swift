//
//  study_OnlineTCAStoreApp.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/19/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct study_OnlineTCAStoreApp: App {
  var body: some Scene {
    WindowGroup {
      RootView(
        store: Store(
          initialState: RootDomain.State(),
          reducer: { RootDomain() }
        )
      )
    }
  }
}
