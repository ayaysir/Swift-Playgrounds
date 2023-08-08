import UIKit

    struct Person {
        var name: String
        var job: String
        var age: Int

    }

protocol Mouse {
    func leftClick() -> Any
    func rightClick() -> Any
}

// 프로토콜은 가능
struct Daiso5000Mouse: Mouse {
    func leftClick() -> Any {
        return "left"
    }
    
    func rightClick() -> Any {
        return "right"
    }
}

let mouse1 = Daiso5000Mouse()
mouse1.leftClick() // left





    let person1 = Person(name: "aa", job: "neet", age: 12)
    print(person1)

var person2 = person1
person2.name = "bb"
person1.name // aa
person2.name // bb

class Computer {
    var name: String
    var cpu: String
    var ramMB: Int
    var etc: Any
    
    init(name: String, cpu: String, ramMB: Int, etc: Any) {
        self.name = name
        self.cpu = cpu
        self.ramMB = ramMB
        self.etc = etc
    }
    
    convenience init(name: String) {
        self.init(name: name, cpu: "Intel", ramMB: 1024, etc: NSObject())
    }
}

Computer(name: "ea")

//let computer1 = Computer(cpu: "Intel")
//let computer2 = computer1
//computer1.cpu = "AMD"
//computer1.cpu // AMD
//computer2.cpu // AMD



