//
//  ContentView.swift
//  study-UIRepresentable RND
//
//  Created by 윤범태 on 1/25/25.
//

import SwiftUI

struct ContentView_1: View {
  @StateObject private var store = WebViewStore_1()
  var body: some View {
    NavigationStack {
      VStack {
        ProgressView(value: store.webView.estimatedProgress)
        WebViewRP_1(store: store)
      }
      .padding()
      .navigationBarTitle(Text(verbatim: store.webView.title ?? ""), displayMode: .inline)
      .toolbarRole(.browser)
      .navigationBarItems(trailing: HStack {
        Button(action: goBack) {
          Image(systemName: "chevron.left")
            .imageScale(.large)
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
        }
        .disabled(false)
        Button(action: goForward) {
          Image(systemName: "chevron.right")
            .imageScale(.large)
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
        }
        .disabled(false)
      })
    }
    .onAppear {
      // 초기 웹 페이지 로딩
      store.webView.load(URLRequest(url: URL(string: "https://testpages.herokuapp.com/styled/alerts/alert-test.html")!))
    }
    .alert(store.alertMessage, isPresented: $store.showAlert) {
      Button("확인", role: .none) { }
    }
    .alert(store.confirmMessage, isPresented: $store.showConfirm) {
      Button("예", role: .none) {
        store.confirmResult?(true)
      }
      Button("아니오", role: .cancel) {
        store.confirmResult?(false)
      }
    }
    .alert(store.promptMessage, isPresented: $store.showPrompt) {
      TextField("Prompt", text: $store.promptQuery)
      Button("제출", role: .none) {
        store.promptResult?(store.promptQuery)
      }
      Button("취소", role: .cancel) {
        store.promptResult?(nil)
      }
    }
  }
  
  func goBack() {
    store.webView.goBack()
  }
  
  func goForward() {
    store.webView.goForward()
  }
}

#Preview {
  ContentView_1()
}
