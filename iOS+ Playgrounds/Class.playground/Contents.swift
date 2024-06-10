import UIKit

var str = "Hello, playground"

struct PersonStruct {
    var firstName: String
    var lastName: String
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    mutating func uppercaseName() {
        firstName = firstName.uppercased()
        lastName = lastName.uppercased()
    }
}

class Person {
    var firstName: String = ""
    var lastName: String = ""
    
    // initializer(constructor)
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    func uppercaseName() {
        firstName = firstName.uppercased()
        lastName = lastName.uppercased()
    }
}

var person1 = Person(firstName: "James", lastName: "Raynor")
var person2 = Person(firstName: "Sarah", lastName: "Kerrigan")
person2 = person1
person1.firstName = "Jacob"
person1.firstName
person2.firstName

var personStruct1 = PersonStruct(firstName: "A", lastName: "B")
var personStruct2 = personStruct1
personStruct1.firstName = "C"
personStruct1.firstName
personStruct2.firstName


/*
 Struct
 1. 두 오브젝트를 같다, 다르다로 비교해야 하는 경우
  - Point(x:y:)
 2. Copy된 객체들이 독립된 상태를 가져야 하는 경우
 3. 코드에서 오브젝트의 데이터를 여러 스레드에 걸쳐 사용할 경우
 
 Class
 1. 두 오브제트의 인스턴스 자체가 같음을 확인해야 할 때
 2. 하나의 객체가 필요하고, 여러 대상에 의해 접근되고 변경이 필요한 경우
 
 -> Struct 우선 사용
 
 */

// 처음 주어진 코드
struct Grade {
    var letter: Character
    var points: Double
    var credits: Double
}

class Pernson {
    var firstName: String
    var lastName: String

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }

    func printMyName() {
        print("My name is \(firstName) \(lastName)")
    }
}

class Student: Pernson {
    var grades: [Grade] = []
}

let a = Pernson(firstName: "A", lastName: "A")
let b = Student(firstName: "B", lastName: "B")

a.firstName
b.firstName

let math = Grade(letter: "B", points: 8.5, credits: 3)
let history = Grade(letter: "C", points: 7.5, credits: 3)
b.grades.append(math)
b.grades.append(history)
b.grades

class StudentAthelete: Student {
    var minimumTrainingTime: Int = 2
    var trainedTime: Int = 0
    var sports: [String]
    
    // 부모 클래스로부터 상속받은 뒤 init
    init(firstName: String, lastName: String, sports: [String]) {
        // super가 나중에
        // phase1
        self.sports = sports
        super.init(firstName: firstName, lastName: lastName)
        
        // phase 2
        self.train()
    }
    
    // 간략 init
    convenience init(name: String) {
        self.init(firstName: name, lastName: "", sports: [])
    }
    
    func train() {
        trainedTime += 1
    }
}

class FootballPlayer: StudentAthelete {
    var team = "FC Axios"
    
    // 오버라이드
    override func train() {
        trainedTime += 2
    }
}

var ath1 = StudentAthelete(firstName: "Bolt", lastName: "Usain", sports: ["A"])
var ath2 = FootballPlayer(firstName: "JY", lastName: "Park", sports:   ["B", "C"])
var ath3 = StudentAthelete(name: "S")
ath2.sports
ath3.firstName

ath1.grades.append(math)
ath2.grades.append(math)

// ath1.team
ath2.team

ath1.train()
ath2.train()
ath1.trainedTime
ath2.trainedTime

// Upcasting
ath1 = ath2 as StudentAthelete
ath1.printMyName() // My name is JY Park

// Downcasting
if let park = ath1 as? FootballPlayer {
    park.team
}
