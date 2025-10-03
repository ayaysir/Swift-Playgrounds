//
//  DraftListView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/3/25.
//

import SwiftUI
import ComposableArchitecture

struct DraftListView: View {
  var body: some View {
    VStack {
      HStack {
        Text("Select a Draft")
          .font(.title2)
          .bold()
        
        Button(action: {}) {  
          Label("New Draft", systemImage: "plus")
        }
        Spacer()
        Button(action: {}) {
          Image(systemName: "xmark")
        }
      }
      
      List {
        ForEach(0..<10) { i in
          Button(action: {}) {
            Text("Cell \(i)")
          }
        }
      }
      .listStyle(.plain)
    }
    .padding()
  }
}

#Preview {
  NavigationStack {
    DraftListView()
  }
}
