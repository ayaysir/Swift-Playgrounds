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
  var body: some Scene {
    WindowGroup {
      // RootView(
      //   store: Store(
      //     initialState: RootDomain.State(),
      //     reducer: { RootDomain() }
      //   )
      // )
      List {
        ForEach(0..<2) { i in
          Section {
            CourseView(
              store: Store(
                initialState: CourseDomain.State(
                  id: UUID(),
                  course: .samples[i]
                ),
                reducer: { CourseDomain() }
              )
            )
          }
        }
      }
    }
  }
}
