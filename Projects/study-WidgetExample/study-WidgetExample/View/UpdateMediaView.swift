//
//  UpdateMediaView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/19/24.
//

import SwiftUI
import AVKit
import PhotosUI

struct UpdateMediaView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showFilePicker = false
    @State private var avPlayer = AVPlayer()
    @State private var isNeedAVPlayer = false
    @State private var imageData: Data?
    
    @State private var fileURL: URL?
    @State private var txfTitle = ""
    @State private var txfComment = ""
    
    @State private var imageSelection: PhotosPickerItem?
    @State private var imageSelectionURL: [String : URL]?
    
    @FocusState private var focusComment: PostTxfType?
    
    var body: some View {
        VStack {
            Text("미디어 선택")
                .font(.title)
                .bold()
            Text("표시할 미디어를 사진 라이브러리 또는 파일 브라우저에서 선택하세요.")
            Button("파일 불러오기") {
                showFilePicker.toggle()
            }
            
            PhotosPicker(selection: $imageSelection) {
                Text("사진 라이브러리에서 가져오기")
            }
            
            ZStack {
                Color.cyan
                if isNeedAVPlayer {
                    VideoPlayer(player: avPlayer)
                } else {
                    let uiImage: UIImage = if let imageData {
                        .init(data: imageData) ?? .init()
                    } else {
                        .init()
                    }
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 300, height: 300)
            
            VStack {
                TextField("제목", text: $txfTitle)
                TextField("코멘트", text: $txfComment)
                    .focused($focusComment, equals: .comment)
                Button("추가") {
                    saveToCoreData()
                    dismiss()
                }
            }
        }
        .padding()
        .sheet(isPresented: $showFilePicker) {
            DocumentPickerReperesentedView { url in
                print(url)
                fileURL = url
                txfTitle = (url.lastPathComponent as NSString).deletingPathExtension
                focusComment = .comment
            }
        }
        .onChange(of: fileURL) {
            mediaLoadFromStorage()
        }
        .onChange(of: imageSelection) {
            mediaLoadFromLibrary()
        }
        .onChange(of: isNeedAVPlayer) {
            avPlayer.pause()
        }
    }
    
    private func autoplayVideo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            avPlayer.play()
        }
    }
}

extension UpdateMediaView {
    func saveToCoreData() {
        let newPost = Post(context: viewContext)
        
        newPost.comment = txfComment
        newPost.title = txfTitle
        newPost.createdTimestamp = Date.now
        newPost.url = if let fileURL {
            URL.applicationSupportDirectory.appendingPathComponent(fileURL.lastPathComponent)
        } else if let imageSelectionURL {
            URL.applicationSupportDirectory.appendingPathComponent(imageSelectionURL.first!.key)
        } else {
            nil
        }
        
        print("newPost.url:", newPost.url ?? "nil")
        
        do {
            if let toURL = newPost.url {
                if let fileURL {
                    try Data(contentsOf: fileURL).write(to: toURL)
                } else if let imageSelectionURL {
                    if isNeedAVPlayer {
                        let tempVideo = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
                        try Data(contentsOf: tempVideo).write(to: toURL)
                    } else if let imageData {
                        try imageData.write(to: toURL)
                    }
                }
                print("file write success:", toURL)
            }
            
            try viewContext.save()
            print("Post saved to viewContext.")
        } catch {
            print("Unresolved error \(error)")
        }
    }
    
    func mediaLoadFromStorage() {
        guard let fileURL,
              let typeID = try? fileURL.resourceValues(forKeys: [.contentTypeKey]),
              let supertypes = typeID.contentType?.supertypes
        else {
            return
        }
        
        print(supertypes)
        
        if supertypes.contains(.image) {
            print("“Image file”")
            isNeedAVPlayer = false
            imageData = try? Data(contentsOf: fileURL)
        } else if supertypes.contains(.movie) {
            print("“Video file”")
            isNeedAVPlayer = true
            avPlayer.replaceCurrentItem(with: AVPlayerItem(url: fileURL))
            autoplayVideo()
        } else if supertypes.contains(.audio) {
            print("Audio file")
            isNeedAVPlayer = true
        } else {
            print("“Something else!”")
            isNeedAVPlayer = false
        }
    }
    
    func mediaLoadFromLibrary() {
        isNeedAVPlayer = false
        
        guard let imageSelection else {
            print("Failed to get the selected item.")
            return
        }
        
        let isVideo = imageSelection.supportedContentTypes.contains { type in
            type.description == "public.mpeg-4"
        }
        
        // get url info
        Task {
            imageSelectionURL = try await fetchContentUrls(content: [imageSelection])
            if let imageSelectionURL {
                txfTitle = (imageSelectionURL.first!.key as NSString).deletingPathExtension
            }
        }
        
        imageSelection.loadTransferable(type: TransferableImage.self) { result in
            switch result {
            case .success(let transferable?):
                if isVideo {
                    let tmpFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
                    let isFileWritten = (try? transferable.data.write(to: tmpFileURL, options: [.atomic])) != nil
                    
                    if isFileWritten {
                        avPlayer.replaceCurrentItem(with: AVPlayerItem(url: tmpFileURL))
                        autoplayVideo()
                        isNeedAVPlayer = true
                    }
                } else {
                    imageData = transferable.data
                }
        
                print("load success", imageData as Any)
            case .success(.none):
                print("load success but image is nil")
                isNeedAVPlayer = false
            case .failure(_):
                print("이미지 라이브러리에서 불러오기 실패")
            }
        }
    }
    
    func fetchContentUrls(content: [PhotosPickerItem]) async throws -> [String: URL] {
        try await withThrowingTaskGroup(of: TransferableURL?.self, returning: [String: URL].self) { group in
            for item in content {
                group.addTask { try await item.loadTransferable(type: TransferableURL.self) }
            }

            var contentUrls: [String: URL] = [:]

            for try await result in group {
                if let result {
                    contentUrls[result.url.lastPathComponent] = result.url
                }
            }

            return contentUrls
        }
    }
}

#Preview {
    UpdateMediaView()
}