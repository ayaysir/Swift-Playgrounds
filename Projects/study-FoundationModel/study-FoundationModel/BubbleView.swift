//
//  BubbleView.swift
//  study-FoundationModel
//
//  Created by 윤범태 on 5/21/26.
//

import SwiftUI

struct BubbleView: View {
  let message: ChatMessage
  
  var body: some View {
    HStack {
      if message.isUser { Spacer() }
      // LocalizedStringKey로 초기화하는 이니셜라이저를 사용해 Markdown을 해석
      Text(.init(message.text))
        .padding(12)
        .foregroundStyle(message.isUser ? .white : .primary)
        .background(
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(message.isUser ? Color.accentColor : Color.gray.opacity(0.3))
        )
        .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
        .overlay(alignment: message.isUser ? .bottomTrailing : .bottomLeading) {
          // 꼬리 느낌 내고 싶으면 여기에 작은 삼각형 등을 추가
          EmptyView()
        }
      
      if !message.isUser { Spacer() }
    }
    .padding(.horizontal)
    .padding(.vertical, 4)
  }
}
