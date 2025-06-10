import UIKit

protocol 운영체제 {
  var 버전: String { get set }
}

struct MacOS: 운영체제 {
  var 버전: String = "macOS Sequoia"
  
  func macOS에서만_할수있음() {
    print(#function)
  }
}

struct Windows: 운영체제 {
  var 버전: String = "Windows 11"
  
  func Windows에서만_할수있음() {
    print(#function)
  }
}

// some 사용: 호출자(사용하는 사람)는 [운영체제] 프로토콜을 따르는 어떤 타입이라는 것만 알 수 있음.
// [운영체제] 프로토콜을 채택하는 구체적인 특정 타입을 반환해야 함

/*
 func 애플스토어_직원의_OS추천(게이머인가: Bool) -> some 운영체제 {
   if 게이머인가 {
     return Windows() // ❌ Branches have mismatching types 'MacOS' and 'Windows'
   } else {
     return MacOS()
   }
 }
 */

func 앱등이의_OS추천(게이머인가: Bool) -> some 운영체제 {
  if 게이머인가 {
    // return Windows() ❌
    return MacOS(버전: "게임잘되는버전") // ✅ 타입은 무조건 MacOS여야 함
  } else {
    return MacOS(버전: "아무거나")
  }
}

func 스티브발머의_OS추천(게이머인가: Bool) -> some 운영체제 {
  if 게이머인가 {
    return Windows(버전: "98, 2000, Xp")
  } else {
    return Windows(버전: "11")
  }
}

앱등이의_OS추천(게이머인가: true).버전

func makeComputer(os: some 운영체제) {
  print("컴퓨터 버전: \(os.버전)")
  
  if let os = os as? MacOS {
    os.macOS에서만_할수있음()
  } else if let os = os as? Windows {
    os.Windows에서만_할수있음()
  }
}

func makeMultiBootingComputer(oss: [some 운영체제]) {
  print(oss)
}

makeMultiBootingComputer(oss: [MacOS(버전: "1"), MacOS(버전: "2")]) // OK
// makeMultiBootingComputer(oss: [MacOS(버전: "1"), MacOS(버전: "2"), Windows(버전: "3")]) // Cannot convert value of type 'Windows' to expected element type 'MacOS'

let os1: any 운영체제 = Bool.random() ? MacOS() : Windows()
// Result values in '? :' expression have mismatching types 'MacOS' and 'Windows'
// let os2: some 운영체제 = Bool.random() ? MacOS() : Windows()

makeComputer(os: MacOS(버전: "123"))
makeComputer(os: Windows(버전: "456"))

// any

func 운영체제_버전출력(_ os: any 운영체제) {
  print("Vesion: \(os.버전)")
  
  if let os = os as? MacOS {
    os.macOS에서만_할수있음()
  } else if let os = os as? Windows {
    os.Windows에서만_할수있음()
  }
}

운영체제_버전출력(MacOS())
운영체제_버전출력(Windows())

// 버전 확인
#if swift(>=6.0)
print("현재 Swift 6.0 이상 사용 중")
#elseif swift(>=5.6)
print("현재 Swift 5.6-5.9 사용 중")
#else
print("현재 Swift 5.5 이하 사용 중")
#endif

func 아무OS반환() -> any 운영체제 {
  let os: [any 운영체제] = [
    MacOS(버전: "1"),
    MacOS(버전: "2"),
    Windows(버전: "2000")
  ]
  return os.randomElement()!
}
아무OS반환() // 예) MacOS 버전 2

// =============== @autoclosure =============== //

func logIfTrue(_ condition: @autoclosure @escaping @MainActor () -> Bool) {
  DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    if condition() { // Sending 'condition' risks causing data races
      print("✅ Condition is true")
    }
  }
}

logIfTrue({
  print("3 + 3 == 6 실행됨")
  return 3 + 3 == 6
}())
logIfTrue(2 + 2 == 4) // 자연스럽게 표현식만 전달

func logIfFalse(_ condition: Bool) {
  if !condition {
    print("❌ Condition is false")
  }
}

logIfFalse({
  print("2 + 3 == 6 실행됨")
  return 2 + 3 == 6
}())

// =============== Concurrency =============== //

// 1: class(동시성 안전하지 않음)

class UnsafeCounter: @unchecked Sendable {
  var value = 0

  func increment() {
    value += 1
  }
}

DispatchQueue.global(qos: .utility).sync {

  let uCounter = UnsafeCounter()

  let group = DispatchGroup()

  for _ in 0..<1000 {
    DispatchQueue.global().async(group: group) {
      for _ in 0..<10 {
        uCounter.increment()
      }
    }
  }

  group.notify(queue: .main) {
    print("UnsafeCounter 최종 값:", uCounter.value) // 💥 10000이 아닐 수 있음
  }
}

// 2: actor

actor SafeCounter {
  var value = 0

  func increment() {
    value += 1
  }
}

DispatchQueue.global(qos: .utility).sync {
  
  let sCounter = SafeCounter()
  let group = DispatchGroup()
  
  for _ in 0..<1000 {
    DispatchQueue.global().async(group: group) {
      for _ in 0..<10 {
        Task {
          await sCounter.increment()
        }
      }
    }
  }
  
  group.notify(queue: .main) {
    Task {
      await print("SafeCounter 최종 값:", sCounter.value) // 💥 10000이 아닐 수 있음
    }
  }
}

/*
 UnsafeCounter 최종 값: 9793, 9825 등 제각각
 SafeCounter 최종 값: 10000
 */

