//
//  DynamicWidget1EntryView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/15/24.
//

import SwiftUI

struct DynamicWidget1EntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Post.createdTimestamp, ascending: true)],
        animation: .default)
    private var posts: FetchedResults<Post>
    
    // 화면을 그리드형식으로 꽉채워줌
    let MARGIN: CGFloat = 10
    var columns: [GridItem] {
        return (1...5).map { _ in
            GridItem(.flexible(), spacing: MARGIN)
        }
    }

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: MARGIN) {
                // Button(intent: OpenAppIntent()) {
                //     Text(entry.configuration.favoriteEmoji)
                // }
                
                ForEach(posts, id: \.hash) { post in
                    Link(destination: URL(string: "widget://deeplink?filename=\(post.fileName ?? "unknown")")!) {
                        if let thumbnail = prepareCachedThumbnail(post: post) {
                            thumbnail
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
                        } else {
                            Image("sample")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
                        }
                    }
                }
            }
        }
        .onAppear {
            // items = PersistenceController.shared.fetchItems()
        }
    }
    
    private func prepareCachedThumbnail(post: Post) -> Image? {
        guard let fileName = post.fileName else {
            return nil
        }
        
        let url = FileManager.sharedContainerURL()
            .appendingPathComponent("thumbnail")
            .appendingPathComponent(fileName + ".thumbnail.png")
        
        _ = url.startAccessingSecurityScopedResource()
        
        if let data = try? Data(contentsOf: url),
                  let uiImage = UIImage(data: data) {
            let image = Image(uiImage: uiImage)
            url.stopAccessingSecurityScopedResource()
            
            return image
        } else {
            url.stopAccessingSecurityScopedResource()
            return nil
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
