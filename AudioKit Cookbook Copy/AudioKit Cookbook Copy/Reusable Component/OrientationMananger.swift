//
//  OrientationMananger.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/19/25.
//

import Foundation

enum OrientationMask {
  case portrait
  case landscapeLeft
  case landscapeRight
  case portraitUpsideDown
  case landscape
  case all
  case allButUpsideDown
}

#if os(iOS)
import UIKit
#endif

func forceOrientation(to orientation: OrientationMask) {
  #if os(iOS)
  let mask: UIInterfaceOrientationMask = switch orientation {
  case .portrait:
      .portrait
  case .landscapeLeft:
      .landscapeLeft
  case .landscapeRight:
      .landscapeRight
  case .portraitUpsideDown:
      .portraitUpsideDown
  case .landscape:
      .landscape
  case .all:
      .all
  case .allButUpsideDown:
      .allButUpsideDown
  }
  
  // 실기기에서 보면 가로전환됨
  guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
  windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
  #endif
}
