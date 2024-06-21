//
//  FullScreenVideoPlayer.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/20/24.
//

import SwiftUI
import AVKit

final class FullScreenVideoRepresentedViewModel: ObservableObject {
    @Published var isLooping = false
}

struct FullScreenVideoPlayerRepresentedView: UIViewControllerRepresentable {
    let url: URL
    @StateObject var viewModel: FullScreenVideoRepresentedViewModel
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        
        let selectorToForceFullScreenMode = NSSelectorFromString("_transitionToFullScreenAnimated:interactive:completionHandler:")
        
        player.play()
        
        if !viewModel.isLooping {
            loopVideo(player)
        }
        
        // 강제 풀스크린 전환
        // asyncAfter는 전체화면에서 컨트롤 요소가 나오지 않을 떄에만 사용
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
            if controller.responds(to: selectorToForceFullScreenMode) {
                controller.perform(selectorToForceFullScreenMode, with: true, with: nil)
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
    
    /// 비디오를 반복 재생
    func loopVideo(_ videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
        
        DispatchQueue.main.async {
            viewModel.isLooping = true
        }
    }
}

#Preview {
    FullScreenVideoPlayerRepresentedView(url: URL(string: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_2mb.mp4")!, viewModel: .init())
}
