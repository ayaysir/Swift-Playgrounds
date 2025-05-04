//
//  LazyView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/4/25.
//

import SwiftUI

typealias Lazy = LazyView

/// `LazyView`는 뷰의 생성을 지연(Lazy)시키는 래퍼입니다.
///
/// SwiftUI에서는 `NavigationLink` 등의 상황에서 뷰가 미리 생성되는 것을 방지하고자 할 때
/// 이 구조체를 사용할 수 있습니다. `LazyView`는 내부적으로 전달된 클로저를 통해
/// 뷰의 실제 생성을 필요한 시점까지 늦춥니다.
///
/// 예시:
/// ```swift
/// NavigationLink(destination: LazyView(DetailView())) {
///   Text("Go to Detail")
/// }
/// ```
public struct LazyView<Content: View>: View {
  /// 실제 뷰를 생성하는 클로저입니다.
  private let build: () -> Content

  /// `LazyView`를 초기화합니다.
  /// - **`@autoclosure`란?**
  ///   - `log({ "Hello" })`를 `log("Hello")` 와 같이 줄일 수 있는 속성
  ///
  /// - Parameter build: 생성 지연을 위한 `Content` 뷰 생성 클로저.
  ///
  public init(_ build: @autoclosure @escaping () -> Content) {
    self.build = build
  }

  /// 뷰가 실제로 사용되는 시점에 `Content`를 반환합니다.
  public var body: Content {
    build()
  }
}
