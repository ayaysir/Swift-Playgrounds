import SwiftUI

struct ContentView: View {
    // Chapter 1-1: Exploring the structure of a SwiftUI app
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}
