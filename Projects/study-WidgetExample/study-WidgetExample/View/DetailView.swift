//
//  DetailView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/20/24.
//

import SwiftUI
import AVKit

struct DetailView: View {
    let post: Post
    
    var body: some View {
        if let fileName = post.fileName {
            let appSupportURL = URL.applicationSupportDirectory.appendingPathComponent(fileName)
            FullScreenVideoPlayerRepresentedView(url: appSupportURL)
        } else {
            FullScreenVideoPlayerRepresentedView(url: Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4")!)
        }
    }
}

#Preview {
    let viewContext = PersistenceController.preview.container.viewContext
    let post = Post(context: viewContext)
    post.title = "Funny video 🤣"
    post.comment = "🤣🤣🤣🤣"
    post.createdTimestamp = Date.now
    post.fileName = nil
    // post.url = Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4")
    return DetailView(post: post)
}
