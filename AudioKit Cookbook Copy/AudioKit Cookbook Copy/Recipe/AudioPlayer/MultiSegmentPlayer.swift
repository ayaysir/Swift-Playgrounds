//
//  MultiSegmentPlayer.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/18/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import SwiftUI

/// 현재 시스템 시간 기록
/// - 다음 프레임이나 다음 타이머 실행 시점과 비교하여 **경과 시간(delta time)**을 계산하기 위함
/// - `DispatchTime.now().uptimeNanoseconds`는 시스템이 부팅된 이후 경과한 시간(절대적인 시간)을 반환, ns -> s 로 변환
fileprivate func currentUptimeSeconds() -> TimeInterval {
  .init(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
}

class MultiSegmentPlayerConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  let player = MultiSegmentAudioPlayer()
  
  var timer: Timer!
  var timePrevious: TimeInterval = currentUptimeSeconds()
  @Published var endTime: TimeInterval = 0
  
  @Published var segments = [MockSegment]()
  // **RMS (Root Mean Square)**는 신호의 **전반적인 에너지 크기(=지속적인 평균적인 세기)**를 나타내는 통계적 측정값
  // 오디오에서는 “소리의 실제 감지되는 볼륨 크기”에 가까운 값으로 간주
  
  /// 1초에 몇 개의 RMS 프레임을 사용하지 결정
  /// - 값이 클수록 더 자주 샘플링 → 더 부드러운 시각화 가능하지만 계산량 증가
  /// - 예) 5라면, 1초당 15개의 RMS 값 계산 → 66ms마다 1프레임
  var rmsFramePerSecond: Double = 15
  /// 시각적으로 RMS 하나가 얼마나 많은 픽셀을 차지하는지에 대한 설정
  /// - RMS 데이터를 UI 타임라인 위에 표시할 때, 얼마나 촘촘히 그릴지를 결정
  var pixelsPerRMS: Double = 1
  
  @Published var isPlaying = false {
    didSet {
      if !isPlaying {
        player.stop()
      } else {
        timePrevious = currentUptimeSeconds()
        // segments를 참조하여 플레이 시작
        player.playSegments(
          audioSegments: segments,
          referenceTimeStamp: timestamp
        )
      }
    }
  }
  
  @Published var _timestamp: TimeInterval = 0
  var timestamp: TimeInterval {
    get { _timestamp }
    set {
      _timestamp = newValue.clamped(to: 0 ... endTime)
      if newValue > endTime {
        isPlaying = false
        _timestamp = 0
      }
    }
  }
  
  init() {
    createSegments()
    setEndTime()
    setAudioSessionCategoriesWithOptions()
    routeAudioToOutput()
    startAudioEngine()
    setTimer()
  }
  
  func setEndTime() {
    endTime = segments[segments.count - 1].playbackEndTime
  }
  
  func setAudioSessionCategoriesWithOptions() {
#if os(iOS)
    do {
      try AudioKit.Settings.session.setCategory(
        .playAndRecord,
        options: [.defaultToSpeaker, // 기본 출력이 수화부(earpiece)가 아닌 스피커로 자동 전환
                  .mixWithOthers, // 앱이 재생 중일 때도 다른 앱의 오디오와 섞여서 재생되도록 허용
                  .allowBluetooth, // 블루투스 헤드셋/이어폰의 SCO 오디오(전화 품질) 사용 허용
                  .allowBluetoothA2DP] // 고음질 Bluetooth A2DP 오디오 출력 허용 (음악용 블루투스 장비 지원)
      )
      try AudioKit.Settings.session.setActive(true)
    } catch {
      assertionFailure(error.localizedDescription)
    }
#elseif os(macOS)
    Log("macOS에서는 AVAudioSession 설정이 필요하지 않음")
#endif
  }
  
  func routeAudioToOutput() {
    engine.output = player
  }
  
  func startAudioEngine() {
    do {
      try engine.start()
    } catch {
      assertionFailure(error.localizedDescription)
    }
  }
  
  func setTimer() {
    timer = Timer.scheduledTimer(
      timeInterval: 0.05,
      target: self,
      selector: #selector(checkTime),
      userInfo: nil,
      repeats: true
    )
  }
  
  /// 오디오 또는 타임라인 재생 중에 실시간으로 현재 시간(timestamp)을 업데이트하는 역할을 합니다.
  /// - 주로 Timer나 CADisplayLink 등으로 주기적으로 호출되며, 경과 시간을 계산하여 재생 위치를 진행시키는 구조입니다.
  @objc func checkTime() {
    // 재생 중일 때만 시간을 진행시킴
    if isPlaying {
      // 시스템 부팅 이후 흐른 시간이라, 절대 시간은 아니지만 경과 시간 계산에는 적합
      let timeNow = currentUptimeSeconds()
      // 이전 체크 시점 이후로 얼마나 시간이 흘렀는지(delta time) 계산
      // delta time을 timestamp에 더해 현재 재생 위치를 실제 시간 흐름만큼 증가
      timestamp += (timeNow - timePrevious)
      // 다음 프레임의 delta 계산을 위해 현재 시점을 저장
      timePrevious = timeNow
    }
  }
}

