import UIKit

// ===== Array =====

var evenNumbers: [Int] = [2, 4, 6, 8]
// let evenNumbers: Array<Int> = [2, 4, 6, 8]
// let keyword는 immutable

evenNumbers.append(10)
evenNumbers += [12, 14, 16]
evenNumbers.append(contentsOf: [18, 20])

evenNumbers.isEmpty

evenNumbers.count
let first = evenNumbers.first // Int?

if let firstElement = evenNumbers.first {
    firstElement
}

evenNumbers.min()
evenNumbers.max()

evenNumbers[0]
evenNumbers[1]

evenNumbers[0...2]

evenNumbers.contains(3)

evenNumbers.insert(0, at: 0)
evenNumbers.remove(at: 0)
// evenNumbers.removeAll()
evenNumbers

evenNumbers[0] = -2
evenNumbers

evenNumbers[0...2] = [-2, -4, -6]
evenNumbers

evenNumbers.swapAt(0, 1)

for num in evenNumbers {
    num
}

// index 포함
for (index, num) in evenNumbers.enumerated() {
    index
    num
}

// 앞/뒤의 3개 원소를 제거 후 새로운 배열에 저장
let dropFirstArray = evenNumbers.dropFirst(3)
let dropLastArray = evenNumbers.dropLast(3)
evenNumbers

// 앞/뒤 3개 원소만 가져온 새로운 배열
let prefixArray = evenNumbers.prefix(3)
let suffixArray = evenNumbers.suffix(3)
evenNumbers


// ===== Dictionary =====

var scoreDict: [String: Int] = ["Jason": 80, "Java": 90, "Jade": 95]
let scoreDict2: Dictionary<String, Int> = ["Jason": 80, "Java": 90, "Jade": 95]

scoreDict["Jerry"] // nil

if let score = scoreDict["Jason"] {
    score
} else {
    "none"
}

scoreDict.isEmpty
scoreDict.count

scoreDict["Jason"] = 50
scoreDict

scoreDict["Jerry"] = 100
scoreDict
// scoreDict2["Jerry"] = 100 // cannot assign through subscript: 'scoreDict2' is a 'let' constant
scoreDict["Jerry"] = nil
scoreDict // ["Jason": 50, "Jade": 95, "Java": 90]

for (name, score) in scoreDict {
    print("\(name): \(score)")
}

for key in scoreDict.keys {
    print(key)
}

// 1 이름, 직업, 도시
// 2 도시를 부산으로 업데이트
// 3 이름과 도시 출력하는 함수 만들기

var info: [String: String] = ["name": "Yu", "job": "student", "city": "Seoul"]
info["city"] = "Busan"

func printInfo(_ info: [String: String]) {
    print("name: " + (info["name"] ?? "unknown"))
    print("city: " + (info["city"] ?? "unknown"))
}
printInfo(info)

func printInfo2(_ info: [String: String]) {
    if let name = info["name"], let city = info["city"] {
        print(name, city)
    } else {
        print("unknown")
    }
}
printInfo2(info)

// ===== Set =====

var set1: Set<Int> = [1, 2, 3, 3, 2, 2, 3, 1]
set1.count

set1.contains(4)
set1.contains(1)

set1.insert(5)
set1.remove(3)
set1

// ===== Closure =====

// 형태 1: 기본 형태 - in 키워드를 사용하여 클로저 내부 부분을 구현
var multiplyClosure: (Int, Int) -> Int = { (a: Int, b: Int) -> Int in
    return a * b
}
multiplyClosure(2, 4)

// 형태 2: 형태 1에서 변수 타입(1급 함수: (Int, Int) -> Int)이 왼쪽 변수 타입 부분에 주어져 있으므로 오른쪽 식에서 타입을 제거하고, 소괄호도 없앤다.
var multiplyClosure2: (Int, Int) -> Int = { a, b in
    return a * b
}
multiplyClosure2(2, 4)

// 형태 3: 형태 2에서 오른쪽 식에서 변수 이름도 없애고, 순서에 따라 $0, $1, $2.. 등으로 대체, return 키워드를 생략하고 표현식(expression statement)로 대체
var multiplyClosure3: (Int, Int) -> Int = { $0 * $1 }
multiplyClosure3(2, 4)

func operationTwoNum(_ a: Int, _ b: Int, operation: (Int, Int) -> Int) -> Int {
    let result = operation(a, b)
    return result
}
operationTwoNum(6, 4, operation: multiplyClosure)

var addClosure: (Int, Int) -> Int = { $0 + $1 }
var substractClosure: (Int, Int) -> Int = { $0 - $1 }
operationTwoNum(6, 4, operation: addClosure)
operationTwoNum(6, 4, operation: substractClosure)
let divided = operationTwoNum(8, 4) { a, b in a / b } // why 2 times?
divided

let voidClosure: () -> Void = {
    print("aaa")
}
voidClosure()

// capturing values
var count = 0
let increment = {
    count += 1
}
increment()
increment()
increment()
increment()
count
