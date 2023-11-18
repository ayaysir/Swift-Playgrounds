//
//  ChildView.swift
//  iOSAppDevTutorials
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI

struct ChildView: View {
    /*
     Use the @ObservedObject property wrapper to indicate that a view received an object from a parent source, such as the app, a scene, or a view. This parent structure creates and owns the object, so the child view doesn’t need an initial value for an ObservedObject:
     */
    @ObservedObject var scrumTimer: ScrumTimerExample
    
    var body: some View {
        GrandChildView()
            .environmentObject(scrumTimer)
    }
}

struct GrandChildView: View {
    @EnvironmentObject var timer: ScrumTimerExample
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    ChildView(scrumTimer: .init())
}
