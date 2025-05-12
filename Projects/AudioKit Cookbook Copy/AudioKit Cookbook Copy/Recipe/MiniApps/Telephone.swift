//
//  Telephone.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/12/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SporthAudioKit
import SwiftUI

// MARK: - structs

typealias DTMFTone = (low: Double, high: Double)

struct NumberKeyInfo: Identifiable, Hashable {
  var digitString: String
  var alphanumerics: String?
  
  var id: String {
    digitString + (alphanumerics ?? "")
  }
}

class TelephoneConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  @Published var last10Digits = ""
  
  // 대기음 (vww.......)
  let dialTone = OperationGenerator {
    let dialTone1 = Operation.sineWave(frequency: 350)
    let dialTone2 = Operation.sineWave(frequency: 440)
    return mixer(dialTone1, dialTone2) * 0.3
  }
  
  //: ### 전화 벨소리 (bbb ... bbb ... bbb)
  //: 벨소리도 2초 동안 재생(hold)되는 한 쌍의 주파수이며,
  //: 6초마다 반복됩니다.
  let ringing = OperationGenerator {
    let ringingTone1 = Operation.sineWave(frequency: 480)
    let ringingTone2 = Operation.sineWave(frequency: 440)
    let ringingToneMix = mixer(ringingTone1, ringingTone2)
    
    let ringTrigger = Operation.metronome(frequency: 0.166_6) // (1/6)Hz (6초에 한번) 트리거 발생 (=> 1 / (1/6) = 6)
    let rings = ringingToneMix.triggeredWithEnvelope(
      trigger: ringTrigger,
      attack: 0.01, // 0.01초동안 진폭 상승
      hold: 2,  // 2초간 최대 음량 유지
      release: 0.01 // 0.01초동안 음량 감소
    )
    
    return rings * 0.4
  }
  
  //: ### 통화 중 신호 (pb pb pb pb)
  //: 통화 중 신호도 비슷하지만 매개변수 집합만 다릅니다.
  let busy = OperationGenerator {
    let busySignalTone1 = Operation.sineWave(frequency: 480)
    let busySignalTone2 = Operation.sineWave(frequency: 620)
    let busySignalTone = mixer(busySignalTone1, busySignalTone2)
    
    let busyTrigger = Operation.metronome(frequency: 2) // 2초
    let busySignal = busySignalTone.triggeredWithEnvelope(
      trigger: busyTrigger, // 2Hz (1초당 2번) 트리거 발생
      attack: 0.01, // 0.01초동안 진폭 상승
      hold: 0.25, // 0.25 최대 음량 유지
      release: 0.01 // 0.01초동안 음량 감소
    )
    
    return busySignal * 0.4
  }
  
  //: ## 키 누름
  //: 모든 숫자는 사인파의 조합입니다.
  //:
  //: DTMF 톤의 표준 사양:
  var keys = [String : DTMFTone]()
  let keypad = OperationGenerator {
    let op1 = Operation.sineWave(frequency: Operation.parameters[1])
    let op2 = Operation.sineWave(frequency: Operation.parameters[2])
    let keyPressTone = op1 + op2
    
    let momentaryPress = keyPressTone.triggeredWithEnvelope(
      trigger: Operation.parameters[0], // 트리거 (1이면 시작, 0이면 정지)
      attack: 0.01, // 0.01초동안 진폭 상승
      hold: 0.1, // 0.1초 동안 유지 (hold)
      release: 0.01 // 0.01초 동안 사라짐 (release)
    )
    
    return momentaryPress * 0.04
  }
  
  func doit(key: String, state: String) {
    switch key {
    case "CALL":
      guard state == "down" else { return }
      
      busy.stop()
      dialTone.stop()
      
      if ringing.isStarted {
        ringing.stop()
        dialTone.start()
      } else {
        ringing.start()
      }
    case "BUSY":
      guard state == "down" else { return }
      
      ringing.stop()
      dialTone.stop()
      
      if busy.isStarted {
        busy.stop()
        // dialTone.start()
      } else {
        busy.start()
      }
    default:
      // 그 외 키
      guard state == "down" else {
        keypad.parameter1 = 0
        return
      }
      
      dialTone.stop()
      ringing.stop()
      busy.stop()
      
      keypad.parameter1 = AUValue(1)
      keypad.parameter2 = AUValue(keys[key]!.low)
      keypad.parameter3 = AUValue(keys[key]!.high)
      last10Digits.append(key)
      
      if last10Digits.count > 10 {
        last10Digits.removeFirst()
      }
    }
  }
  
  init() {
    keys["1"] = DTMFTone(low: 697, high: 1209)
    keys["2"] = DTMFTone(low: 697, high: 1336)
    keys["3"] = DTMFTone(low: 697, high: 1477)
    keys["4"] = DTMFTone(low: 770, high: 1209)
    keys["5"] = DTMFTone(low: 770, high: 1336)
    keys["6"] = DTMFTone(low: 770, high: 1477)
    keys["7"] = DTMFTone(low: 852, high: 1209)
    keys["8"] = DTMFTone(low: 852, high: 1336)
    keys["9"] = DTMFTone(low: 852, high: 1477)
    keys["*"] = DTMFTone(low: 941, high: 1209)
    keys["0"] = DTMFTone(low: 941, high: 1336)
    keys["#"] = DTMFTone(low: 941, high: 1477)
    
    keypad.start()
    engine.output = Mixer(dialTone, ringing, busy, keypad)
  }
}

