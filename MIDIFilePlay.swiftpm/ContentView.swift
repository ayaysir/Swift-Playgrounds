import SwiftUI

struct ContentView: View {
    @StateObject var conductor = MIDIFilePlayConductor()
    
    var body: some View {
        VStack {
            Button {
                if conductor.isPlaying {
                    conductor.stop()
                } else {
                    conductor.play()
                }
            } label: {
                Image(systemName: conductor.isPlaying ? "stop.fill" : "play.fill")
            }
            Slider(value: $conductor.currentPosition, in: 0...conductor.duration) { result in
                conductor.changePosition(conductor.currentPosition)
            }
        }
        .padding()
    }
}
