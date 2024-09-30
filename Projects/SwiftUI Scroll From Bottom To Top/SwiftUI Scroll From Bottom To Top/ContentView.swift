//
//  ContentView.swift
//  SwiftUI Scroll From Bottom To Top
//
//  Created by 윤범태 on 8/8/24.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      ScrollFromBottomToTop_iOS14_View()
        .tabItem {
          Text("iOS 14 +")
        }
      
      if #available(iOS 17.0, *) {
        ScrollFromBottomToTop_iOS17_View()
          .tabItem {
            Text("iOS 17 +")
          }
      } else {
        EmptyView()
          .tabItem {
            Text("Not Available")
          }
      }
    }
  }
}

struct ScrollFromBottomToTop_iOS14_View: View {
  // 원래 보여지는(정렬된) 순서의 역순으로 된 리스트
  let reversedSomeList = Array(Array(1...100).reversed())
  
  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        LazyVStack {
          ForEach(reversedSomeList, id: \.self) { index in
            ZStack {
              RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                .frame(height: 50)
                .foregroundColor(.blue.opacity(0.1 + Double(index) * 0.009))
                .onAppear {
                  print("Displayed: Cell \(index)")
                }
              Text("Cell \(index)")
            }
            // 개별 요소를 180도로 회전 후 좌우 플립
            .rotationEffect(.degrees(180))
            .rotation3DEffect(
              .degrees(180),
              axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .onTapGesture {
              print("Tapped: Cell \(index)")
            }
          }
        }
        .frame(minHeight: proxy.size.height)
      }
      .padding()
      // 스크롤 뷰를 x축을 기준으로 180도로 회전
      .rotation3DEffect(
        .degrees(180),
        axis: (x: 1.0, y: 0.0, z: 0.0)
      )
    }
  }
}

@available(iOS 17.0, *)
struct ScrollFromBottomToTop_iOS17_View: View {
  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(1..<101) { index in
          ZStack {
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
              .frame(height: 50)
              .foregroundColor(.green.opacity(0.1 + Double(index) * 0.009))
              .onAppear {
                print("Displayed: Cell \(index)")
              }
            Text("Cell \(index)")
          }
          .onTapGesture {
            print("Tapped: Cell \(index)")
          }
        }
      }
    }
    .padding()
    // iOS 17 버전 이상부터는 아래 modifier만 추가하면 됨
    .defaultScrollAnchor(.bottom)
  }
}

#Preview {
  ContentView()
}
