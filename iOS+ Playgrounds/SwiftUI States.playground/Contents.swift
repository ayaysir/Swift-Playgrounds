import UIKit

// 날씨 클래스: 온도를 저장한다.
class Weather: ObservableObject {
    @Published var temperature: Double
    init(temperature: Double) {
        self.temperature = temperature
    }
}

let weather = Weather(temperature: 20)

/*
 weather.temperature는 단순한 Double 타입이지만
 weather.$temperature Published<Double>.Publisher 타입으로 sink()를 사용할 수 있다.
 - sink() : closure에서 새로운 값이나 종료 이벤트에 대해 처리한다.
 - weather 인스턴스의 temperature가 변경될 때 sink의 클로저에 작성된 내용이 실행된다.
 */

//
let cancellable = weather.$temperature
    .sink() {
        print ("Temperature now: \($0)")
}

// 3초 뒤 weather.temperature 의 값을 25로 변경한다.
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
    weather.temperature = 25
}


// 출력:
// Temperature now: 20.0
// Temperature now: 25.0 (3초 후)

// class Person: ObservableObject {
//     @Published var name: String
//
//     init(name: String) {
//         self.name = name
//     }
// }
//
// let person = Person(name: "James")
// person.objectWillChange.sink {
//     print("Person's name changed: \($0)")
// }
// person.name = "Thomas"

class Contact: ObservableObject {
    @Published var name: String
    @Published var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    func haveBirthday() -> Int {
        age += 1
        return age
    }
}

let john = Contact(name: "John Appleseed", age: 24)
_ = john.objectWillChange
    .sink { _ in
        print("\(john.age) will change")
}
print(john.haveBirthday())
// Prints "24 will change"
// Prints "25"
