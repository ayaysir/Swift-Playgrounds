//
//  GridScrollView.swift
//  SwiftUI Scroll From Bottom To Top
//
//  Created by 윤범태 on 6/20/26.
//

import SwiftUI

/// Creates a grid scroll view.
///
/// - Parameters:
///   - columnCount: The number of columns in the grid. Default value is 3.
///   - margin: The spacing between grid items. Default value is 10
///   - content: The content of the grid.
struct GridScrollView<Content: View>: View {
  let columnCount: CGFloat
  let margin: CGFloat
  let content: Content
  
  init(
    columnCount: CGFloat = 3,
    margin: CGFloat = 10,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.columnCount = columnCount
    self.margin = margin
    self.content = content()
  }

  private var columns: [GridItem] {
    return (1...Int(columnCount)).map { _ in
      GridItem(.flexible(), spacing: margin)
    }
  }
  
  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: margin) {
        content
      }
    }
  }
}

#Preview {
  GridScrollView(columnCount: 3, margin: 20) {
    ForEach(0..<100) { i in
      Rectangle()
        .fill(.gray)
        .aspectRatio(1, contentMode: .fit)
        .overlay(Text("\(i)"))
    }
  }
}

/*
 Results:
 
 [0][1][2]
 [3][4][5]
 ...
 [96][97][98]
 [99]
 */
