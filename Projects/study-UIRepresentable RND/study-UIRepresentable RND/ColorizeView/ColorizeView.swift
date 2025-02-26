//
//  ColorizeView.swift
//  study-UIRepresentable RND
//
//  Created by 윤범태 on 1/27/25.
//

import SwiftUI
import WebKit

struct ColorizeView: View {
  @State private var mode = "colorize"
  
  var body: some View {
    VStack {
      Button("toggle mode") {
        mode = mode == "invert" ? "colorize" : "invert"
      }
      
      
      if mode == "invert" {
        VStack {
          ColorizeWebViewRP()
        }
        .colorInvert()
        .offset(x: 10, y: 10)
      } else if mode == "colorize" {
        VStack {
          ColorizeWebViewRP()
        }
        .colorMultiply(.pink)
      }
      
      ZStack {
        if mode == "invert" {
          ColorizeWebViewRP()
            .colorInvert()
            .offset(x: 10, y: 10)
        } else if mode == "colorize" {
          ColorizeWebViewRP()
            .colorMultiply(.pink)
        }
      }
    }
  }
}

struct ColorizeWebViewRP: UIViewRepresentable {
  typealias UIViewType = UIView
  
  func makeUIView(context: Context) -> UIView {
    let webView = WKWebView()
    let url = URL(string: "https://google.com")
    let request = URLRequest(url: url!)
    webView.isInspectable = true
    webView.load(request)
    
    let view = UIView()
    view.backgroundColor = .cyan
    view.layer.compositingFilter = "CIColorInvert"
    view.addSubview(webView)
    
    // WebView의 Auto Layout 설정
    webView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])

    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    
  }
}

#Preview {
  ColorizeView()
}
