//
//  InfiniteScrollView.swift
//  SwiftUI Scroll From Bottom To Top
//
//  Created by 윤범태 on 5/30/26.
//

import SwiftUI

private struct Post: Identifiable {
  var id = UUID()
  var author: String
  var title: String
  var content: String
}

private class InfiniteScrollViewModel: ObservableObject {
  private(set) var fetchCount = 0
  @Published var datas: [Post] = []
  
  init() {
    fetchSampleDatas(count: 100)
  }
  
  func fetchSampleDatas(count: Int = 10000) {
    if fetchCount >= 10 {
      return
    }
    
    fetchCount += 1
    
    Task {
      try await Task.sleep(nanoseconds: UInt64(1e+9))
      datas += (1...count).map { Post(author: "...", title: "FetchCount: \(fetchCount), Title \($0)", content: "Content \($0)") }
    }
    
  }
}

struct InfiniteScrollView: View {
  @StateObject private var viewModel = InfiniteScrollViewModel()
  
  var body: some View {
    List {
      ForEach(viewModel.datas) { data in
        HStack {
          Image(systemName: "photo")
            .resizable()
            .frame(width: 100, height: 100)
          VStack(alignment: .leading) {
            Text("\(data.title)")
              .font(.title2).bold()
            Text("\(data.content)")
              .font(.caption)
          }
        }
        
      }
      if viewModel.fetchCount < 10 {
        // List 안에 넣어야만 됨
        TypingIndicator()
          .onAppear {
            print("Text onAppear")
            viewModel.fetchSampleDatas(count: 100)
          }
      }
    
      
    }
    .listStyle(.plain)
    .environment(\.defaultMinListRowHeight, 5)
  }
}

#Preview {
  InfiniteScrollView()
}
