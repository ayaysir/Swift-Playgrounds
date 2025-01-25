//
//  WebViewStore.swift
//  study-UIRepresentable RND
//
//  Created by 윤범태 on 1/25/25.
//

import Foundation
import WebKit
import Combine

final class WebViewStore_1: ObservableObject {
  @Published public var webView: WKWebView
  
  // Combine으로 Publish 되는 변수들
  @Published var estimatedProgress: Double = 0.0
  @Published var title: String? = ""
  
  // private var cancellable: AnyCancellable?
  private var cancellables = Set<AnyCancellable>()
  
  init(webView: WKWebView = .init()) {
    self.webView = webView
    
    webView.publisher(for: \.estimatedProgress)
      .receive(on: DispatchQueue.main)
      .assign(to: \.estimatedProgress, on: self)
      .store(in: &cancellables)
    
    webView.publisher(for: \.title)
      .receive(on: DispatchQueue.main)
      .assign(to: \.title, on: self)
      .store(in: &cancellables)
  }
  
  // MARK: - 여기에서 연결할 변수들을 @Published로 추가
  
  @Published var showAlert = false
  @Published var alertMessage = ""
  
  @Published var showConfirm = false
  @Published var confirmMessage = ""
  var confirmResult: ((Bool) -> Void)?
  
  @Published var showPrompt = false
  @Published var promptMessage = ""
  @Published var promptQuery = ""
  var promptResult: ((String?) -> Void)?
}
