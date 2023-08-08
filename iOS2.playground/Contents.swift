import UIKit

let num = 10


switch num {
case 0:
    "This is 0"
case 1...10:
    "This is between 1 and 10."
default: // Switch must be exhaustive
    "I don't know what is this."
}

let animal = "cat"

switch animal {
case "dog", "cat":
    "가축"
default:
    "야생동물"
}

let num2 = 20
switch num2 {
case _ where num2 % 2 == 0:
    "짝수"
default:
    "홀수"
}

let coords = (x: 0, y: 10)
switch coords {
case (0, 0):
    "원점"
case (let x, 0):    // x값은 아무거나
    "x axis: \(x)"
case (0, let y):
    "y axis: \(y)"
case (let x, let y) where x == y:
    "x = y (\(x), \(y))"
case (let x, let y):
    "anywhere (\(x), \(y))"
}

// ========== Function ==========

func printName(name: String) {
    print("이름은 \(name) 입니다.")
}
printName(name: "김밥")

func printMultipleOfTen(value: Int) {
    print("\(value) * 10 = \(value * 10)")
}
printMultipleOfTen(value: 5)

func printTotalPrice(가격 price: Int, 개수 count: Int) {
    print("Total price: \(price * count)")
}
printTotalPrice(가격: 1500, 개수: 5)
printTotalPrice(가격: 1500, 개수: 7)
printTotalPrice(가격: 1500, 개수: 2)
printTotalPrice(가격: 1500, 개수: 11)

func printTotalPriceWithDefault(price: Int = 1500, count: Int) {
    print("Total price: \(price * count)")
}
printTotalPriceWithDefault(count: 5)
printTotalPriceWithDefault(price: 2000, count: 5)

// 리턴값이 있는 함수
// func name(...) -> Return_Type {...}
func getTotalPrice(price: Int = 1000, count: Int) -> Int {
    return price * count
}
let calculatedPrice = getTotalPrice(count: 177)


// 1. 성, 이름을 받아서 fullName을 출력하는 함수 만들기
func printFullName(firstName: String, lastName: String) {
    print("\(firstName) \(lastName)")
}

// 2. 파라미터 제거
func printFullName(_ firstName: String, _ lastName: String) {
    print("\(firstName) \(lastName)")
} // 오버로딩 가능

// 3. return 함수
func getFullName(firstName: String, lastName: String) -> String {
    return "\(firstName) \(lastName)"
}

printFullName(firstName: "James", lastName: "Raynor")
printFullName("Sarah", "Kerrigan")
getFullName(firstName: "Edmund", lastName: "Duke")

// In-out parameter
var value = 3
func incrementAndPrint(_ value: inout Int) {
    value += 1
    print(value)
}
incrementAndPrint(&value)
// Passing value of type 'Int' to an inout parameter requires explicit '&'

// Function as a parameter
func add(_ a: Int, _ b: Int) -> Int {
    return a + b
}

func substract(_ a: Int, _ b: Int) -> Int {
    return a - b
}

var function = add
function(3, 5)
function = substract
function(4, 2)

// option + 변수명 클릭으로 변수타입 파악, 옮겨적기
func printResult(_ function: (Int, Int) -> Int, _ a: Int, _ b: Int) {
    let result = function(a, b)
    print(result)
}

printResult(add, 3, 5)
printResult(substract, 3, 5)


// ========= Optional =========

var name: String = "E"
// name = nil // 'nil' cannot assigned to type 'String'

var carName: String? = "Tesla"
carName =  nil

var celName: String?    // nil
celName = "a"

let num10 = Int("a")    // nil

//print(carName) // Expression implicitly coerced from 'String?' to 'Any'
// Forced unwrapping
// print(carName!) // Unexpectedly found nil while unwrapping an Optional value
carName = "Tesla"
print(carName!)

// Optional binding (if let)
func getCarName(carName: String?) -> String {
    if let unwrappedCarName = carName {
        return unwrappedCarName
    } else {
        return "none"
    }
}
getCarName(carName: carName)
carName = nil
getCarName(carName: carName)


// Optional binding (guard)
func printParsedInt(from: String) {
//    if let parsedInt = Int(from) {
//        print(parsedInt)
//    } else {
//        print("Cannot convert to Int.")
//    }
    guard let parsedInt = Int(from) else {
        print("Cannot convert to Int.")
        return
    }
    
    print(parsedInt)
}
printParsedInt(from: "10")
printParsedInt(from: "aAaaa")

// Nil coalescing(접합) - nil이라면 기본값
carName = "Tesla"
carName = carName ?? "----"
carName = nil
carName = carName ?? "----"

var food: String? = "치킨"

// Optional Binding
if let unwrappedFood = food {
    unwrappedFood
} else {
    "None"
}

// 함수 만들기: 입력 파라미터는 String?

func unwrapFood(food: String?) -> String {
    guard let unwrappedFood = food else {
        return "None"
    }
    return unwrappedFood
}
unwrapFood(food: food)
unwrapFood(food: nil)
