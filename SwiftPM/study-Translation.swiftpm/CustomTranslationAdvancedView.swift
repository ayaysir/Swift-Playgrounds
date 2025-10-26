//
//  CustomTranslationAdvancedView.swift
//  study-Translation
//
//  Created by 윤범태 on 10/26/25.
//

import SwiftUI
import Translation

@available(iOS 18.0, *)
struct CustomTranslationAdvancedView: View {
  var sourceTexts = [
    "Translationフレームワークは大きく二つの方式で使用できます。",
    "Explore the warehouse and watch our consolidation processes in action, where everything is carefully organized to keep operations running smoothly.",
    "本機能は、プロデュース方針を決める事で、ゲーム内の様々な場面で、効率よくプロデュースを進める事ができるようになる機能です。",
    "And of course, we couldn’t resist a quick stop at the sky bar, where work meets a moment of relaxation.",
    "プロデュース方針は場数ptを使って設定する事ができ、自分のプレイスタイルに合わせたカスタマイズが可能です。"
  ]
  
  @State private var translatedTexts = [String](repeating: "", count: 5)
  @State private var isTranslating = false
  @State private var selectedLanguageCode = "ko-KR"
  @State private var lastTranslatedLanguageCode = ""
  @State private var currentTranslatingID: Int = 0
  @State private var showTranslation = false

  // 구성 객체: 버튼으로 할당하면 translationTask에서 세션을 받음
  @State private var configuration: TranslationSession.Configuration?
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Select target language:")
        Picker("Select target language", selection: $selectedLanguageCode) {
          Text("ko-KR")
            .tag("ko-KR")
          Text("ja-JP")
            .tag("ja-JP")
          Text("en-US")
            .tag("en-US")
        }
      }
      
      List {
        Text("invalidate 또는 configuration 재정의를 이용하여 개별 문장마다 번역하기 예제")
          .bold()
        ForEach(sourceTexts.indices, id: \.self) { i in
          VStack(alignment: .leading) {
            Text(sourceTexts[i])
            Text(translatedTexts[i])
              .foregroundStyle(.gray)
            HStack {
              Button("\(selectedLanguageCode)로 번역") {
                currentTranslatingID = i
                if configuration != nil && selectedLanguageCode == lastTranslatedLanguageCode {
                  configuration?.invalidate()
                } else {
                  configuration = TranslationSession.Configuration(
                    source: nil,
                    target: Locale.Language(identifier: selectedLanguageCode)
                  )
                }
              }
              .buttonStyle(.bordered)
              Button("번역 창 열기") {
                currentTranslatingID = i
                showTranslation.toggle()
              }
              .buttonStyle(.bordered)
            }
          }
        }
      }
    }
    .onChange(of: selectedLanguageCode) {
      translatedTexts = [String](repeating: "", count: 5)
    }
    .translationPresentation(
      isPresented: $showTranslation,
      text: sourceTexts[currentTranslatingID]
    ) { result in
      // 대치 메뉴에서 할 작업
      translatedTexts[currentTranslatingID] = result
    }
    .translationTask(configuration) { session in
      // 세션 제공 시에 배치 번역 실행
      print("triggered")
      Task {
        await MainActor.run {
          translatedTexts[currentTranslatingID] = ""
          isTranslating = true
        }
        
        do {
          let response = try await session.translate(sourceTexts[currentTranslatingID])
          translatedTexts[currentTranslatingID] = response.targetText
        } catch let error as TranslationError {
          translatedTexts[currentTranslatingID] = "\(error.localizedDescription): \(error.failureReason ?? "Unknown Error")"
        }
        
        // 번역 완료되면 상태 업데이트
        await MainActor.run {
          isTranslating = false
          lastTranslatedLanguageCode = selectedLanguageCode
        }
      }
    }
  }
}
