import UIKit

protocol 운영체제 {
  var 버전: String { get set }
}

struct MacOS: 운영체제 {
  var 버전: String = "macOS Sequoia"
}
struct Windows: 운영체제 {
  var 버전: String = "Windows 11"
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

앱등이의_OS추천(게이머인가: true).버전

// any

func 운영체제_버전출력(_ os: any 운영체제) {
  print("Vesion: \(os.버전)")
}

운영체제_버전출력(MacOS())
운영체제_버전출력(Windows())



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


DispatchQueue.global(qos: .utility).sync {
  class UnsafeCounter: @unchecked Sendable {
    var value = 0

    func increment() {
      value += 1
    }
  }

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

DispatchQueue.global(qos: .utility).sync {
  actor SafeCounter {
    var value = 0

    func increment() {
      value += 1
    }
  }
  
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
 UnsafeCounter 최종 값: 9793
 SafeCounter 최종 값: 10000
 */

