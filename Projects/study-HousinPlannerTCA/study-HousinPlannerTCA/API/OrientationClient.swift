//
//  OrientationClient.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/9/25.
//

import ComposableArchitecture
import UIKit

// 1. OrientationClient 정의
struct OrientationClient {
  var set: (Orientation) -> Void
}

enum Orientation {
  case portrait
  case landscape
  case all
}

// 2. OrientationClient의 DependencyKey 등록
extension OrientationClient: DependencyKey {
  // liveValue: 실제 앱(Real app)에서 동작할 때 사용하는 값
  // - 앱 빌드해서 실제로 실행할 때, 실제 사이드 이펙트를 수행, 반드시 “진짜 동작”하는 기능이 들어가야 함
  static var liveValue: OrientationClient = OrientationClient { orientation in
    switch orientation {
    case .portrait:
      setOrientation(.portrait)
    case .landscape:
      setOrientation(.landscape)
    case .all:
      setOrientation(.all)
    }
  }
  
  // previewValue: SwiftUI Preview에서 사용하는 값
  static let previewValue = OrientationClient { _ in
    
  }
  
  // testValue: Unit Test / Reducer Test에서 사용하는 값
  static let testValue = OrientationClient { _ in
    
  }
}

// 3. DependencyValues에 등록
extension DependencyValues {
  var orientation: OrientationClient {
    get { self[OrientationClient.self] }
    set { self[OrientationClient.self] = newValue }
  }
}
