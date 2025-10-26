//
//  CustomTranslationTriggerStartView.swift
//  study-Translation
//
//  Created by 윤범태 on 10/25/25.
//

import SwiftUI
import Translation

@available(iOS 18.0, *)
struct CustomTranslationTriggerStartView: View {
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
        ForEach(sourceTexts.indices, id: \.self) { i in
          VStack(alignment: .leading) {
            Text(sourceTexts[i])
            Text(translatedTexts[i])
              .foregroundStyle(.gray)
          }
        }
      }
      
      if #available(iOS 18.0, *) {
        HStack {
          Button {
            let targetLanguage = Locale.Language(identifier: selectedLanguageCode)
            // source, target 언어가 동일하면 트리거가 안됨 => invalidate로 재트리거 가능
            // 둘 중 하나가 이전과 다르면 재 트리거됨
            configuration = TranslationSession.Configuration(
              source: nil,
              target: targetLanguage
            )
            
          } label: {
            HStack {
              if isTranslating {
                ProgressView().scaleEffect(0.7)
              }
              let buttonText = selectedLanguageCode == lastTranslatedLanguageCode ? "\(lastTranslatedLanguageCode) 번역 완료" : "번역 시작"
              Text(isTranslating ? "번역 중..." : buttonText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(8)
          }
          .disabled(selectedLanguageCode == lastTranslatedLanguageCode)
          Button("invalidate configuration") {
            configuration?.invalidate()
          }
        }
        .padding()
        // translationTask 수식어: configuration이 설정되면 closure로 session을 받습니다.
        .translationTask(configuration) { session in
          // 세션 제공 시에 배치 번역 실행
          Task {
            await MainActor.run {
              translatedTexts = .init(repeating: "", count: 5)
              isTranslating = true
            }
            
            for i in sourceTexts.indices {
              let response = try? await session.translate(sourceTexts[i])
              translatedTexts[i] = response?.targetText ?? sourceTexts[i]
            }
            
            // 번역 완료되면 상태 업데이트
            await MainActor.run {
              isTranslating = false
              // lastTranslatedLanguageCode = selectedLanguageCode
              // configuration?.invalidate()
              configuration = nil
            }
          }
        }
      } else {
        Text("iOS 18 이상 필요")
      }
    }
  }
}

/*
 Thread 20: Fatal error: Attempted to use TranslationSession after the view it was attached to has disappeared, which is not supported. Instead of storing a TranslationSession instance outside of the .translationTask closure, trigger a .translationTask to run again on a visible view and use that TranslationSession instance.
 */
