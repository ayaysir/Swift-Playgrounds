import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ButtonDebounce()
                    .tabItem {
                        Image(systemName: "button.programmable")
                        Text("Button Debounce")
                    }
                ButtonThrottle()
                    .tabItem {
                        Image(systemName: "button.programmable")
                        Text("Button Throttle")
                    }
                SliderDebounce()
                    .tabItem {
                        Image(systemName: "button.programmable")
                        Text("Slider Debounce")
                    }
            }
        }
    }
}
