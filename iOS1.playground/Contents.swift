import UIKit

//var str = "Hello, playground"

/*
 multiple line comment
 ----
 */

let value = arc4random_uniform(100)


// Tuple
let coordinates = (4, 6)
coordinates.0
coordinates.1

// Named Tuple
let coordinatesNamed = (x: 2, y: 3)
coordinatesNamed.x
coordinatesNamed.y

let (x, y) = coordinatesNamed
x
y

// boolean
let yes = true
let no = false

let isFourGreaterThanFive = 4 > 5

// if ~ else
if isFourGreaterThanFive {
    "TRUE"
} else {
    "FALSE"
}

let a = 5,
    b = 10

if a > b {
    "a가 크다"
} else {
    "b가 크다"
}

let name1 = "Jin"
let name2 = "Jason"

let isTwoNameSame = name1 == name2

let isJason = name2 == "Jason"
let isMale = true
let isJasonAndMale = isJason && isMale
let isJasonAndFemale = isJason && !isMale

let greetingMsg: String
if isJason {
    "Hi Jason."
} else {
    "Hi somebody."
}

name1 == "Jason" ? "Hi Jason." : "Hi somebody."

// scope
var hours = 50
let payPerHour = 10000
var salary = 0

if hours > 40 {
    let extraHours = hours - 40
    salary += extraHours * payPerHour * 2
    hours -= extraHours
}

salary += hours * payPerHour

// ==========================

var i = 0
while i < 10 {
    print(i)
    if i == 5 {
        break
    }
    i += 1
}

// do.. while
print("====== do~while ======")
i = 10
repeat {
    print(i)
    i += 1
} while i < 10

// for loop
let closedRange = 0...10 // 10까지
let halfClosedRange = 0..<10 // 9까지

var sum = 0
for i in closedRange {
    sum += i
}
sum
sum = 0
for i in halfClosedRange {
    sum += i
}
sum

var sinValue: CGFloat = 0
for i in closedRange {
    sinValue = sin(CGFloat.pi / 4 * CGFloat(i))
}

for _ in closedRange {
    "name: \(name1)"
}

//for i in closedRange {
//    if i % 2 == 0 {
//        print("짝수: \(i)")
//    }
//}

for i in closedRange where i % 2 == 0 {
    print("짝수: \(i)")
}

for i in closedRange where i != 3 {
    i
}

// 구구단
let isShowMultiTable = true
for i in 1...9 where isShowMultiTable{
    for j in 1...9 {
        print("\(i) * \(j) = \(i*j)")
    }
}


