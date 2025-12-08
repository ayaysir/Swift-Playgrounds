//
//  SetOrientation.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/7/25.
//

import SwiftUI

func setOrientation(_ orientation: UIInterfaceOrientationMask) {
  guard let windowScene = UIApplication.shared.connectedScenes
      .first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }

  // 잠금 상태 저장
  AppDelegate.orientationLock = orientation

  // 가로 고정 요청
  windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation)) { error in
    // errorHandler
    print("Orientation update error:", error.localizedDescription)
  }
}
