//
//  TCACaseStudiesApp.swift
//  TCACaseStudies
//
//  Created by 윤범태 on 2/3/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCACaseStudiesApp: App {
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
