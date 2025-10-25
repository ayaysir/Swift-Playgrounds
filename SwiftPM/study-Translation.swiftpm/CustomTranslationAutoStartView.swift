//
//  SwiftUIView.swift
//  study-Translation
//
//  Created by 윤범태 on 10/25/25.
//

import SwiftUI

struct CustomTranslationAutoStartView: View {
  var sourceTexts = [
    "Translationフレームワークは大きく二つの方式で使用できます。",
    "Explore the warehouse and watch our consolidation processes in action, where everything is carefully organized to keep operations running smoothly.",
    "本機能は、プロデュース方針を決める事で、ゲーム内の様々な場面で、効率よくプロデュースを進める事ができるようになる機能です。",
    "And of course, we couldn’t resist a quick stop at the sky bar, where work meets a moment of relaxation.",
    "プロデュース方針は場数ptを使って設定する事ができ、自分のプレイスタイルに合わせたカスタマイズが可能です。"
  ]
  @State private var translatedTexts = [String](repeating: "", count: 5)
  var sourceLanguage: Locale.Language?
  var targetLanguage: Locale.Language?
  
  var body: some View {
    if #available(iOS 18.0, *) {
      List {
        ForEach(sourceTexts.indices, id: \.self) { i in
          VStack(alignment: .leading) {
            Text(sourceTexts[i])
            Text(translatedTexts[i])
              .foregroundStyle(.gray)
          }
        }
      }
      // translationTask: 뷰가 생성되면 자동으로 시작
      .translationTask(
        source: sourceLanguage,
        target: targetLanguage
      ) { session in
        Task { @MainActor in
          for i in sourceTexts.indices {
            let response = try await session.translate(sourceTexts[i])
            translatedTexts[i] = response.targetText
          }
        }
      }
    } else {
      Text("Need iOS 18.0 or later")
    }
  }
}
