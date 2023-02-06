import UIKit
import Darwin

var greeting = "Hello, playground"

let g1: Double = 30
let g2: Double = 36
let g3: Double = 69

ceil(g1 / 15)
ceil(g2 / 15)
ceil(g3 / 15)

var countOfEachPage: [Int] = []

for i in stride(from: 0, to: 36, by: 15) {
    print(i)
}

var ii = 36
var count = 0
while ii >= 0 {
    if ii < 15 {
        countOfEachPage.append(ii)
        break
    }
    ii = ii - 15
    countOfEachPage.append(15)
}
countOfEachPage

let numbers = [1, 2, 3, 4]
let numberSum = numbers.reduce(0, { pt, num in
    print(pt, num)
    return pt + num
})

let arr = [0, 1, 4, 6, 8, 10]
let sum = arr.reduce(0) { partialResult, currentValue in
    return partialResult + currentValue
}

let sum2 = arr.reduce(into: 0) { partialResult, currentValue in
    partialResult += currentValue
}

let xyArr = [
    ["x": 1, "y": 0],
    ["x": 2, "y": 5],
    ["x": 3, "y": 11],
]

// x 값만 더하기 (1형태)
let xSum = xyArr.reduce(0) { partialResult, currentValue in
    return partialResult +  currentValue["x"]!
}

// x 값만 더하기 (2형태)
let xSum2 = xyArr.reduce(into: 0) { partialResult, currentValue in
    partialResult +=  currentValue["x"]!
}

// x, y 각각 더하고 딕셔너리로 결과 반환 (1형태)
let xySum = xyArr.reduce(["x": 0, "y": 0]) { partialResult, currentValue in
    // partialResult["x"]! += 1
    // Left side of mutating operator isn't mutable: 'partialResult' is a 'let' constant
    
    var partialResultCopy = partialResult
    partialResultCopy["x"]! += currentValue["x"]!
    partialResultCopy["y"]! += currentValue["y"]!
    return partialResultCopy
}

// x, y 각각 더하고 딕셔너리로 결과 반환 (2형태)
let xySum2 = xyArr.reduce(into: ["x": 0, "y": 0]) { partialResult, currentValue in
    partialResult["x"]! += currentValue["x"]!
    partialResult["y"]! += currentValue["y"]!
}

let twoDimArray: [[Any]] = [[0, 4], ["x", "y"], ["zz"]]
twoDimArray.reduce([]) { partialResult, currentValue in
    return partialResult + currentValue
}

twoDimArray.reduce(into: []) { partialResult, currentValue in
    partialResult.append(currentValue)
}

print("adf")


/*
 const names = ['Alice', 'Bob', 'Tiff', 'Bruce', 'Alice', 'Alice']
 const count = names.reduce((allNames, name) => {
     if(name in allNames) {// in: v 키(key)가 allNames 객체 안에 있는지 확인
         allNames[name] += 1
     } else {
         allNames[name] = 1  // 키가 없으면 생성
     }
     
     return allNames
 }, {}) // allNames 초기값을 객체로 설정
 */

let names = ["Alice", "Bob", "Tiff", "Bruce", "Alice", "Alice", "Tiff"]

// 1형태
names.reduce([String: Int]()) { partialResult, currentValue in
    var partialResult = partialResult
    partialResult[currentValue, default: 0] += 1
    return partialResult
}

// 2형태
names.reduce(into: [String: Int]()) { partialResult, currentValue in
    partialResult[currentValue, default: 0] += 1
}

/*
 const people = [{
         name: 'Alice',
         age: 21
     },
     {
         name: 'Max',
         age: 20
     },
     {
         name: 'Jane',
         age: 20
     }
 ]
 function groupBy(people, prop) {
     return people.reduce((acc, v) => {
         const key = v[prop]
         
         if(!acc[key])   acc[key] = []
         acc[key].push(v)
         
         return acc
     }, {})
 }
 console.log(groupBy(people, "age"))
 */

struct Person {
    let name: String
    let age: Int
}

let people = [
    Person(name: "Alice", age: 21),
    Person(name: "Max", age: 20),
    Person(name: "Jane", age: 20),
]

