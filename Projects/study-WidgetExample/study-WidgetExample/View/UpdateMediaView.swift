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
    
    @State private var showFilePicker = false
    @State private var avPlayer = AVPlayer()
    @State private var isNeedAVPlayer = false
    @State private var imageData: Data?
    
    @State private var fileURL: URL?
    @State private var txfTitle = ""
    @State private var txfComment = ""
    
    @State private var imageSelection: PhotosPickerItem?
    
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
                    // TODO: - 데이터베이스 추가
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
        .onChange(of: imageSelection) {
            if let imageSelection {
                let isVideo = imageSelection.supportedContentTypes.contains { type in
                    type.description == "public.mpeg-4"
                }
                
                isNeedAVPlayer = false
                imageSelection.loadTransferable(type: TransferableImage.self) { result in
                    guard imageSelection == self.imageSelection else {
                        print("Failed to get the selected item.")
                                        return
                    }
                    
                    switch result {
                    case .success(let transferable?):
                        if isVideo {
                            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
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
                        print("이미지 라이브러리에서 불러오기 실패")                    }
                }
            }
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

struct TransferableImage: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            return TransferableImage(data: data)
            
        }
        
        DataRepresentation(importedContentType: .movie) { data in
            return TransferableImage(data: data)
        }
    }
}

#Preview {
    UpdateMediaView()
}
