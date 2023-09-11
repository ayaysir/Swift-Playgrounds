import UIKit

let i1 = [[60, 50], [30, 70], [60, 30], [80, 40]]
let i2 = [[10, 7], [12, 3], [8, 15], [14, 7], [5, 15]]
let i3 = [[14, 4], [19, 6], [6, 16], [18, 7], [7, 11]]

func solution(_ sizes:[[Int]]) -> Int {
    /*
     10 7
     12 3
     8 15
     14 7
     5 15
     =>
     7 10
     3 12
     8 15
     7 14
     5 15
     =====
     14 4
     19 6
     6 16
     18 7
     7 11
     =>
     4 14
     6 19
     6 16
     7 18
     7 11

     오름차순으로 정렬 후 각 라인에서 가장 큰 값들을 곱함
     */
    var maxInSmalls: Int = 0
    var maxInLarges: Int = 0
    
    for size in sizes {
        let small = min(size[0], size[1])
        let large = max(size[0], size[1])
        
        maxInSmalls = max(small, maxInSmalls)
        maxInLarges = max(large, maxInLarges)
    }
    
    return maxInSmalls * maxInLarges
}
solution(i1)
solution(i2)
solution(i3)

func moigosa(_ answers: [Int]) -> [Int] {
    var scores = [0, 0, 0]
    var patterns = [
        [1, 2, 3, 4, 5],
        [2, 1, 2, 3, 2, 4, 2, 5],
        [3, 3, 1, 1, 2, 2, 4, 4, 5, 5],
    ]
    
    for (index, answer) in answers.enumerated() {
        for (pIndex, pattern) in patterns.enumerated() {
            if pattern[index % pattern.count] == answer {
                scores[pIndex] += 1
            }
        }
    }
    
    let maxScore = scores.max()
    
    return scores.enumerated().compactMap { (index, score) in
        maxScore == score ? index + 1 : nil
    }
}

let supo1 = [1,2,3,4,5]
let supo2 = [1,3,2,4,2]

moigosa(supo1)
moigosa(supo2)


func permute<T>(_ a: [T], _ n: Int) -> [[T]] {
    if n == 0 {
        return [a]
    }
    var a = a
    var ret = permute(a, n - 1)
    for i in 0..<n {
        a.swapAt(i, n)
        ret += permute(a, n - 1)
        a.swapAt(i, n)
    }
    return ret
}

// 소수: 1과 자기 자신 만을 약수로 가지는 수들을 소수, 0과 1은 소수가 아님
func findPrime(_ numbers: String) -> Int {
    let oneDigitPrime = [2, 3, 5, 7].map(String.init)
    if numbers.count == 1 {
        if oneDigitPrime.contains(numbers) {
            return 1
        } else {
            return 0
        }
    }
    
    // 최대 자릿수 구하기
    let digit = numbers.count
    
    // 가능한 소수 모두 구하기
    // (소수 구할때 제곱근 이상이면 소수, 서로소가 아니라고 증명되었다.)
    let maxNumber = NSDecimalNumber(decimal: pow(10, digit)).intValue - 1
    let possibleAllPrimes = oneDigitPrime + (11...maxNumber).filter { number in
        var divided: [Int] = []
        for i in 1...maxNumber {
            if number % i == 0 {
                divided.append(number)
            }
        }
        
        return divided.count == 2
    }.map(String.init)
    
    let numberFilteredPrimes = possibleAllPrimes.filter { primeString in
        
        // var isContainAllNumber = true
        // for char in primeString {
        //     var isAtLeastContainOneNumber = false
        //     for number in numbers {
        //         isAtLeastContainOneNumber = isAtLeastContainOneNumber || char == number
        //     }
        //     isContainAllNumber = isContainAllNumber && isAtLeastContainOneNumber
        // }
        // print(primeString, isContainAllNumber)
        
        return primeString.map { primeChar in
            numbers.contains(primeChar)
        }.allSatisfy { $0 }
    }
    
    
    
    let d = numberFilteredPrimes.filter { f in
        print(f, possibleAllPrimes.contains(f))
        return possibleAllPrimes.contains(f)
    }
    
    
    return 0
}

findPrime("17")
// findPrime("011")