// 1형태
people.reduce( [Int: [Person]]() ) { partialResult, currentPerson in
    var partialResult = partialResult
    partialResult[currentPerson.age, default: []].append(currentPerson)
    return partialResult
}

// 2형태
people.reduce(into: [Int: [Person]]() ) { partialResult, currentPerson in
    partialResult[currentPerson.age, default: []].append(currentPerson)
}


/*
 const friends = [{
     name: 'Anna',
     books: ['Bible', 'Harry Potter'],
     age: 21
 }, {
     name: 'Bob',
     books: ['War and peace', 'Romeo and Juliet'],
     age: 26
 }, {
     name: 'Alice',
     books: ['The Lord of the Rings', 'The Shining'],
     age: 18
 }]
 const books = friends.reduce((acc, v) => {
     return [...acc, ...v.books] // acc의 모든 원소를 나열하고, v의 books에 있는 모든 원소도 나열
 }, []
 */

struct Reader {
    let name: String
    let books: [String]
    let age: Int
}

let readers = [
    Reader(name: "Anna", books: ["Bible", "Harry Potter"], age: 21),
    Reader(name: "Bob", books: ["War and Peace", "Romeo and Juliet"], age: 21),
    Reader(name: "Anna", books: ["The Lord of the Rings", "The Shining"], age: 21),
]

// 1형태
readers.reduce([]) { partialResult, currentReader in
    return partialResult + currentReader.books
}

// 2형태
readers.reduce(into: []) { partialResult, currentReader in
    partialResult += currentReader.books
}


/*
 const dArr = [1, 2, 1, 6, 2, 2, 3, 5, 4, 5, 3, 4, 4, 7, 4, 4]
 const result = dArr.sort().reduce((acc, v) => {
     const len = acc.length
     // acc 배열의 길이가 0이거나, acc 배열의 마지막 원소가 현재 원소랑 같지 않다면
     if(len === 0 || acc[len - 1] !== v) {
         acc.push(v)
     }
     return acc
 }, [])
 console.log(result)
 */

let numArr = [1, 2, 1, 6, 2, 2, 3, 5, 4, 5, 3, 4, 4, 7, 4, 4]

// 1형태
numArr.sorted().reduce([Int]()) { partialResult, currentValue in
    
    var partialResult = partialResult
    
    // partialResult 배열의 길이가 0이거나, partialResult 배열의 마지막 원소가 현재 원소랑 같지 않다면
    if(partialResult.count == 0 || partialResult[partialResult.count - 1] != currentValue) {
        partialResult.append(currentValue)
    }
    
    return partialResult
}

// 2형태
numArr.sorted().reduce(into: [Int]()) { partialResult, currentValue in
    
    // partialResult 배열의 길이가 0이거나, partialResult 배열의 마지막 원소가 현재 원소랑 같지 않다면
    if(partialResult.count == 0 || partialResult[partialResult.count - 1] != currentValue) {
        partialResult.append(currentValue)
    }
}

Set(numArr).sorted()

// ========================== //


func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let temporaryA = a
    a = b
    b = temporaryA
}

var someInt = 3
var anotherInt = 107
swapTwoInts(&someInt, &anotherInt)
print("someInt:", someInt, "anotherInt:", anotherInt)

func swapTwoValues<UInt8>(_ a: inout UInt8, _ b: inout UInt8) {
    let temporaryA = a
    a = b
    b = temporaryA
}

var someString = "Javelin"
var anotherString = "Stinger"
swapTwoValues(&someString, &anotherString)
print(someString, ":", anotherString)
// 결과: Stinger : Javelin

var someDouble = 1338.4434
var anotherDouble = 4.7237
swapTwoValues(&someDouble, &anotherDouble)
print(someDouble, ":", anotherDouble)
// 결과: 4.7237 : 1338.4434

// struct IntStack {
//     var items: [Int] = []
//     mutating func push(_ item: Int) {
//         items.append(item)
//     }
//     mutating func pop() -> Int {
//         return items.removeLast()
//     }
// }
//
// var intStack = IntStack(items: [3, 6, 2, 7])
// intStack.push(199848)
// intStack.items // [3, 6, 2, 7, 199848]
// intStack.pop()
// intStack.pop()
// intStack.items // [3, 6, 2]






