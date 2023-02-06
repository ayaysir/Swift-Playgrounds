import UIKit

var greeting = "Hello, playground"

func getPoint(somePoint: (Int, Int)) {
    switch somePoint {
    case (0, 0):
        print("\(somePoint) is at the origin")
    case (_, 0):
        print("\(somePoint) is on the x-axis")
    case (0, _):
        print("\(somePoint) is on the y-axis")
    case (-2...2, -2...2):
        print("\(somePoint) is inside the box")
    default:
        print("\(somePoint) is outside of the box")
    }
}

getPoint(somePoint: (0, 0))
getPoint(somePoint: (3, 0))
getPoint(somePoint: (0, 124))
getPoint(somePoint: (1, 3))
getPoint(somePoint: (1, 2))

func getPoint2(somePoint:(Int,Int))
{
    switch somePoint
    {
    case (0, 0):
        print("\(somePoint) is at the origin")
    case (let x, 0):
        print("on the x-axis with an x value of \(x)")
    case (0, let y):
        print("on the y-axis with an y value of \(y)")
    case (-2...2, -2...2):
        print("\(somePoint) is inside the box")
    default:
        print("\(somePoint) is outside of the box")
    }
}

getPoint2(somePoint: (0, 0))
getPoint2(somePoint: (3, 0))
getPoint2(somePoint: (0, 124))
getPoint2(somePoint: (1, 3))
getPoint2(somePoint: (1, 2))

func wherePoint(point:(Int,Int))
{
    switch point
    {
    case let (x, y) where x == y:
        print("(\(x), \(y)) is on the line x == y")
    case let (x, y) where x == -y:
        print("(\(x), \(y)) is on the line x == -y")
    case let (x, y):
        print("(\(x), \(y)) is just some arbitrary point")
    }
}

wherePoint(point: (3, 3))
wherePoint(point: (3, -3))
wherePoint(point: (3, 2))


enum JustError: Error {
    case fatalError
}

func justError(_ throwError: Bool) throws {
    if throwError {
        throw JustError.fatalError
    } else {
        return
    }
}

func justErrorWithValue(_ throwError: Bool) throws -> String {
    if throwError {
        throw JustError.fatalError
    } else {
        return "1234567"
    }
}

let result = Result {
    try justError(false)
}

let result2 = Result {
    try justErrorWithValue(false)
}

switch result2 {
case .success(let data):
    print("success", data)
case .failure(let error):
    print("failed", error)
}

switch result2 {
  case let .success(data):
    print("success", data)
  case let .failure(error):
    print("failed", error)
}

if case let .success(data) = result {
    print("success", data)
}

if case .success(let data) = result {
    print("success", data)
}

let scores = (1...10).map { _ in Int.random(in: 1...10) }
for case let score in scores where score > 4 {
    score
}

func dateString(timestamp: Int) -> String {
    
    print(timestamp)
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    formatter.timeZone = .autoupdatingCurrent
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timezoneAbbr = TimeZone.abbreviationDictionary.first { $1 == formatter.timeZone.identifier }
    print(formatter.string(from: date) + " (\(timezoneAbbr?.key ?? "Unknown"))")
    print(formatter.string(from: date) + " (\(timezoneAbbr?.value ?? "Unknown"))")
    // timezoneAbbr?.value는 Asia/Seoul, timezoneAbbr?.key는 KST로 표시
    // .value는 timeZone.identifier와 동일
    return formatter.string(from: date) + " (\(timezoneAbbr?.value ?? "Unknown"))"
}

dateString(timestamp: 1655192817)