func correctBracket실패(_ s:String) -> Bool {
    var sArr = s.map(String.init)
    
    if sArr.count == 0 || sArr.count % 2 == 1
        || sArr[0] == ")" || (sArr[sArr.count - 1] == "(") {
        return false
    }
    
    var leftStack: [String] = Array(sArr.reversed())
    var rightStack: [String] = []
    
    while leftStack.count > 0 {
        guard let popped = leftStack.popLast() else {
            return false
        }
        
        if rightStack.count >= 1 && popped == ")" {
            if let rightLast = rightStack.last {
                
                if !leftStack.isEmpty {
                    if let rightPopped = rightStack.popLast(), rightPopped == "(" {
                        continue
                    } else {
                        return false
                    }
                }
            }
        }
        
        rightStack.append(popped)
    }

    return sArr.filter({ $0 == "(" }).count == sArr.count / 2
}

func correctBracket(_ s: String) -> Bool {
    var stack: [String] = []
    var sArr = s.map(String.init)
    
    for i in 0..<s.count {
        if sArr[i] == "(" {
            stack.append("(")
        } else {
            if stack.isEmpty {
                return false
            }
            
            stack.popLast()
        }
    }
    
    return stack.isEmpty
}

correctBracket("()()")
correctBracket("(())()")
correctBracket(")()(")
correctBracket("(()(")

correctBracket("(()))")
correctBracket("(((((((")
correctBracket(")))))))))")
correctBracket("()")
correctBracket("(())")
correctBracket("(")
correctBracket(")")
correctBracket(")(")
correctBracket("((())())")

// 5, 11 ())(()
correctBracket("())(()")
/*
 
 */
correctBracket("()()()()")


func developFeature(_ progresses: [Int], _ speeds: [Int]) -> [Int] {
    if progresses.count <= 1 {
        return [progresses.count]
    }
    
    var remainDays: [Int] = []
    
    for i in 0..<progresses.count {
        let remainDay = Int(ceil(Double(100 - progresses[i]) / Double(speeds[i])))
        remainDays.append(remainDay)
    }
    
    var result: [Int] = []
    var distNum = 1
    var baseValue = 0
    
    for i in 0..<remainDays.count {
        if i == 0 {
            baseValue = remainDays[i]
            continue
        }
        
        if baseValue >= remainDays[i] {
            distNum += 1
            
            if i >= remainDays.count - 1 {
                result.append(distNum)
                // 더 이상 진행되지 않음
            }
        } else {
            result.append(distNum)
            
            if i < remainDays.count - 1 {
                distNum = 1
                baseValue = remainDays[i]
            } else {
                result.append(1)
            }
        }
    }
    
    return result
}

developFeature([93, 30, 55], [1, 30, 5])
developFeature([95, 90, 99, 99, 80, 99], [1, 1, 1, 1, 1, 1])
developFeature([96, 99, 98, 97], [1, 1, 1, 1]) // [4]
developFeature([0, 3, 0, 0, 10], [5, 96, 20, 50, 1]) // [4, 1]
developFeature([93], [1]) // [1]
developFeature([93, 30, 55, 30], [1, 30, 5, 30]) // [2, 2]

struct Priority {
    var isLocation: Bool
    var value: Int
}

// func dequeue(_ array: inout [Priority]) -> Priority? {
//     guard !array.isEmpty else {
//         return nil
//     }
//
//     let first = array[0]
//     array = Array(array.dropFirst())
//
//     return first
// }
//
//
// func process실패(_ priorities: [Int], _ location: Int) -> Int {
//     if priorities.count == 1 {
//         return 1
//     }
//
//     var queue = priorities.enumerated().map { (index, priorityValue) in
//         return Priority(isLocation: index == location, value: priorityValue)
//     }
//
//     guard var max = priorities.max() else {
//         return -99
//     }
//
//     var runnedIndex = 0
//     print(priorities)
//
//     while !queue.isEmpty {
//         let first = dequeue(&queue)
//
//         guard !queue.isEmpty else {
//             return runnedIndex
//         }
//
//         print(first, max, queue, queue.count)
//         if first["priority"]! < max {
//             // enqueue
//             queue.append(first)
//
//         } else {
//             // 실행됨
//             if currentIndex == 0 {
//                 return runnedIndex + 1
//             } else {
//                 runnedIndex += 1
//                 currentIndex -= 1
//             }
//         }
//
//
//     }
//     print(location)
//     // print(queue)
//
//     return runnedIndex
// }
//
// func process(_ priorities: [Int], _ location: Int) -> Int {
//     if priorities.count == 1 {
//         return 1
//     }
//
//
// }

