import SwiftUI
import Translation

struct TranslationPresententationView: View {
  @State private var textToTranslate = "Translationフレームワークは大きく二つの方式で使用できます。"
  @State private var showTranslation = false
  
  var body: some View {
    if #available(iOS 17.4, *) {
      VStack {
        Text(textToTranslate)
        Button("번역하기") {
          showTranslation.toggle()
        }
        Rectangle()
          .frame(height: 150)
          .foregroundStyle(.clear)
      }
      .translationPresentation(isPresented: $showTranslation, text: textToTranslate) { result in
        // replacement action 핸들러
        textToTranslate = result
      }
    } else {
      Text("Need iOS 17.4 or later")
    }
  }
}

