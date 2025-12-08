//
//  study_HousinPlannerTCAApp.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 9/28/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct study_HousinPlannerTCAApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
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
