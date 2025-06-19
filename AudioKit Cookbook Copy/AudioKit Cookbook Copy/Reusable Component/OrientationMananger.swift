//
//  OrientationMananger.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/19/25.
//

import UIKit

func forceOrientation(to orientation: UIInterfaceOrientationMask) {
  // 실기기에서 보면 가로전환됨
  guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
  windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
}
