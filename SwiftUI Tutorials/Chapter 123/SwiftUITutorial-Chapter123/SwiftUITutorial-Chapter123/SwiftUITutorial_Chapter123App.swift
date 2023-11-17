//
//  SwiftUITutorial_Chapter123App.swift
//  SwiftUITutorial-Chapter123
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI

@main
struct SwiftUITutorial_Chapter123App: App {
    @State private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Image(systemName: "snowflake")
                        Text("Chapter 1")
                    }
                LandmarkList()
                    .environment(modelData)
                    .tabItem {
                        Image(systemName: "fanblade")
                    }
            }
        }
    }
}
