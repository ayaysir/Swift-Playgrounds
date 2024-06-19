//
//  UpdateMediaView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/19/24.
//

import SwiftUI
import AVKit

struct UpdateMediaView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showFilePicker = false
    @State private var avPlayer = AVPlayer()
    @State private var isNeedAVPlayer = false
    
    @State private var fileURL: URL?
    @State private var txfTitle = ""
    @State private var txfComment = ""
    
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
            Button("사진 라이브러리에서 불러오기") {
                // TODO: - 사진 라이브러리에서 가져오기
            }
            
            ZStack {
                Color.cyan
                if let fileURL {
                    if isNeedAVPlayer {
                        VideoPlayer(player: avPlayer)
                    } else if let data = try? Data(contentsOf: fileURL) {
                        Image(uiImage: .init(data: data) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                    }
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
            } else if supertypes.contains(.movie) {
                print("“Video file”")
                isNeedAVPlayer = true
                avPlayer.replaceCurrentItem(with: AVPlayerItem(url: fileURL))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    avPlayer.play()
                }
            } else if supertypes.contains(.audio) {
                print("Audio file")
                isNeedAVPlayer = true
            } else {
                print("“Something else!”")
                isNeedAVPlayer = false
            }
        }
    }
}

#Preview {
    UpdateMediaView()
}
