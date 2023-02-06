import UIKit

// Queue - Main, Global, Custom

// Main
DispatchQueue.main.async {
    let view = UIView()
    view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
}

// Global
DispatchQueue.global(qos: .userInteractive).async {
    // 가장 중요, 당장 해야됨
}

DispatchQueue.global(qos: .userInitiated).async {
    // 거의 바로 해야함, 사용자가 결과를 기다린다.
}

DispatchQueue.global(qos: .default).async {
    // 기본값 (qos 생략가능)
}

DispatchQueue.global(qos: .utility).async {
    // 시간이 걸리는 일, 사용자가 당장 기다리지 않는 것
    // 네트워킹, 대용량 파일 로딩
}

DispatchQueue.global(qos: .background).async {
    // 사용자한테 당장 인식될 필요가 없는 것들
    // 뉴스 데이터, 위치 업데이트, 영상 다운로드
}

// Custom queue
let concurrentQueue = DispatchQueue(label: "concurrent", qos: .background, attributes: .concurrent)
let serialQueue = DispatchQueue(label: "serial", qos: .background)


// 복합적인 상황
func downloadImageFromServer() -> UIImage {
    // Heavy tasks
    
    return UIImage()
}

func updateUI(image: UIImage) {
    
}

DispatchQueue.global(qos: .background).async {
    let image = downloadImageFromServer()
    
    DispatchQueue.main.async {
        updateUI(image: image)
    }
}


// sync, async

// async
DispatchQueue.global(qos: .background).async {
    for i in 0...5 {
        print("😈 \(i)")
    }
}

DispatchQueue.global(qos: .userInteractive).async {
    for i in 0...5 {
        print("🤮 \(i)")
    }
}