func findIndex(ofString valueToFind: String, in array: [String]) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

let strings = ["cat", "dog", "llama", "parakeet", "terrapin"]
if let foundIndex = findIndex(ofString: "llama", in: strings) {
    print("llama의 인덱스는 \(foundIndex)번째입니다.")
}
// 결과: llama의 인덱스는 2번째입니다.

func findIndex<T: Equatable>(of valueToFind: T, in array:[T]) -> Int? {
    for (index, value) in array.enumerated() {
        // 컴파일 오류: Binary operator '==' cannot be applied to two 'T' operands
        if value == valueToFind {
            return index
        }
    }
    return nil
}

let doubleIndex = findIndex(of: 9.3, in: [3.14159, 0.1, 0.25])
// 9.3은 in 배열에 없으므로 doubleIndex는 nil이 반환됩니다.

let stringIndex = findIndex(of: "Andrea", in: ["Mike", "Malcolm", "Andrea"])
// Andrea는 in 배열 2번 인덱스에 있으므로 stringIndex 2가 반환됩니다.


struct IntStack: Container {
    // original IntStack implementation
    var items: [Int] = []
    mutating func push(_ item: Int) {
        items.append(item)
    }
    mutating func pop() -> Int {
        return items.removeLast()
    }
    // conformance to the Container protocol
    // typealias Item = Int
    mutating func append(_ item: Int) {
        self.push(item)
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Int {
        return items[i]
    }
}

var intStack = IntStack(items: [3, 6, 2, 7])
intStack.push(199848)
intStack.items // [3, 6, 2, 7, 199848]
intStack.pop()
intStack.pop()
intStack.items // [3, 6, 2]

struct StringStack: Container {
    // original IntStack implementation
    // var items: [String] = []
    // mutating func push(_ item: String) {
    //     items.append(item)
    // }
    // mutating func pop() -> String {
    //     return items.removeLast()
    // }
    // conformance to the Container protocol
    // typealias Item = Int
    mutating func append(_ item: String) {
        // self.push(item)
    }
    var count: Int {
        return 1
    }
    subscript(i: Int) -> String {
        return "items[i]"
    }
}

// extension Array: Container {}

// struct Stack<Element> {
//     var items: [Element] = []
//     mutating func push(_ item: Element) {
//         items.append(item)
//     }
//     mutating func pop() -> Element {
//         return items.removeLast()
//     }
// }
//
// var stackOfStrings = Stack<String>()
// stackOfStrings.push("uno")
// stackOfStrings.push("dos")
// stackOfStrings.push("tres")
// stackOfStrings.push("cuatro")
// // the stack now contains 4 strings
//
// stackOfStrings.items
// // ["uno", "dos", "tres", "cuatro"]
//
// let fromTheTop = stackOfStrings.pop()
// // 팝(popped)된 fromTheTop 의 값은 "cuatro", 이후 스택은 3개의 값을 담고 있음
//
// stackOfStrings.items
// // ["uno", "dos", "tres"]
//
// extension Stack {
//     // pop 하지 않고 최상위 요소를 반환
//     var topItem: Element? {
//         return items.isEmpty ? nil : items[items.count - 1]
//     }
// }
//
// stackOfStrings.topItem // "tres"

protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
}

