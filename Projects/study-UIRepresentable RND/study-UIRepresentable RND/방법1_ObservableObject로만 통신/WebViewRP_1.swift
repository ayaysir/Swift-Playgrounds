//
//  WebViewRP.swift
//  study-UIRepresentable RND
//
//  Created by 윤범태 on 1/25/25.
//

import SwiftUI
import WebKit

/// A container for using a WKWebView in SwiftUI
struct WebViewRP_1: UIViewRepresentable {
  typealias UIViewType = WKWebView
  
  let store: WebViewStore_1
  
  init(store: WebViewStore_1) {
    self.store = store
  }
  
  func makeUIView(context: Context) -> WKWebView {
    store.webView.uiDelegate = context.coordinator
    
    return store.webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKUIDelegate {
    var parent: WebViewRP_1
    
    init(_ parent: WebViewRP_1) {
      self.parent = parent
    }
    
    func webView(
      _ webView: WKWebView,
      runJavaScriptAlertPanelWithMessage message: String,
      initiatedByFrame frame: WKFrameInfo
    ) async {
      parent.store.showAlert = true
      parent.store.alertMessage = message
    }
    
    func webView(
      _ webView: WKWebView,
      runJavaScriptConfirmPanelWithMessage message: String,
      initiatedByFrame frame: WKFrameInfo
    ) async -> Bool {
      /*
       parent.store.showConfirm = true
       parent.store.confirmMessage = message
       
       // 이거 어떻게 받아옴??
       return true
       */
      
      await withCheckedContinuation { continuation in
        DispatchQueue.main.async {
          self.parent.store.showConfirm = true
          self.parent.store.confirmMessage = message
          self.parent.store.confirmResult = { result in
            continuation.resume(returning: result)
          }
        }
      }
    }
    
    func webView(
      _ webView: WKWebView,
      runJavaScriptTextInputPanelWithPrompt prompt: String,
      defaultText: String?,
      initiatedByFrame frame: WKFrameInfo
    ) async -> String? {
      /*
       parent.store.showPrompt = true
       parent.store.promptMessage = prompt
       
       // 이거 어떻게 받아옴??
       return "..."
       */
      
      await withCheckedContinuation { continuaton in
        DispatchQueue.main.async {
          self.parent.store.showPrompt = true
          self.parent.store.promptMessage = prompt
          self.parent.store.promptResult = { result in
            continuaton.resume(returning: result)
          }
        }
      }
    }
  }
}