extension MultiSegmentPlayerConductor {
  struct SegmentInfo {
    var url: URL
    var startDelay: TimeInterval
  }
  
  func createSegments() {
    guard let beatURL = TestAudioURLs.beat.url() else { return }
    guard let highTomURL = TestAudioURLs.highTom.url() else { return }
    guard let midTomURL = TestAudioURLs.midTom.url() else { return }
    guard let lowTomURL = TestAudioURLs.lowTom.url() else { return }
    guard let guitarURL = Bundle.main.url(
      forResource: GlobalSource.guitar.filePath,
      withExtension: nil
    ) else {
      return
    }
    
    let segmentInfos: [SegmentInfo] = [
      .init(url: beatURL, startDelay: 0),
      .init(url: highTomURL, startDelay: 1),
      .init(url: midTomURL, startDelay: 0),
      .init(url: midTomURL, startDelay: 0.5),
      .init(url: lowTomURL, startDelay: 0),
      .init(url: lowTomURL, startDelay: 0.5),
      .init(url: highTomURL, startDelay: 0),
      .init(url: guitarURL, startDelay: 1),
    ]
    
    for i in segmentInfos.indices {
      let playbackStartTime = if i == 0 {
        0.0
      } else {
        segments[i - 1].playbackEndTime + segmentInfos[i].startDelay
      }
      
      segments.append(
        try! MockSegment(
          audioFileURL: segmentInfos[i].url,
          playbackStartTime: playbackStartTime,
          rmsFramesPerSecond: rmsFramePerSecond
        )
      )
    }
  }
}

struct MultiSegmentPlayerView: View {
  @StateObject var conductor = MultiSegmentPlayerConductor()
  let playheadWidth: CGFloat = 2
  
  var body: some View {
    VStack {
      ZStack(alignment: .leading) {
        TrackView(
          segments: conductor.segments,
          rmsFramesPerSecond: conductor.rmsFramePerSecond,
          pixelsPerRMS: conductor.pixelsPerRMS
        )
        Rectangle()
          .fill(.red)
          .frame(width: playheadWidth)
          .offset(x: currentPlayPosition)
      }
      .frame(height: 200)
      .padding()
      
      PlayPauseButton
        .frame(height: 30)
      
      Text(currentTimeText)
        .padding(.top)
      
      Divider()
      
      VStack {
        Text("🔧 실행 흐름 요약")
          .font(.title2)
          .bold()
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(verbatim: """
          1.  onAppear 시 conductor.start() → 오디오 엔진 시작
          2.  Play 누르면 isPlaying = true → player.playSegments() 실행 + timestamp 시작
          3.  Timer가 checkTime()을 주기적으로 호출 → timestamp 증가
          4.  timestamp 값에 따라 플레이헤드 위치 및 시간 텍스트 실시간 갱신
          5.  RMS 파형은 TrackView에서 표시됨
          """)
        
        .multilineTextAlignment(.leading)
      }
      .padding(10)
      
      Spacer()
    }
    .navigationTitle("Multi Segment Player")
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
  }
  
  private var PlayPauseButton: some View {
    Image(systemName: conductor.isPlaying ? "pause" : "play")
      .resizable()
      .scaledToFit()
      .frame(width: 24)
      .contentShape(Rectangle())
      .onTapGesture {
        conductor.isPlaying.toggle()
      }
  }
  
  var currentTimeText: String {
    let currentTime = String(format: "%.1f", conductor.timestamp)
    let endTime = String(format: "%.1f", conductor.endTime)
    return currentTime + " of " + endTime
  }
  
  /*
   실제 예시 (예: 15 FPS, 1픽셀 당 1 RMS)
   •  pixelsPerRMS = 1, rmsFramesPerSecond = 15이면 pixelsPerSecond = 15
   •  2초가 흘렀다면 2 * 15 = 30픽셀 → currentPlayPosition = 28 (커서 폭 보정 포함)
   */
  var currentPlayPosition: CGFloat {
    let pixelsPerSecond = conductor.pixelsPerRMS * conductor.rmsFramePerSecond
    return conductor.timestamp * pixelsPerSecond - playheadWidth
  }
}

#Preview {
  MultiSegmentPlayerView()
}
