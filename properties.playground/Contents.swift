import UIKit

struct Person {
    // stored property
    var firstName: String {
        didSet { // 이름이 변경되었을 때 (oldValue)
            print(oldValue, "->", firstName)
        }
        willSet { // 이름이 변경될 때 (newValue)
            print(firstName, "->", newValue)
        }
    }
    var lastName: String
    
    // lazy property
    lazy var isPopular: Bool = {
        if fullName == "Sam Kim"  {
            return true
        } else {
            return false
        }
    }()
    
    // computed property: var 키워드만 가능
    var fullName: String {
        get {
            return "\(firstName) \(lastName)"
        }
        set {
            if let firstName = newValue.components(separatedBy: " ").first {
                self.firstName = firstName
            }
            if let lastName = newValue.components(separatedBy: " ").last {
                self.lastName = lastName
            }
        }
    }
    
    // type property (인스턴스와 무관하게 타입에 대한 프로퍼티)
    static let isAlien: Bool = false
    
}

var person = Person(firstName: "Jason", lastName: "Lee")

person.firstName
person.firstName = "James"
person.firstName
person.fullName = "Sam Kim"
person.fullName

Person.isAlien
person.isPopular


