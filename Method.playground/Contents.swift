import UIKit

struct Lecture {
    var title: String
    var maxStudents: Int = 10
    var numOfRegistered: Int = 0
    
    // method
    func getRemainSeat() -> Int {
        return maxStudents - numOfRegistered
    }
    
    // 내부 stored property를 변경하는 메소드 (mutating)
    mutating func enroll() {
        numOfRegistered += 1
    }
    
    static let target: String = "Anyone want to learn something."
    
    // type method
    static func getAcademyName() -> String {
        "붕어가재대학교"
    }
}

var lect = Lecture(title: "경영학")
lect.getRemainSeat()
lect.enroll()
lect.enroll()
lect.getRemainSeat()
Lecture.target
Lecture.getAcademyName()


struct Math {
    static func abs(_ value: Int) -> Int {
        if value >= 0 {
            return value
        } else {
            return -value
        }
    }
}

Math.abs(-20)

// Math 구조체를 확장하겠다
extension Math {
    // 제곱
    static func square(_ value: Int) -> Int {
        return value * value
    }
    
    static func half(_ value: Int) -> Int {
        return value / 2
    }
}

Math.square(16)
Math.half(25)

// 기본 타입에 extension 적용
extension Int {
    func passthrough() -> Int {
        return self
    }
}

10.passthrough()
