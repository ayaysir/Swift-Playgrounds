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
      Text("두 수의 곱: \(multipleTwoNumbers(12, 10))")
      Text("2024년은 윤년이야? \(isLeapYear(2024))")
      Text("2025년은 윤년이야? \(isLeapYear(2025))")
      
      Divider()
      
      Text(dollarsText)
    }
    .padding()
  }
  
  var dollarsText: String {
    let dollars1 = DollarsWrapper(dollars: 10, cents: 50)
    let dollars2 = DollarsWrapper(double: 96.32)
    
    if let dollars1, let dollars2 {
      dollars1.addDollars(dollars2)
      
      return """
      Total Pennies: \(dollars1.toPennies())
      Dollars: \(dollars1.dollars())
      Cents: \(dollars1.cents())
      Formatted: \(dollars1.toString() ?? "-")
      """
    } else {
      return ""
    }
  }
}

#Preview {
  ContentView()
}