func dequeue(_ array: inout [Int]) -> Int? {
    guard !array.isEmpty else {
        return nil
    }

    let first = array[0]
    array = Array(array.dropFirst())

    return first
}

func process(_ priorities: [Int], _ location: Int) -> Int {
    var queue = priorities
    var location = location
    
    var answer = 0
    
    while !queue.isEmpty {
        let max = queue.max()!
        guard let first = dequeue(&queue) else {
            return 0
        }
        location -= 1
        
        if first != max {
            queue.append(first)
            if location < 0 {
                location = queue.count - 1 // 로케이션 리셋
            }
        } else {
            answer += 1
            if location < 0 {
                break
            }
        }
    }
    
    return answer
}

process([2, 1, 3, 2], 2)
process([1, 1, 9, 1, 1, 1], 0)

func truckPassingTheBridge(_ bridge_length: Int, _ weight: Int, _ truck_weights: [Int]) -> Int {
    if truck_weights.count == 1 {
        return bridge_length + 1
    }
    
    var seconds = 0
    var sumOfBridge = 0 // 시간초과 방지용
    var truckWeightsQueue = truck_weights
    var bridge = [Int](repeating: 0, count: bridge_length)
    
    while !bridge.isEmpty {
        seconds += 1
        sumOfBridge -= bridge.removeFirst()
        
        if !truckWeightsQueue.isEmpty {
            if sumOfBridge + truckWeightsQueue[0] <= weight {
                let firstTruck = truckWeightsQueue.removeFirst()
                bridge.append(firstTruck)
                sumOfBridge += firstTruck
            } else {
                bridge.append(0)
            }
        }
    }
    
    return seconds
}


// func dequeueForSliced(_ arraySubsequence: inout Array<Int>.SubSequence) -> Int? {
//     guard !arraySubsequence.isEmpty else {
//         return nil
//     }
//
//     let first = arraySubsequence.first
//     arraySubsequence = arraySubsequence.dropFirst()
//
//     return first
// }
//
// func truckPassingTheBridge(_ bridge_length: Int, _ weight: Int, _ truck_weights: [Int]) -> Int {
//     if truck_weights.count == 1 {
//         return bridge_length + 1
//     }
//
//     var seconds = 0
//     var truckWeightsQueue = truck_weights[0..<truck_weights.count]
//     var bridge = [Int](repeating: 0, count: bridge_length)[0..<bridge_length]
//
//     while !bridge.isEmpty {
//         seconds += 1
//         dequeueForSliced(&bridge)
//
//         if !truckWeightsQueue.isEmpty {
//             let sumOfBridge = bridge.reduce(0) { $0 + $1 }
//             if sumOfBridge + truckWeightsQueue.first! <= weight {
//                 guard let firstTruck = dequeueForSliced(&truckWeightsQueue) else {
//                     return 0
//                 }
//
//                 bridge.append(firstTruck)
//             } else {
//                 bridge.append(0)
//             }
//         }
//     }
//
//     return seconds
// }


struct Queue<T> {
    private(set) var queue: [T?] = []
    private(set) var head: Int = 0

    public init() {}

    public init(_ array: [T]) {
        queue = array
    }

    public var count: Int {
        return queue.count
    }

    public var isEmpty: Bool {
        return queue.compactMap{ $0 }.isEmpty
    }

    public mutating func enqueue(_ element: T) {
        queue.append(element)
    }

    public mutating func dequeue() -> T? {
        guard head <= queue.count, let element = queue[head] else {
            return nil

        }
        queue[head] = nil
        head += 1

        if head > 50 {
            queue.removeFirst(head)
            head = 0
        }

        return element
    }

    public var first: T? {
        guard head < queue.count, let element = queue[head] else {
            return nil
        }

        return element
    }
}


