import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        // Chapter 1-2
        #if os(iOS)
        DefaultScene()
        #elseif os(macOS)
        AlternativeScene()
        #endif
    }
}
