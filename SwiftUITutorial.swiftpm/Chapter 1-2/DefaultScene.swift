//
//  DefaultSceneScene.swift
//  SwiftUITutorial
//
//  Created by 윤범태 on 2023/11/11.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        EmptyView()
    }
}

struct DefaultScene: Scene {
    var body: some Scene {
        // Chapter 1-2
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Journal", systemImage: "book")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
