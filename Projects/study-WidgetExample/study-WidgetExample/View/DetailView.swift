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
    var isOpenFromWidget = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if isOpenFromWidget {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            if let fileName = post.fileName {
                let url = FileManager.sharedContainerURL().appendingPathComponent(fileName)
                
                if post.isVideo {
                    FullScreenVideoPlayerRepresentedView(url: url)
                } else {
                    QLPreviewRepresentedView(url: url)
                }
            } else {
                // TODO: - alert: 파일이 없습니다.
                FullScreenVideoPlayerRepresentedView(url: Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4")!)
            }
        }
        .onAppear {
            
        }
        .onDisappear {
            
        }
    }
}

#Preview {
    let viewContext = PersistenceController.preview.container.viewContext
    let post = Post(context: viewContext)
    post.isVideo = true
    post.title = "Funny video 🤣"
    post.comment = "🤣🤣🤣🤣"
    post.createdTimestamp = Date.now
    post.fileName = nil
    return DetailView(post: post)
}
