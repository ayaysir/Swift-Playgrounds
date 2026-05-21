//
//  SwiftUIWebView.swift
//  study-UIKitWithoutStoryboard
//
//  Created by 윤범태 on 3/20/26.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  typealias UIViewType = WKWebView
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.translatesAutoresizingMaskIntoConstraints = false
    let url = URL(string: "https://dict.naver.com")!
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true

    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct WebViewView: View {
  var body: some View {
    // TabView {
    //   WebView()
    //     .ignoresSafeArea()
    //     .tabItem {
    //       Label("Home", image: "home")
    //     }
    // }
    WebView()
      .ignoresSafeArea(edges: .bottom)
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          HStack {
            Button("a") {}
            Button(action: {}) {
              Label("Play", systemImage: "play")
            }
            Button(action: {}) {
              Label("Play", systemImage: "play")
            }
            Spacer()
            Button(action: {}) {
              Label("Play", systemImage: "play")
            }
          }
        }
      }
  }
}

#Preview {
  WebViewView()
}
