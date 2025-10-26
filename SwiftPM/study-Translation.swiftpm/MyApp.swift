import SwiftUI

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        TranslationPresententationView()
          .tabItem {
            Label("Home", systemImage: "house")
          }
        CustomTranslationAutoStartView()
          .tabItem {
            Label("Custom", systemImage: "book")
          }
        
        if #available(iOS 18.0, *) {
          CustomTranslationTriggerStartView()
            .tabItem {
              Label("Custom 2", systemImage: "folder")
            }
          
          CustomTranslationAdvancedView()
            .tabItem {
              Label("Custom 3", systemImage: "info.circle")
            }
        }
      }
    }
  }
}
