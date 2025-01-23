//
//  ContentView.swift
//  ConnectToNative
//
//  Created by 윤범태 on 1/23/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("두 수의 합: \(addTwoNumbers(3, 5))") // 8
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