// func truckPassingTheBridge(_ bridge_length: Int, _ weight: Int, _ truck_weights: [Int]) -> Int {
//     if truck_weights.count == 1 {
//         return bridge_length + 1
//     }
//
//     var seconds = 0
//     var totalWeight = 0
//     var truckCount = 0
//
//     var bridge = [Int](repeating: 0, count: bridge_length)
//
//     while truckCount < truck_weights.count {
//         seconds += 1
//         totalWeight -= bridge.removeFirst()
//
//         let currentTruckWeight = truck_weights[truckCount]
//         if currentTruckWeight + totalWeight <= weight {
//             totalWeight += currentTruckWeight
//             bridge.append(currentTruckWeight)
//
//             truckCount += 1
//         } else {
//             bridge.append(0)
//         }
//     }
//
//     print(seconds, bridge_length)
//     return seconds + bridge_length
// }

truckPassingTheBridge(2, 10, [7, 4, 5, 6])
truckPassingTheBridge(100, 100, [10])
truckPassingTheBridge(100, 100, [10, 10, 10, 10, 10, 10, 10, 10, 10, 10])

// ========================== //

struct SimplifiedDate: Comparable {
    var year: Int
    var month: Int
    var day: Int
    
    /// 비교 연산자: 나중이 더 큰것이고, 같은 날짜도 true로 침
    static func < (lhs: SimplifiedDate, rhs: SimplifiedDate) -> Bool {
        if lhs.year < rhs.year {
            return true
        } else if lhs.year == rhs.year && lhs.month < rhs.month {
            return true
        } else if lhs.year == rhs.year && lhs.month == rhs.month {
            return lhs.day < rhs.day
        } else {
            return false
        }
    }
    
}

/// 기준 날짜로부터 몇 달이 지났을 때 언제인가?
func expiredDate(from baseDate: SimplifiedDate, expireMonth: Int) -> SimplifiedDate {
    let isDayMoveBeforeMonth = baseDate.day == 1
    // 1일이고, 1월이면 전년 12월 28일로 이동해야 함
    
    // 일
    let day: Int = isDayMoveBeforeMonth ? 28 : baseDate.day - 1
    
    // 월
    let addedMonth = baseDate.month + expireMonth
    let moddedMonth = addedMonth % 12 == 0 ? 12 : addedMonth % 12
    let finalMonth = moddedMonth == 1 && isDayMoveBeforeMonth ? 12 : (isDayMoveBeforeMonth ? moddedMonth - 1 : moddedMonth)
    print(moddedMonth, finalMonth)
    
    /// 결과가 12월 31일이므로 연도를 -1 조정할 필요가 있을 때 true
    let isNeedsubstractYear = (moddedMonth == 1 && isDayMoveBeforeMonth) || (addedMonth % 12 == 0)
    
    // 연
    let dividedAddYear = addedMonth / 12
    let finalYear = baseDate.year + (isNeedsubstractYear ? dividedAddYear - 1 : dividedAddYear)
    
    return SimplifiedDate(year: finalYear, month: finalMonth, day: day)
}

expiredDate(from: .init(year: 2019, month: 12, day: 17), expireMonth: 12) // 2020.12.16
// for i in 5...12 {
//     let date = expiredDate(from: .init(year: 2020, month: 8, day: 1), expireMonth: i)
//     print(date)
// }
//
// expiredDate(from: .init(year: 2020, month: 8, day: 1), expireMonth: 5)
// expiredDate(from: .init(year: 2020, month: 8, day: 1), expireMonth: 6)
// expiredDate(from: .init(year: 2020, month: 8, day: 2), expireMonth: 5)

func privacyPeriod(_ today: String, _ terms: [String], _ privacies: [String]) -> [Int] {

    /*
     주의: 이 세계관에서 한 달은 전부 28일이다.
     */

    // 1. 날짜 스트링을 연월일로 분리

    let splittedToday = today.split(separator: ".")
    let todayDate = SimplifiedDate(year: Int(splittedToday[0])!,
                                   month: Int(splittedToday[1])!,
                                   day: Int(splittedToday[2])!)

    // 2. 약관 종류별로 분류해서 사전 생성
    let termsDict: [String: Int] = terms.reduce([String: Int]()) { dict, value in
        let splitted = value.split(separator: " ")
        var dict = dict
        dict[String(splitted[0])] = Int(splitted[1])
        return dict
    }

    // print(termsDict)

    // 3. privacies 순회하면서 약관 종류가 뭔지 파악하고, 유효기간이 지났는지 여부 파악
    var result: [Int] = []
    privacies.enumerated().forEach { (index, value) in
        let splittedValue = value.split(separator: " ")
        let splittedCollectDay = splittedValue[0].split(separator: ".")
        let collectDate = SimplifiedDate(year: Int(splittedCollectDay[0])!,
                                        month: Int(splittedCollectDay[1])!,
                                        day: Int(splittedCollectDay[2])!)
        let category = splittedValue[1]
        // print(collectDate, category)

        // 2022.05.02로부터 A(6) 유효기간이 경과했다면 언제?
        // 2022.05.02에서 달을 6 더함
        let expireDate = expiredDate(from: collectDate, expireMonth: termsDict[String(category)]!)
        // print(todayDate, expireDate, todayDate > expireDate)
        if todayDate > expireDate {
            result.append(index + 1)
        }
    }


    return result
}

