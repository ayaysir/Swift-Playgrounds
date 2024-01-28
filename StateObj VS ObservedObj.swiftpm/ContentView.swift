import SwiftUI

class RandomGenerator: ObservableObject {
    @Published private(set) var text = UUID().uuidString.split(separator: "-")[0]
    @Published var word = "👀"
    
    init() {
        text += " \(Date.now.timeIntervalSince1970)"
    }
}

struct RandomView1: View {
    @ObservedObject var rg: RandomGenerator = .init()
    
    var body: some View {
        Text(rg.text)
        Button("아무말") {
            rg.word = ["🐼", "🐟", "🦀", "🐴"].randomElement() ?? ""
        }
        Text(rg.word)
    }
}

struct RandomView2: View {
    @StateObject var rg: RandomGenerator = .init()
    
    var body: some View {
        Text(rg.text)
        Button("아무말") {
            rg.word = ["🐼", "🐟", "🦀", "🐴"].randomElement() ?? ""
        }
        Text(rg.word)
    }
}

struct ContentView: View {
    @State private var isOn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(isOn ? "켬" : "꺼짐") {
                    isOn.toggle()
                }
                Divider()
                
                Text("@ObservedObject")
                    .font(.custom("Courier New", size: 20).bold())
                RandomView1()
                Divider()
                
                Text("@StateObject")
                    .font(.custom("Courier New", size: 20).bold())
                RandomView2()
                Divider()
            }
        }
    }

}