struct TelephoneView: View {
  @StateObject private var conductor = TelephoneConductor()
  @State private var currentDigit = ""
  
  let columns = Array(
    repeating: GridItem(.flexible(), spacing: 20),
    count: 3
  )
  
  let numberKeyInfos: [NumberKeyInfo] = [
    .init(digitString: "1"),
    .init(digitString: "2", alphanumerics: "A B C"),
    .init(digitString: "3", alphanumerics: "D E F"),

    .init(digitString: "4", alphanumerics: "G H I"),
    .init(digitString: "5", alphanumerics: "J K L"),
    .init(digitString: "6", alphanumerics: "M N O"),

    .init(digitString: "7", alphanumerics: "P Q R S"),
    .init(digitString: "8", alphanumerics: "T U V"),
    .init(digitString: "9", alphanumerics: "W X Y Z"),

    .init(digitString: "*"),
    .init(digitString: "0"),
    .init(digitString: "#")
  ]
  
  private func formattedPhoneNumber(_ digits: String) -> String {
    digits == "" ? " " : digits
  }
  
  private var mainBody: some View {

    VStack {
      Text(formattedPhoneNumber(conductor.last10Digits))
        .font(.largeTitle)
      
      LazyVGrid(columns: columns, spacing: 20) {
        ForEach(numberKeyInfos) { info in
          NumberKey(keyInfo: info)
        }

        BusyKey()
        PhoneKey()
        DeleteKey()
      }
      .padding(30)
    }
    .padding()
  }
  
  var body: some View {
    mainBody
      .navigationTitle("Telephone")
      .onAppear {
        conductor.start()
      }
      .onDisappear {
        conductor.stop()
      }
  }
}

extension TelephoneView {
  func NumberKey(keyInfo: NumberKeyInfo) -> some View {
    let stack = ZStack {
      Circle()
        .foregroundStyle(
          Color(
            red: 0.5,
            green: 0.5,
            blue: 0.5,
            opacity: 0.4
          )
        )
      VStack {
        Text(keyInfo.digitString)
          .font(.largeTitle)
        if let alphanumerics = keyInfo.alphanumerics {
          Text(alphanumerics)
        } else {
          Text("")
        }
      }
    }
      .gesture(
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
          .onChanged { _ in
            if currentDigit != keyInfo.digitString {
              conductor.doit(key: keyInfo.digitString, state: "down")
              currentDigit = keyInfo.digitString
            }
          }
          .onEnded { _ in
            conductor.doit(key: keyInfo.digitString, state: "up")
            currentDigit = ""
          }
      )
    
    let stackOverlapped = ZStack {
      stack
        .colorInvert()
        .opacity(keyInfo.digitString == currentDigit ? 1 : 0)
      stack
        .opacity(keyInfo.digitString == currentDigit ? 0 : 1)
    }
    
    return stackOverlapped
  }
  
  func PhoneKey() -> some View {
    return ZStack {
      Circle()
        .foregroundStyle(.green)
        .opacity(0.8)
      Image(systemName: "phone.fill")
        .font(.largeTitle)
    }
    .gesture(
      DragGesture(minimumDistance: 0, coordinateSpace: .local)
        .onChanged { _ in
          if conductor.last10Digits.count > 0 {
            conductor.doit(key: "CALL", state: "down")
          }
        }.onEnded { _ in
          conductor.doit(key: "CALL", state: "up")
        }
    )
  }
  
  // 빨간색 종료 버튼
  func BusyKey() -> some View {
    return ZStack {
      Circle()
        .foregroundStyle(.red)
        .opacity(0.8)
      Image(systemName: "phone.down.fill")
        .font(.largeTitle)
    }
    .gesture(
      DragGesture(minimumDistance: 0, coordinateSpace: .local)
        .onChanged { _ in
          conductor.doit(key: "BUSY", state: "down")
        }.onEnded { _ in
          conductor.doit(key: "BUSY", state: "up")
        }
    )
  }
  
  func DeleteKey() -> some View {
    return ZStack {
      Circle()
        .foregroundStyle(.blue)
        .opacity(0.8)
      Image(systemName: "delete.left.fill")
        .font(.largeTitle)
    }
    .gesture(
      DragGesture(minimumDistance: 0, coordinateSpace: .local)
        .onEnded { _ in
          if conductor.last10Digits.count > 0 {
            conductor.last10Digits.removeLast()
          }
        }
    )
  }
}

#Preview {
  TelephoneView()
}
