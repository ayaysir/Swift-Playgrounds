//
//  GyroShaderUIDemo.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/12/25.
//


import SwiftUI

#if os(iOS)
import CoreMotion

class MotionManager: ObservableObject {
  private var motionManager = CMMotionManager()
  @Published var pitch: Double = 0.0
  @Published var roll: Double = 0.0
  
  init() {
    motionManager.deviceMotionUpdateInterval = 1/60
    motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
      guard let motion = motion else { return }
      self.pitch = motion.attitude.pitch
      self.roll = motion.attitude.roll
    }
  }
}

struct GyroShaderUIDemoView: View {
  @StateObject var motion = MotionManager()
  
  var body: some View {
    ZStack {
      Color.black.edgesIgnoringSafeArea(.all)
      RoundedRectangle(cornerRadius: 30)
        .fill(LinearGradient(
          gradient: Gradient(colors: [.blue, .purple]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing))
        .frame(width: 300, height: 300)
        .rotation3DEffect(
          .degrees(motion.pitch * 20),
          axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(
          .degrees(motion.roll * 20),
          axis: (x: 0, y: 1, z: 0))
        .padding(100) // 💡 충분한 여유 공간 추가
        .drawingGroup(opaque: false, colorMode: .extendedLinear)
    }
    .modifier(ExtendedRangeViewModifier())
  }
}

struct ExtendedRangeViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    content.background(ExtendedRangeBackground())
  }
}

struct ExtendedRangeBackground: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.layer.wantsExtendedDynamicRangeContent = true
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
  GyroShaderUIDemoView()
}

#elseif os(macOS)
struct GyroShaderUIDemoView: View {
  var body: some View {
    Text("macOS에서는 지원하지 않습니다.")
  }
}
#endif

/*
 https://www.notion.so/UI-20c6402b0516805a9ec5f4222d1645db
 
 # 센서 기반 몰입형 UI (코드 공유용)

 ## 📌 개요 요약

 요즘 주목받는 센서 기반 몰입형 UI 사례를 공유드립니다.
 기기의 기울임이나 움직임에 따라 인터페이스가 반응하는 방식으로, 특히 프리미엄 서비스 유도 화면에서 사용자의 시선을 강하게 끄는 데 효과적입니다. 버튼에 적용할 경우 플랫한 버튼보다 훨씬 더 강한 인상을 줄 수 있을 것으로 보입니다.

 ---

 ## 🛠 구현 구성 요소 (SwiftUI + Core Motion + Metal)

 1. **Core Motion으로 기울기 값 수집**
     - CMMotionManager 사용
 2. **SwiftUI에서 실시간 바인딩 & 3D 회전 적용**
     - `rotation3DEffect`로 pitch, roll 적용
 3. **색공간 고급 설정 및 메탈 효과 적용**
     - `.drawingGroup(opaque: false, colorMode: .extendedLinear)`
     - `window.layer.wantsExtendedDynamicRangeContent = true`
 4. **ExtendedRangeViewModifier 적용**
     - HDR 화면을 위한 UIKit layer 접근
 
 ## 🔍 구현 난이도 및 팁

 - **난이도**: 5점 만점 기준 **4.0점**
 - **소요 시간**: 경험자 기준 2~3일 내 구현 가능
 - **Metal 셰이더까지 확장 시**: 난이도 4.5점 이상

 **실전 적용 시 유의사항**

 - HDR 관련 설정은 시뮬레이터보다 실기기에서 정확히 확인해야 합니다
 - iPhone의 회전 센서 민감도는 제한적이므로, pitch/roll 값을 적절히 곱해서 회전 폭 조절 필요

 ---

 ## 🧪 확장 아이디어

 - 입장 전 카드 UI → 콘텐츠 위 상단 티저 영역으로 확장
 - ‘카드 뒤집기’, ‘조명 따라 움직이는 버튼’ 등 인터랙션 응용
 - 사용자 반응 데이터 기반 AB테스트 (플랫 vs 몰입형 UI 비교)
 */
