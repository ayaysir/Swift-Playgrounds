//
//  AlternativeScene.swift
//  SwiftUITutorial
//
//  Created by 윤범태 on 2023/11/11.
//

import SwiftUI

struct AlternativeContentView: View {
    var body: some View {
        EmptyView()
    }
}

// Chapter 1-2
struct AlternativeScene: Scene {
    var body: some Scene {
        WindowGroup {
            AlternativeContentView()
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
