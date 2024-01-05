import SwiftUI
import Combine

struct ButtonThrottle: View {
    @State private var statusText = "대기"
    @State private var buttonTouchCount = 0
    @State private var buttonProcessCount = 0
    
    // PassthroughSubject 퍼블리셔 추가
    private let buttonPublisher = PassthroughSubject<Void, Never>()
    
    var body: some View {
        // 퍼블리셔에 1초 Throttle, 메인 스레드에서
        let buttonThrottle = buttonPublisher
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: false)
        
        VStack {
            Text("\(statusText) | \(buttonTouchCount)")
            Button("Throttle") {
                buttonPublisher.send() // 보내면 onReceive에서 수신
                buttonTouchCount += 1
            }
        }
        .onReceive(buttonThrottle) { _ in
            buttonProcessCount += 1
            statusText = "버튼 작업 실행 [\(buttonProcessCount)]"
        }
    }
}
