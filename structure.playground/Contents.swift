import UIKit

struct Location {
    let x: Int
    let y: Int
}

struct Store {
    let location: Location
    let name: String
    let deliveryRange = 2.0
    
    func isDeliverable(userLocation: Location) -> Bool {
        let distToStore = getDistance(current: userLocation, target: location)
        return distToStore <= deliveryRange
    }
}

//let store1 = (x: 3, y: 5, name: "GS")
//let store2 = (x: 4, y: 6, name: "SEVEN")
//let store3 = (x: 1, y: 7, name: "CU")

//let store1 = (location: Location(x: 3, y: 5), name: "GS")
//let store2 = (location: Location(x: 4, y: 6), name: "SEVEN")
//let store3 = (location: Location(x: 1, y: 7), name: "CU")

let store1 = Store(location: Location(x: 3, y: 5), name: "GS")
let store2 = Store(location: Location(x: 4, y: 6), name: "SEVEN")
let store3 = Store(location: Location(x: 1, y: 7), name: "CU")

func getDistance(current: Location, target: Location) -> Double {
    let distX = Double(target.x - current.x)
    let distY = Double(target.y - current.y)
    let dist = sqrt(distX * distX + distY * distY)
    return dist
}

func printClosestStore(currentLocation: Location, stores: [Store]) {
    var closestStoreName = ""
    var closestStoreDist = Double.infinity
    var isDeliverable = false
    
    for store in stores {
        let distToStore = getDistance(current: currentLocation, target: store.location)
        closestStoreDist = min(distToStore, closestStoreDist)
        if closestStoreDist == distToStore {
            closestStoreName = store.name
            isDeliverable = store.isDeliverable(userLocation: currentLocation)
        }
    }
    
    print("closest store: \(closestStoreName), isDeliverable: \(isDeliverable)")
}

let myLocation = Location(x: 2, y: 5)
let stores = [store1, store2, store3]
printClosestStore(currentLocation: myLocation, stores: stores)

// 로케이션 구조체 생성, 스토어 구조체 생성

// 클래스 vs 구조체
// 클래스: 변수 할당시 객체의 주소를 복사
// 구조체: 변수 할당시 객체 자신을 복사

// 1. 강의 이름, 강사 이름, 학생수 Struct
// 2. 강의 배열과 강사 이름을 받아 해당 강사의 강의 이름 출력하는 함수 생성
// 3. 강의 3개 만들고 강사 이름으로 강의 찾기

struct Lecture: CustomStringConvertible {
    
    // CustomStringConvertible 프로토콜에 대한 description 정의
    // compueted prperty
    var description: String {
        return "Title: \(title), Lecturer: \(lecturer)"
    }
    
    let title: String
    let lecturer: String
    let studentCount: Int
}

var lecture1 = Lecture(title: "경영학", lecturer: "김경영", studentCount: 35)
var lecture2 = Lecture(title: "마케팅", lecturer: "이홍보", studentCount: 17)
var lecture3 = Lecture(title: "회계학", lecturer: "박회계", studentCount: 21)
var lectureArr = [lecture1, lecture2, lecture3]

func printLectures(lectures: [Lecture]) {
    for lecture in lectures {
        print("\(lecture.title): \(lecture.lecturer)")
    }
}

printLectures(lectures: lectureArr)
func findLecture(lecturer: String, lectures: [Lecture]) -> Lecture? {
//    for lecture in lectures {
//        if lecturer == lecture.lecturer {
//            return lecture
//        }
//    }
//    return nil
    
    // lectures.first(where: <#T##(Lecture) throws -> Bool#>)
    // 트레일러 클로저 사용
    lectures.first() { lecture in lecture.lecturer == lecturer }
}
let foundLecture = findLecture(lecturer: "이홍보", lectures: lectureArr)
foundLecture?.lecturer

print(lecture1)
