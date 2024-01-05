import SwiftUI
import Combine

struct ButtonDebounce: View {
    @State private var statusText = "대기"
    @State private var buttonTouchCount = 0
    @State private var buttonProcessCount = 0
    
    // PassthroughSubject 퍼블리셔 추가
    private let buttonPublisher = PassthroughSubject<Void, Never>()
    
    var body: some View {
        // 퍼블리셔에 1초 Debounce, 메인 스레드에서
        let buttonDebounce = buttonPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
        
        VStack {
            Text("\(statusText) | \(buttonTouchCount)")
            Button("Debounce") {
                buttonPublisher.send() // 보내면 onReceive에서 수신
                buttonTouchCount += 1
            }
        }
        .onReceive(buttonDebounce) { _ in
            buttonProcessCount += 1
            statusText = "버튼 작업 실행 [\(buttonProcessCount)]"
        }
    }
}
