//
//  ErrorView.swift
//  study-OnlineTCAStore
//
//  Created by 윤범태 on 6/24/25.
//

import SwiftUI

struct ErrorView: View {
  let message: String
  let retryAction: () -> Void
  
  var body: some View {
    VStack {
      Text("😕")
        .font(.system(size: 50))
      Text("")
      Text(message)
        .font(.custom("AmericanTypewriter", size: 25))
      Button(action: retryAction) {
        Text("Retry")
          .font(.custom("AmericanTypewriter", size: 25))
          .frame(width: 100, height: 30)
      }
      .buttonStyle(.borderedProminent)
    }
  }
}

#Preview {
  ErrorView(
    message: "Oops, we couldn't fetch product list",
    retryAction: {}
  )
}
