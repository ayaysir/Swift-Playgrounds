import SwiftUI

struct ContentView: View {
  @State var isOn = false
  
  var body: some View {
    if #available(iOS 18.0, *) {
      Image(systemName: isOn ? "heart.fill" : "heart")
        .frame(width: 200, height: 200)
        .symbolRenderingMode(.multicolor)
        .symbolEffect(.bounce, options: .default, value: isOn)
        .onTapGesture {
          isOn.toggle()
        }
    } else {
      // Fallback on earlier versions
    }
  }
}