struct Stack<Element>: Container {
    // original Stack<Element> implementation
    var items: [Element] = []
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    // conformance to the Container protocol
    mutating func append(_ item: Element) {
        self.push(item)
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Element {
        return items[i]
    }
}

protocol SuffixableContainer: Container {
    associatedtype Suffix: SuffixableContainer where Suffix.Item == Item
    // associatedtype Suffix: SuffixableContainer
    func suffix(_ size: Int) -> Suffix
}

extension Stack: SuffixableContainer {
    func suffix(_ size: Int) -> Stack {
        var result = Stack()
        for index in (count-size)..<count {
            result.append(self[index])
        }
        return result
    }
    // SuffixableContainer의 연관 타입 Suffix는 Stack으로 추론됨.
}
var stackOfInts = Stack<Int>()
stackOfInts.append(10)
stackOfInts.append(20)
stackOfInts.append(30)
let suffix = stackOfInts.suffix(2)
// suffix contains 20 and 30
suffix.items

// 'SuffixableContainer' requires the types 'Double' and 'Float' be equivalent
// struct DoubleStack: SuffixableContainer {
//     mutating func append(_ item: Double) {}
//
//     var count: Int
//
//     subscript(i: Int) -> Double {
//         return 0.0
//     }
//
//     func suffix(_ size: Int) -> Stack<Float> {
//         return Stack<Float>()
//     }
// }

func allItemsMatch<C1: Container, C2: Container>
    (_ someContainer: C1, _ anotherContainer: C2) -> Bool
    where C1.Item == C2.Item, C1.Item: Equatable {

        // 두 컨테이너에 동일한 개수의 항목이 포함되어 있는지 확인합니다.
        if someContainer.count != anotherContainer.count {
            return false
        }

        // 항목의 각 쌍을 확인하여 동일한지 확인합니다.
        for i in 0..<someContainer.count {
            if someContainer[i] != anotherContainer[i] {
                return false
            }
        }

        // 모든 항목이 일치하므로 true를 반환합니다.
        return true
}


extension Array: Container {}

var stackOfStrings = Stack<String>()
stackOfStrings.push("uno")
stackOfStrings.push("dos")
stackOfStrings.push("tres")

var arrayOfStrings = ["uno", "dos", "tres"]

if allItemsMatch(stackOfStrings, arrayOfStrings) {
    print("All items match.")
} else {
    print("Not all items match.")
}
// Prints "All items match."

extension Stack where Element: Equatable {
    func isTop(_ item: Element) -> Bool {
        guard let topItem = items.last else {
            return false
        }
        return topItem == item
    }
}

if stackOfStrings.isTop("tres") {
    print("Top element is tres.")
} else {
    print("Top element is something else.")
}
// Prints "Top element is tres."

// struct NotEquatable { }
// var notEquatableStack = Stack<NotEquatable>()
// let notEquatableValue = NotEquatable()
// notEquatableStack.push(notEquatableValue)
// notEquatableStack.isTop(notEquatableValue)
// // Error: Referencing instance method 'isTop' on 'Stack' requires that 'NotEquatable' conform to 'Equatable'

extension Container where Item: Equatable {
    func startsWith(_ item: Item) -> Bool {
        return count >= 1 && self[0] == item
    }
}

if [9, 9, 9].startsWith(42) {
    print("Starts with 42.")
} else {
    print("Starts with something else.")
}
// Prints "Starts with something else."

extension Container where Item == Double {
    func average() -> Double {
        var sum = 0.0
        for index in 0..<count {
            sum += self[index]
        }
        return sum / Double(count)
    }
}

print([1260.0, 1200.0, 98.6, 37.0].average())
// 결과: "648.9"

// extension Container where Item == Int {
//     func average() -> Double {
//         var sum = 0.0
//         for index in 0..<count {
//             sum += Double(self[index])
//         }
//         return sum / Double(count)
//     }
// }
// extension Container where Item: Equatable {
//     func endsWith(_ item: Item) -> Bool {
//         return count >= 1 && self[count-1] == item
//     }
// }

extension Container {
    // 평균 구하기
    func average() -> Double where Item == Int {
        var sum = 0.0
        for index in 0..<count {
            sum += Double(self[index])
        }
        return sum / Double(count)
    }

    // 끝 요소 확인
    func endsWith(_ item: Item) -> Bool where Item: Equatable {
        return count >= 1 && self[count-1] == item
    }
}

let numbersInt = [1260, 1200, 98, 37]
print(numbers.average())
// 결과: "648.75"
print(numbers.endsWith(37))
// 결과: "true"


protocol Container2 {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }

    associatedtype Iterator: IteratorProtocol where Iterator.Element == Item
    func makeIterator() -> Iterator
}

extension Container2 {
    subscript<Indices: Sequence>(indices: Indices) -> [Item]
        where Indices.Iterator.Element == Int {
            var result: [Item] = []
            for index in indices {
                result.append(self[index])
            }
            return result
    }
}

-11.3 / 12.0
floor(-11.3 / 12.0)

-1 / 12.0
floor(-1 / 12.0)
