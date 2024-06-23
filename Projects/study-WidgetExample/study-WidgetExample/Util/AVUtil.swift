//
//  AVUtil.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/22/24.
//

import AVKit
import QuickLookThumbnailing

struct AVUtil {
    private init() {}
    
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
    
    static func generateImageThumbnail(for fileURL: URL, size: CGSize, scale: CGFloat) async throws -> UIImage {
        let request = QLThumbnailGenerator
            .Request(fileAt: fileURL, size: size, scale: scale,
                     representationTypes: .lowQualityThumbnail)

        let repr = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
        return repr.uiImage
    }
    
    static func generateThumbnail(for fileURL: URL, size: CGSize, scale: CGFloat, completion: @escaping ((UIImage?) -> ())) {
        let request = QLThumbnailGenerator
            .Request(fileAt: fileURL, size: size, scale: scale,
                     representationTypes: .thumbnail)
        QLThumbnailGenerator.shared.generateRepresentations(for: request) { representation, type, error in
            if let error {
                print(error)
                return
            }
            
            completion(representation?.uiImage)
        }
    }
}
