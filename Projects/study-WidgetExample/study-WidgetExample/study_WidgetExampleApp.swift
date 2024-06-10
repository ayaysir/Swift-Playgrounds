//
//  study_WidgetExampleApp.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/11/24.
//

import SwiftUI

@main
struct study_WidgetExampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
