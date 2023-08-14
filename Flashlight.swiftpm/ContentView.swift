import SwiftUI
import AVFoundation

struct ContentView: View {
    private let DEBUG_MODE: Bool = false
    
    @Environment(\.scenePhase) var scenePhase
    @State var outsideDisplayBrightness: CGFloat = 0.5
    @State var displayBrightness: CGFloat = 1.0 {
        didSet {
            guard displayBrightness <= 1 && displayBrightness >= 0 else {
                return
            }
    
            setBrightness(displayBrightness)
        }
    }
    
    @State var torchBrightness: Float = 1.0 {
        didSet {
            guard torchBrightness <= 1.0  else {
                torchBrightness = 1.0
                return
            }
            
            guard torchBrightness >= 0.0 else {
                torchBrightness = 0.01 // 0.0은 에러발생
                return
            }
            
            setTorch(torchBrightness)
        }
    }
    
    private func setBrightness(_ displayBrightness: CGFloat) {
        UIScreen.main.brightness = displayBrightness
    }
    
    private func setTorch(_ torchBrightness: Float) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: torchBrightness)
            // 참고: 플래시 끄기
            // device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            print(#function, error.localizedDescription)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(DEBUG_MODE ? .cyan : .white)
                    .onTapGesture {
                        displayBrightness += 0.1
                    }
                Rectangle()
                    .onTapGesture {
                        displayBrightness -= 0.1
                    }
            }
            VStack(spacing: 0) {
                Rectangle()
                    .onTapGesture {
                        torchBrightness += 0.1
                    }
                Rectangle()
                    .fill(DEBUG_MODE ? .cyan : .white)
                    .onTapGesture {
                        torchBrightness -= 0.1
                    }
            }
        }
        .foregroundColor(.white)
        .ignoresSafeArea()
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .background:
                // print("App is in background")
                break
            case .inactive:
                // print("App is inactive")
                setBrightness(outsideDisplayBrightness)
                // 플래시(torch)는 저절로 꺼지기 때문에 굳이 코드로 넣지 않음
            case .active:
                // print("App is active")
                outsideDisplayBrightness = UIScreen.main.brightness
                setTorch(torchBrightness)
                setBrightness(displayBrightness)
            @unknown default:
                break
            }
        }
    }
}
