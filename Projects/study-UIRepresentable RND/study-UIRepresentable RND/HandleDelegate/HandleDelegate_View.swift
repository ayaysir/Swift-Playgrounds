//
//  HandleDelegate_View.swift
//  study-UIRepresentable RND
//
//  Created by 윤범태 on 1/25/25.
//

import SwiftUI
import WebKit

struct HandleDelegate_View: View {
  @State private var showAlert = false
  @State private var showConfirm = false
  @State private var showPrompt = false
  
  @State private var alertMessage = ""
  @State private var promptInput = ""
  
  @State private var alertHandler: (() -> Void)?
  @State private var confirmHandler: ((Bool) -> Void)?
  @State private var promptHandler: ((String?) -> Void)?
  
  var body: some View {
    HD_WebViewRP(
      showAlert: $showAlert,
      showConfirm: $showConfirm,
      showPrompt: $showPrompt,
      alertMessage: $alertMessage,
      alertHandler: $alertHandler,
      confirmHandler: $confirmHandler,
      promptHandler: $promptHandler
    )
      .alert(alertMessage, isPresented: $showAlert) {
        Button("OK", role: .none) {
          alertHandler?()
        }
      }
      .alert(alertMessage, isPresented: $showConfirm) {
        
        Button("No", role: .cancel) {
          confirmHandler?(false)
        }
        Button("Yes", role: .none) {
          confirmHandler?(true)
        }
      }
      .alert(alertMessage, isPresented: $showPrompt) {
        TextField("Prompt", text: $promptInput)
        Button("제출", role: .none) {
          promptHandler?(promptInput)
          promptInput = ""
        }
        Button("취소", role: .cancel) {
          promptHandler?(nil)
          promptInput = ""
        }
      }
  }
}

struct HD_WebViewRP: UIViewRepresentable {
  typealias UIViewType = WKWebView
  
  @Binding var showAlert: Bool
  @Binding var showConfirm: Bool
  @Binding var showPrompt: Bool
  
  @Binding var alertMessage: String
  
  @Binding var alertHandler: (() -> Void)?
  @Binding var confirmHandler: ((Bool) -> Void)?
  @Binding var promptHandler: ((String?) -> Void)?
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    let url = URL(string: "https://testpages.herokuapp.com/styled/alerts/alert-test.html")!
    webView.load(URLRequest(url: url))
    webView.uiDelegate = context.coordinator
    
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKUIDelegate {
    let parent: HD_WebViewRP
    
    init(_ parent: HD_WebViewRP) {
      self.parent = parent
    }
    
    func webView(
      _ webView: WKWebView,
      runJavaScriptAlertPanelWithMessage message: String,
      initiatedByFrame frame: WKFrameInfo
    ) async {
      await withCheckedContinuation { continuation in
        DispatchQueue.main.async {
          self.parent.showAlert = true
          self.parent.alertMessage = message
          // 대기(await)중이던 async 함수를 재개한다.
          self.parent.alertHandler = {
            continuation.resume()
          }
        }
      }
    }
    
    // Confirm창: completionHandler 전송으로 구현 (간단)
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (Bool) -> Void) {
      DispatchQueue.main.async {
        self.parent.showConfirm = true
        self.parent.alertMessage = message
        self.parent.confirmHandler = completionHandler
      }
    }
    
    // Prompt창: async/await로 구현 (복잡)
    func webView(
      _ webView: WKWebView,
      runJavaScriptTextInputPanelWithPrompt prompt: String,
      defaultText: String?,
      initiatedByFrame frame: WKFrameInfo
    ) async -> String? {
      return await withCheckedContinuation { continuation in
        DispatchQueue.main.async {
          self.parent.showPrompt = true
          self.parent.alertMessage = prompt
          self.parent.promptHandler = { inputValue in
            continuation.resume(returning: inputValue)
          }
        }
      }
    }
  }
}

#Preview {
  HandleDelegate_View()
}
