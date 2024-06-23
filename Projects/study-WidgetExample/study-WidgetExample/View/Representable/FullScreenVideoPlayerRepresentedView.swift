//
//  FullScreenVideoPlayer.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/20/24.
//

import SwiftUI
import AVKit

struct FullScreenVideoPlayerRepresentedView: UIViewControllerRepresentable {
    let url: URL
    let player = AVPlayer()
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        
        player.replaceCurrentItem(with: .init(url: url))
        
        let selectorToForceFullScreenMode = NSSelectorFromString("_transitionToFullScreenAnimated:interactive:completionHandler:")
        
        player.play()
        loopVideo()
        
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
    
    func loopVideo() {
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
        
        // Be sure to specify the object as the AVPlayer's player item if you have multiple players. https://stackoverflow.com/a/40396824
        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: self.player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
}

#Preview {
    FullScreenVideoPlayerRepresentedView(url: URL(string: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_2mb.mp4")!)
}
