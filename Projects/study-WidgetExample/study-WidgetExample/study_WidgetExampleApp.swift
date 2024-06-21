//
//  study_WidgetExampleApp.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/11/24.
//

import SwiftUI

@main
struct study_WidgetExampleApp: App {
    @State private var widgetText = ""
    @State private var isPresented = false
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.deepLinkText, widgetText)
                .onOpenURL { url in
                    widgetText = url.absoluteString.removingPercentEncoding ?? "텍스트가 없습니다!"
                    isPresented = true
                }
                .sheet(isPresented: $isPresented) {
                    if !widgetText.isEmpty {
                        Text(widgetText)
                            .font(.title)
                    }
                }
                .onAppear {
                    print("***** System Report *****")
                    print("appSupport dirpath:", URL.applicationSupportDirectory.absoluteString)
                    print("*************************")
                }
        }
    }
}

struct DeepLinkEnv: EnvironmentKey {
    static let defaultValue = ""
}

extension EnvironmentValues {
    var deepLinkText: String {
        get {
            self[DeepLinkEnv.self]
        } set {
            self[DeepLinkEnv.self] = newValue
        }
    }
}
