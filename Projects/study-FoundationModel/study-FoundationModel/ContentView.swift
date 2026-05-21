//
//  ContentView.swift
//  study-FoundationModel
//
//  Created by 윤범태 on 5/21/26.
//

import SwiftUI
import SwiftData
import FoundationModels

enum ChatAnchorID {
  static let typing = "typing-indicator"
}

struct ContentView: View {
  // @Environment(\.modelContext) private var modelContext
  // @Query private var items: [Item]
  
  @State private var messages: [ChatMessage] = [
    ChatMessage(text: "무엇을 도와드릴까요?", isUser: false)
  ]
  @State private var draft: String = ""
  @State private var isThinking: Bool = false
  
  let session = LanguageModelSession(instructions: "당신은 한국어 비서입니다. 사용자 질문에 답하세요.") // (1) LanguageModelSession 설정
  
  var body: some View {
    NavigationSplitView {
      List {
        Section {
          NavigationLink {
            
          } label: {
            Text("기본 대화")
          }
        } header: {
          Text("기록")
        }
      }
#if os(macOS)
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
      .toolbar {
#if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
#endif
        ToolbarItem {
          Button(action: {}) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .onAppear {
        
      }
    } detail: {
      AreaChats
    }
  }
  
  @ViewBuilder private var AreaChats: some View {
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(messages) { message in
              BubbleView(message: message)
                .id(message.id)
                .textSelection(.enabled)
            }
            
            if isThinking {
              TypingIndicator()
                .padding(.horizontal)
                .padding(.vertical, 8)
                .id(ChatAnchorID.typing)
            }
          }
          .padding(.bottom, 8)
          .onChange(of: messages) { _, _ in
            scrollToBottom(proxy: proxy)
          }
          .onChange(of: isThinking) { _, thinking in
            if thinking {
              DispatchQueue.main.async {
                scrollToBottom(proxy: proxy)
              }
            } else {
              scrollToBottom(proxy: proxy)
            }
          }
        }
        // .background(Color.background)
      }
      
      Divider()
      
      HStack(spacing: 8) {
        TextField("메시지 입력…", text: $draft, axis: .vertical)
          .textFieldStyle(.roundedBorder)
          .lineLimit(1...6)
          .onSubmit(send)
        
        Button {
          send()
        } label: {
          Image(systemName: "paperplane.fill")
            .font(.system(size: 17, weight: .semibold))
        }
        .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
      .padding(.horizontal)
      .padding(.vertical, 10)
      .background(.ultraThinMaterial)
    }
  }
  
  private func scrollToBottom(proxy: ScrollViewProxy) {
    if isThinking {
      withAnimation(.easeOut(duration: 0.25)) {
        proxy.scrollTo(ChatAnchorID.typing, anchor: .bottom)
      }
    } else if let last = messages.last {
      withAnimation(.easeOut(duration: 0.25)) {
        proxy.scrollTo(last.id, anchor: .bottom)
      }
    }
  }
  
  private func send() {
    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return }
    draft = ""
    
    let userMsg = ChatMessage(text: text, isUser: true)
    messages.append(userMsg)
    
    isThinking = true
    Task {
      do {
        let response = try await session.respond(to: text) // (2) session.respond 로 질문 입력 후 답변 받음
        let reply = ChatMessage(text: response.content, isUser: false)
        print(response)
        messages.append(reply)
        isThinking = false
      } catch {
        let reply = ChatMessage(text: "죄송합니다. 에러가 발생했습니다:  \(error)", isUser: false)
        messages.append(reply)
        isThinking = false
      }
      // try? await Task.sleep(nanoseconds: 900_000_000) // 0.9s
    }
  }
}

struct TypingIndicator: View {
  @State private var phase: Int = 0
  let dots = 3
  
  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<dots, id: \.self) { i in
        Circle()
          .fill(Color.secondary)
          .frame(width: 8, height: 8)
          .opacity(phase == i ? 1 : 0.3)
          .animation(.easeInOut(duration: 0.35).repeatForever().delay(Double(i) * 0.12), value: phase)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .onAppear {
      // 무한 순환
      Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
        phase = (phase + 1) % dots
      }
    }
  }
}

#Preview {
  ContentView()
  // .modelContainer(for: Item.self, inMemory: true)
}
