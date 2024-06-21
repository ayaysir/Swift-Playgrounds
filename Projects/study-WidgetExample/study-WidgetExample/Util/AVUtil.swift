//
//  AVUtil.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/22/24.
//

import AVKit

struct AVUtil {
    static func generateVideoThumbnail(videoPath: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: videoPath, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
