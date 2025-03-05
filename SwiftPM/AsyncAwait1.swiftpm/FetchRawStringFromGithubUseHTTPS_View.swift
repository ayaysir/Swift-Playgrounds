//
//  SwiftUIView.swift
//  AsyncAwait1
//
//  Created by 윤범태 on 3/4/25.
//

import SwiftUI

fileprivate let urlStr1 = "https://gist.githubusercontent.com/ayaysir/dc83d550cc36b3e7b28b7e725d8fec4c/raw/fee8e5305f86b46a042fbd5dd45c061f31434e11/en.txt"
fileprivate let urlStr2 = "https://raw.githubusercontent.com/ayaysir/iOSInterviewquestions-withChatGPT/refs/heads/master/README.md"
fileprivate let urlStr3 = "https://raw.githubusercontent.com/ayaysir/MusicScale/refs/heads/main/README.md"
fileprivate let urlStr4 = "https://gist.githubusercontent.com/ayaysir/4f62ca975150afec2de2642bfe178ea5/raw/a4cd5d331ee876217fe7d74b84c6db2a64457364/Notice.csv"
/*
 https://gist.githubusercontent.com/ayaysir/4f62ca975150afec2de2642bfe178ea5/raw/eb448f70d31727b2c883299a2743be0ac0123492/Notice.csv
 
 결론: 내용 업데이트마다 주소가 바뀌어서 공지사항용으로 사용할 수 없음
 */

func fetchString(from url: URL) async throws -> String {
  let (data, _) = try await URLSession.shared.data(from: url)
  return String(decoding: data, as: UTF8.self)
}

struct FetchRawStringFromGithubUseHTTPS_View: View {
  @State private var content: String?
  @State private var showLoading = false
  @State private var status = ""
  
  var body: some View {
    ZStack {
      VStack {
        HStack {
          Button("gist") {
            Task {
              await fetch(urlString: urlStr1)
            }
          }
          Button("Github_Short") {
            Task {
              await fetch(urlString: urlStr3)
            }
          }
          Button("Github_Long") {
            Task(priority: .background) {
              await fetch(urlString: urlStr2)
            }
          }
          Button("gist_secret") {
            Task(priority: .background) {
              await fetch(urlString: urlStr4)
            }
          }
        }
        
        Text(status)
        
        ScrollView {
          if let content {
            Text(content)
          }
        }
        .padding()
        
      }
      
      if showLoading {
        // 배경 블러 효과
        BlurView()
          .ignoresSafeArea()
        ProgressView("Loading...")
          .progressViewStyle(.circular)
          .padding()
      }
    }
    .task {
      await fetch(urlString: urlStr1)
    }
  }
  
  func fetch(urlString: String) async {
    do {
      showLoading = true
      
      let first = try await fetchString(from: URL(string: urlString)!)
      DispatchQueue.main.async {
        self.content = first
        showLoading = false
      }
    } catch {
      print("Error fetching data:", error)
    }
  }
}

// 블러 효과를 위한 UIViewRepresentable
struct BlurView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    return view
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
  FetchRawStringFromGithubUseHTTPS_View()
}
