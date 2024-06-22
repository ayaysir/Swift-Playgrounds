//
//  ContentView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/11/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.deepLinkText) var deepLinkText
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Post.createdTimestamp, ascending: true)],
        animation: .default)
    private var posts: FetchedResults<Post>
    
    @State private var showUpdateView = false

    var body: some View {
        NavigationView {
            List {
                Text(deepLinkText.isEmpty ? "DeepLinkText" : deepLinkText)
                Text("SharedCounter: \(Counter.currentCount())")
                ForEach(posts) { post in
                    NavigationLink {
                        DetailView(post: post)
                    } label: {
                        HStack {
                            let thumbnail = prepareThumbnail(post: post) ?? Image("sample")
                            
                            thumbnail
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
                            
                            Text(post.title ?? "unknown title")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showUpdateView.toggle()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
        .sheet(isPresented: $showUpdateView) {
            UpdateMediaView()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { posts[$0] }.forEach(viewContext.delete)

            do {
                // TODO: - URL의 파일 삭제
                
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func prepareThumbnail(post: Post) -> Image? {
        guard let fileName = post.fileName else {
            return nil
        }
        
        let url = URL.applicationSupportDirectory.appendingPathComponent(fileName)
        
        if post.isVideo, let uiImage = AVUtil.generateVideoThumbnail(videoPath: url) {
             return Image(uiImage: uiImage)
        } else if let data = try? Data(contentsOf: url),
                  let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        
        return nil
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
