//
//  study_BackgroundTasksApp.swift
//  study-BackgroundTasks
//
//  Created by 윤범태 on 9/30/24.
//

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct study_BackgroundTasksApp: App {
  
  // SwiftUI에서는 App에서 태스크를 등록
  @Environment(\.scenePhase) var scenePhase
  
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
    .onChange(of: scenePhase) {
      if scenePhase == .background {
        
      }
    }
    // iOS 17 이상
    .backgroundTask(.appRefresh("com.example.refresh")) { task in
      print("BackgroundTask execute: \(Date.now)")
    }
  }
}