privacyPeriod("2022.05.19", ["A 6", "B 12", "C 3"], ["2021.05.02 A", "2021.07.01 B", "2022.02.19 C", "2022.02.20 C"])
privacyPeriod("2020.01.01", ["Z 3", "D 5"], ["2019.01.01 D", "2019.11.15 Z", "2019.08.02 D", "2019.07.01 D", "2018.12.28 Z"])
privacyPeriod("2020.12.17", ["A 12"], ["2010.01.01 A", "2019.12.17 A"]) // [1, 2]

// =============================================================== //

// 기본 케이스는 맞는데 채점하면 실패
func delivery실패(_ cap: Int, _ n: Int, _ deliveries: [Int], _ pickups: [Int]) -> Int64 {
    var deliveries = deliveries
    var pickups = pickups
    var totalDistance = 0
    
    var remainCap = cap
    
    func moveToDeliveriesEnd() {
        // 오른쪽 끝으로 이동
        totalDistance += max(deliveries.count, pickups.count)
        while !deliveries.isEmpty {
            let lastDelv = deliveries.removeLast()
            print(#function, lastDelv)
            remainCap -= lastDelv
            print(#function, remainCap)
            if remainCap == 0 {
                remainCap = cap
                break
            } else if remainCap < 0 {
                deliveries.append(abs(remainCap))
                remainCap = cap
                break
            }
        }
    }
    
    func moveToPickupsEnd() {
        // 오른쪽 끝에서 왼쪽으로 이동
        totalDistance += pickups.count
        while !pickups.isEmpty {
            let lastPkup = pickups.removeLast()
            print(#function, lastPkup)
            remainCap -= lastPkup
            print(#function, remainCap)
            if remainCap == 0 {
                remainCap = cap
                break
            } else if remainCap < 0 {
                pickups.append(abs(remainCap))
                remainCap = cap
                break
            }
        }
    }
    
    while !deliveries.isEmpty && !pickups.isEmpty {
        // 왕복하면서, 배달 먼저, 수거 나중
        
        // 왕복 1회
        moveToDeliveriesEnd()
        moveToPickupsEnd()
    }
    
    return Int64(totalDistance)
}

func delivery(_ cap: Int, _ n: Int, _ deliveries: [Int], _ pickups: [Int]) -> Int64 {
    /*
     https://oh2279.tistory.com/147
     그리디 문제이다.

     예제 풀이를 따라 코드를 작성하면, 아마 시간초과가 발생할 것이다. n이 최대 100,000까지므로 n^2의 시간복잡도로는 문제를 풀 수 없다.

     우선, 한번에 최대한 멀리가서 멀리 있는 곳들의 작업을 먼저 끝내야지 이동횟수를 최소한으로 만들 수 있으므로 입력받은 배열들을 역순으로 뒤집어준다. 가장 먼 곳부터 탐색을 시작하는데, 배달해야 하거나 픽업해와야 할 것들이 하나라도 있으면 그곳으로 이동한다!

     어차피 한번 가면 다시 물류창고로 되돌아와야 하므로 정답에는 거리 x 2를 더해준다.

     이때 각 위치의 배달/픽업 값들에서 cap값을 빼준다. 이 연산의 결과들이 모두 음수라면 해당 위치의 배달/픽업 값이 한번에 실어 나를 수 있는 용량(=cap)보다 적은 것이므로, 오가는 길에 겸사겸사 추가적으로 배달/픽업이 가능하다는 의미이다!
     예) 수거해야할 택배상자가 2인데 cap이 4면 -2가 되고 이 2만큼 추가 적재가 가능하다

     때문에 have_to_deli, have_to_pick 값이 양수가 되기 전까진 이동이 필요 없고, 이 두 값 중 하나라도 양수가 될 때만 해당 위치로 이동해주면 된다.
     */
    
    var totalDistance = 0
   
    var reversedDelvs = Array(deliveries.reversed())
    var reversedPkups = Array(pickups.reversed())
    
    var haveToDelivery = 0
    var haveToPickup = 0
    
    for i in 0..<n {
        haveToDelivery += reversedDelvs[i]
        haveToPickup += reversedPkups[i]
        print("before:", i, haveToDelivery, haveToPickup)
        while haveToDelivery > 0 || haveToPickup > 0 {
            haveToDelivery -= cap
            haveToPickup -= cap
            totalDistance += (n - i) * 2
            print("while:", i, haveToDelivery, haveToPickup, totalDistance)
        }
    }
    
    return Int64(totalDistance)
}

delivery(4, 5, [1, 0, 3, 1, 2], [0, 3, 0, 4, 0]) // 16
// delivery(2, 7, [1, 0, 2, 0, 1, 0, 2], [0, 2, 0, 1, 0, 2, 0]) // 30
//
// delivery(2, 2, [0, 6], [0, 0]) // 12


func personalityType(_ survey: [String], _ choices: [Int]) -> String {
    // 1. 타입 점수 저장용 사전 생성
    let typeStrings = "RCJATFMN"
    var typeScoresDict = typeStrings.reduce([String: Int]()) { dict, character in
        var dict = dict
        dict[String(character)] = 0
        return dict
    }
    
    // 2. survey, choices를 순회하며 맞는 타입에 점수 추가
    for i in 0..<survey.count {
        let types = survey[i].map(String.init)
        let disagreeType = types[0]
        let agreeType = types[1]
        
        switch choices[i] {
        case 1, 2, 3:
            typeScoresDict[disagreeType]! += 4 - choices[i]
        case 5, 6, 7:
            typeScoresDict[agreeType]! += choices[i] - 4
        default:
            break
        }
    }
    
    print(typeScoresDict)
    
    // 3. 결과 출력
    var result: String = ""
    for typePair in ["RT", "CF", "JM", "AN"] {
        let types = typePair.map(String.init)
        // 왼쪽이 크거나 동점(사전순)
        if typeScoresDict[types[0]]! >= typeScoresDict[types[1]]! {
            result += types[0]
        } else {
            result += types[1]
        }
    }
    
    return result
}

personalityType(["AN", "CF", "MJ", "RT", "NA"], [5, 3, 2, 7, 5])
personalityType(["TR", "RT", "TR"], [7, 1, 3])


func craneGame(_ board: [[Int]], _ moves: [Int]) -> Int {
    var board = board
    var basket: [Int] = []
    // 터진 횟수가 아니고 없어진 인형 총 개수임
    var removedDollCount = 0
    
    for indexOneBased in moves {
        let indexZeroBased = indexOneBased - 1
        
        for j in 0..<board.count {
            if board[j][indexZeroBased] == 0 {
                continue
            }
            
            basket.append(board[j][indexZeroBased])
            board[j][indexZeroBased] = 0
            break
        }
        
        // print("basket before:", basket)
        // 바스켓 업데이트
        if basket.count >= 2 && basket[basket.count - 1] == basket[basket.count - 2] {
            basket.removeLast()
            basket.removeLast()
            removedDollCount += 2
        }
        // print("basket after:", basket)
    }
    
    return removedDollCount
}

craneGame([
    [0,0,0,0,0],
    [0,0,1,0,3],
    [0,2,5,0,1],
    [4,2,4,4,2],
    [3,5,1,3,1]
],
          [1,5,3,5,1,2,1,4])

func distance(_ pos1: (Int, Int), _ pos2: (Int, Int)) -> Int {
    // 두 점 (x1, y1), (x2, y2)의 맨해튼 거리 = |x1 - x2| + | y1 - y2 |
    return abs(pos1.0 - pos2.0) + abs(pos1.1 - pos2.1)
}
// distance((0, 1), (1, 1))
// distance((0, 1), (2, 1))
// 5 4 3 (0, 1) (2, 0) (1, 1) 1 1
distance((0, 1), (1, 1)) // 1
distance((2, 0), (1, 1)) // 2

func pressKeypad(_ numbers: [Int], _ hand: String) -> String {
    var isRightHand = hand == "right"
    var leftHandPosition: Int = 10
    var rightHandPosition: Int = 12
    var result: String = ""
    
    // zero-based
    var positions: [(Int, Int)] = [
        (1, 3),
        (0, 0), (1, 0), (2, 0),
        (0, 1), (1, 1), (2, 1),
        (0, 2), (1, 2), (2, 2),
        (0, 3), (1, 3), (2, 3),
    ]
    
    for number in numbers {
        switch number {
        case 1, 4, 7:
            result += "L"
            leftHandPosition = number
        case 3, 6, 9:
            result += "R"
            rightHandPosition = number
        default:
            // 맨해튼 거리
            var distanceFromLeft = distance(positions[leftHandPosition], positions[number])
            var distanceFromRight = distance(positions[rightHandPosition], positions[number])
            // print(number, leftHandPosition, rightHandPosition, positions[leftHandPosition], positions[rightHandPosition], positions[number], distanceFromLeft, distanceFromRight)
            
            if distanceFromLeft > distanceFromRight {
                result += "R"
                rightHandPosition = number
            }
            else if distanceFromLeft < distanceFromRight {
                result += "L"
                leftHandPosition = number
            }
            else {
                // 거리가 같은 경우
                result += isRightHand ? "R" : "L"
                if isRightHand {
                    rightHandPosition = number
                } else {
                    leftHandPosition = number
                }
            }
        }
    }
    
    return result
}

pressKeypad([1, 3, 4, 5, 8, 2, 1, 4, 5, 9, 5], "right") // LRLLLRLLRRL
pressKeypad([7, 0, 8, 2, 8, 3, 1, 5, 7, 6, 2], "left") // LRLLRRLLLRR
pressKeypad([1, 2, 3, 4, 5, 6, 7, 8, 9, 0], "right") // LLRLLRLLRL

func runningRace(_ players: [String], _ callings: [String]) -> [String] {
    // 해설진이 부르면 추월 소환
    // 50000 * 1000000 = 500억으로 이중반복 불가능해 보임
    
    var players = players
    /// 플레이어 현재 인덱스 저장한 딕셔너리(해셔블)
    var playersCurrentIndexDict: [String: Int] = [:]
    
    for (index, player) in players.enumerated() {
        playersCurrentIndexDict[player] = index
    }
    
    // 호명한 순서대로 추월 처리: O(1+x)
    for calling in callings {
        let overtakePlayerIndex = playersCurrentIndexDict[calling]!
        let beOvertakedPlayer = players[overtakePlayerIndex - 1]
        
        // swapAt: O(1)
        players.swapAt(overtakePlayerIndex, overtakePlayerIndex - 1)
        playersCurrentIndexDict[calling]! -= 1
        playersCurrentIndexDict[beOvertakedPlayer]! += 1
    }
    
    return players
}

runningRace(["mumu", "soe", "poe", "kai", "mine"], ["kai", "kai", "mine", "mine"])

func receiveReport(_ id_list: [String], _ report: [String], _ k: Int) -> [Int] {
    var reporterDict: [String: [String]] = [:]
    var reporteeDict: [String: Int] = [:]
    
    for reportPair in report {
        let splitted = reportPair.split(separator: " ")
        let reporter = String(splitted[0])
        let reportee = String(splitted[1])
        
        // 신고 한 리스트: 한 유저가 같은 유저를 여러 번 신고한 경우는 신고 횟수 1회로 처리
        if reporterDict[reporter] == nil {
            reporterDict[reporter, default: []].append(reportee)
            reporteeDict[reportee, default: 0] += 1
        } else if let reportees = reporterDict[reporter], !reportees.contains(reportee) {
            reporterDict[reporter, default: []].append(reportee)
            reporteeDict[reportee, default: 0] += 1
        } // 신고 당한 리스트: 한 사람이 여러번 신고하였다면 카운트하지 않음
    }
    
    // 메일 전송 횟수
    var result: [Int] = [Int](repeating: 0, count: id_list.count)
    for (index, id) in id_list.enumerated() {
        guard let reportees = reporterDict[id] else {
            continue
        }
        
        for reportee in reportees {
            if reporteeDict[reportee]! >= k {
                result[index] += 1
            }
        }
    }
    
    return result
}

receiveReport(["muzi", "frodo", "apeach", "neo"], ["muzi frodo","apeach frodo","frodo neo","muzi neo","apeach muzi"], 2)
receiveReport(["con", "ryan"], ["ryan con", "ryan con", "ryan con", "ryan con"], 3)

func lottoWinningGrade(_ unpollutedLottos: [Int], _ win_nums: [Int]) -> Int {
    let wonCount = unpollutedLottos.compactMap { number in
        win_nums.contains(number) ? true : nil
    }.count
    
    return 7 - wonCount
}

func lottoMinMax(_ lottos: [Int], _ win_nums: [Int]) -> [Int] {
    // 예외 케이스 처리
    // 1. 전부 0인 경우 => [1, 6]
    // 2. 전부 꽉 찬 경우 => 숫자가 변할 수 없으므로 [등수, 등수]
    if lottos == [0, 0, 0, 0, 0, 0] {
        return [1, 6]
    } else if !lottos.contains(0) {
        let winCount = win_nums.compactMap { lottos.contains($0) ? true : nil }.count
        let grade = winCount > 0 ? 7 - winCount : 6
        return [grade, grade]
    }
    
    /*
     0이 1개인 경우
     당첨: 0 | ㅇ: 1 | oxxxxx [5(6), 5(7)] = 13
     당첨: 1 | ㅇ: 1 | *oxxxx [5, 5(6)] = 11
     당첨: 2 | ㅇ: 1 | **oxxx [4, 5] = 9
     당첨: 3 | ㅇ: 1 | ***oxx [3, 4] = 7
     당첨: 4 | ㅇ: 1 | ****ox [2, 3] = 5
     당첨: 5 | ㅇ: 1 | *****o [1, 2] = 3
     
     o = 1 일때 당첨 0이면 (합의) 최대값 13
     o = 2 일때 당첨 0이면 최대값 12
     o = 3 일때 당첨 0이면 최대값 11
     o = 4 일때 당첨 0이면 최대값 10
     o = 5 일때 당첨 0이면 최대값 9
     => 당첨 증가마다 합의 최대값으로부터 2 깎임
     
     최저값은 무조건 7(=>5로 대체)부터 시작, 당첨 증가시마다 1 감소
     */
    
    let zeroCount = lottos.filter { $0 == 0 }.count
    let winCount = win_nums.compactMap { lottos.contains($0) ? true : nil }.count
    print(lottos, win_nums, zeroCount, winCount)
    
    let sumOfMinMax = (14 - zeroCount) - (winCount * 2)
    let lowestGrade = 7 - winCount
    let highestGrade = sumOfMinMax - lowestGrade
    
    return [highestGrade, lowestGrade].map { $0 >= 6 ? 6 : $0 }
}

lottoMinMax([44, 1, 0, 0, 31, 25], [31, 10, 45, 1, 6, 19])
lottoMinMax([0, 0, 0, 0, 0, 0], [38, 19, 20, 40, 15, 25])
lottoMinMax([45, 4, 35, 20, 3, 9], [20, 9, 3, 45, 4, 35])

lottoMinMax([15, 27, 30, 0, 0, 0], [15, 27, 31, 12, 13, 14]) // [2, 5]
lottoMinMax([1, 2, 3, 4, 5, 6], [7, 8, 9, 10, 11, 12]) // [6, 6]

/*
 --------------------------------------
 */

func convertToBinaryArray(from decimal: Int, maxDigit: Int) -> [String] {
    let binaryString = String(decimal, radix: 2)
    return [String](repeating: "0", count: maxDigit - binaryString.count) + binaryString.map(String.init)
}

func secretMap(_ n: Int, _ arr1: [Int], _ arr2: [Int]) -> [String] {
    var mergedMap: [[String]] = [[String]](repeating: [String](repeating: " ", count: n), count: n)
    
    for i in 0..<n {
        let binaryOne = convertToBinaryArray(from: arr1[i], maxDigit: n)
        let binaryTwo = convertToBinaryArray(from: arr2[i], maxDigit: n)
        
        for j in 0..<n {
            if binaryOne[j] == "1" || binaryTwo[j] == "1" {
                mergedMap[i][j] = "#"
            }
        }
    }
    
    return mergedMap.map { $0.joined() }
}

secretMap(5, [9, 20, 28, 18, 11], [30, 1, 21, 17, 28])
secretMap(6, [46, 33, 33 ,22, 31, 50], [27 ,56, 19, 14, 14, 10])
