import UIKit
import Combine

class HandsUp: Publisher {
    typealias Output = String
    // Never: The return type of functions that do not return normally, that is, a type with no values.
    typealias Failure = Never
    
    /*
     S: 제네릭 타입
     where:
      - S: Subscriber 타입을 준수
      - Never == S.Failure이어야 함
      - String == S.Input이어야 함
     
     */
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, String == S.Input {
        DispatchQueue.global(qos: .utility).async {
            let pandas: [String] = ["LeBao", "AiBao", "FuBao"]
            pandas.forEach {
                // receive: Tells the subscriber that the publisher has produced an element.
                _ = subscriber.receive($0)
            }
            
            // Tells the subscriber that the publisher has completed publishing, either normally or with an error.
            subscriber.receive(completion: .finished)
        }
    }
    
}

let handsUpPublisher = HandsUp()

_ = handsUpPublisher.sink(receiveCompletion: { _ in
    print("completed")
}, receiveValue: { panda in
    print("Panda:", panda)
})

/*
 Panda: LeBao
 Panda: AiBao
 Panda: FuBao
 completed
 */

// Combine에서 제공하는 Publisher
// 1. Future: 단일 이벤트와 종료 혹은 실패를 제공하는 publisher
let future = Future<String, Error> { promise in
    promise(.success("Future: Success"))
}

_ = future.sink(receiveCompletion: { result in
    print("Future Result:", result)
}, receiveValue: { receiveValue in
    print("receiveValue:", receiveValue)
})

/*
 receiveValue: Future: Success
 Future Result: finished
 */

let futureWithError = Future<String, Error> { promise in
    promise(.failure(NSError(domain: "Future Error", code: -1)))
}

_ = futureWithError.sink(receiveCompletion: { result in
    print("FutureWithError Result:", result)
}, receiveValue: { receiveValue in
    print("receiveValue:", receiveValue)
})

/*
 FutureWithError Result: failure(Error Domain=Future Error Code=-1 "(null)")
 */

let futureWithNever = Future<String, Never> { promise in
    promise(.success("FutureWithNever: Never"))
}
_ = futureWithNever.sink {
    print($0)
}

/*
 FutureWithNever: Never
 */


// 2. Just: 단일 이벤트 발생 후 종료
let just = Just<String>("Monika")

_ = just.sink {
    print("JustResult:", $0)
} receiveValue: {
    print($0)
}

/*
 Monika
 JustResult: finished
 */


// 3. Deferred: 구독이 이뤄질 때 publisher가 만들어질 수 있도록 하는 publisher
class PutYourHandsUp: Publisher {
    typealias Output = String
    typealias Failure = Never
    
    init() {
        Date().timeIntervalSince1970
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        DispatchQueue.global(qos: .utility).async {
            let pandas: [String] = ["LeBao", "AiBao", "FuBao"]
            pandas.forEach {
                _ = subscriber.receive($0)
            }
            
            subscriber.receive(completion: .finished)
        }
    }
}

// let putYourHandsUpPublisher = PutYourHandsUp()
// print("PutYourHandsUp Publisher Init: \(Date().timeIntervalSince1970)")
// _ = putYourHandsUpPublisher.sink(receiveValue: {
//     print("Panda:", $0)
// })

/*
 (Publisher Init: 1692027505.491494)
 PutYourHandsUp Publisher Init: 1692027505.492146
 Panda: LeBao
 Panda: AiBao
 Panda: FuBao
 */

let deferredPYHUPublisher = Deferred<PutYourHandsUp> {
    PutYourHandsUp()
}
print("Deferred Publisher Init: \(Date().timeIntervalSince1970)")
_ = deferredPYHUPublisher.sink(receiveValue: {
    print("Panda:", $0)
})

/*
 Deferred Publisher Init: 1692027749.778286
 (Publisher Init: 1692027749.778328)
 Panda: LeBao
 Panda: AiBao
 Panda: FuBao
 */


// 4. Empty: 이벤트 없이 종료
let empty = Empty<String, Never>()
_ = empty.sink(receiveCompletion: { result in
    print("Empty: receiveCompletion:", result)
}, receiveValue: { value in
    print("Empty: receiveValue:", value)
})

/*
 Empty: receiveCompletion: finished
 */


// 5. Fail: 오류와 함께 종료
let failed = Fail<String, Error>(error: NSError(domain: "Failed", code: -1))
_ = failed.sink(receiveCompletion: { result in
    print("Fail: receiveCompletion:", result)
}, receiveValue: { value in
    print("Fail: receiveValue:", value)
})

/*
 Fail: receiveCompletion: failure(Error Domain=Failed Code=-1 "(null)")
 */


// 6. Record: 입력과 완료를 기록해 다른 subscriber에서 반복될 수 있는 publisher
let record = Record<String, Error> { recording in
    print("===== Make Record ===== ")
    recording.receive("LeBao")
    recording.receive("AiBao")
    recording.receive("FuBao")
    recording.receive(completion: .failure(NSError(domain: "ㅠ", code: -1)))
}

for _ in 1...3 {
    _ = record.sink {
        print($0)
    } receiveValue: {
        print($0, terminator: "\t")
    }
}

/*
 ===== Make Record =====
 LeBao    AiBao    FuBao    failure(Error Domain=ㅠ Code=-1 "(null)")
 LeBao    AiBao    FuBao    failure(Error Domain=ㅠ Code=-1 "(null)")
 LeBao    AiBao    FuBao    failure(Error Domain=ㅠ Code=-1 "(null)")
 */

// 7. AnyPublisher
let originalPublisher = [1, nil, 3].publisher
let anyPublisher = originalPublisher.eraseToAnyPublisher()
/*
 이 게시자의 실제 유형이 아닌 다운스트림 구독자에게 AnyPublisher의 인스턴스를 노출하려면 eraseToAnyPublisher()를 사용하십시오. 이러한 유형 삭제 형식은 다른 모듈과 같은 API 경계 전체에서 추상화를 유지합니다. 게시자를 AnyPublisher 유형으로 노출하면 시간이 지남에 따라 기존 클라이언트에 영향을 주지 않고 기본 구현을 변경할 수 있습니다.
 */
anyPublisher.sink { receivedValue in
    print("AnyPublisher:", receivedValue as Any)
}

/*
 ===============================================
 */

class IntSubscriber: Subscriber {
    
    typealias Input = Int
    typealias Failure = Never
    
    //
    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }
    
    // Demand: 요구 횟수
    func receive(_ input: Int) -> Subscribers.Demand {
        print("Received Value:", input)
        // .max(n): Creates a demand for the given maximum number of elements.
        // The publisher is free to send fewer than the requested maximum number of elements.
        return .max(1)
        
        /*
         .max(1): Publisher에게 한 번 더 달라고 요청
         .none: Publisher에게 값 더이상 안줘도 된다고 알림
         .unlimited: Publisher에게 끝없이 값을 달라고 요청
         */
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Received completion: \(completion)")
    }
}

let intArray: [Int] = [1, 2, 3, 4, 5]
let intSubscriber = IntSubscriber()

intArray.publisher.subscribe(intSubscriber)

// Combine을 사용할 때 주의할 점은 Publisher의 <Output, Failure> 타입과 Subscriber의 <Input, Failure> 타입이 동일해야 한다는 것!입니다. 이게 다르면 Publisher와 Subscriber는 서로 값을 주고받지 못합니다.


// AnyCancellable
let subject1 = PassthroughSubject<Int, Never>()
let anyCancellable1 = subject1
    .handleEvents(receiveCancel: {
        print("Subject 1 is cancelled.")
    })
    .sink { completion in
        print("received completion: \(completion)")
    } receiveValue: { value in
        print("received value: \(value)")
    }

subject1.send(1)
anyCancellable1.cancel()
subject1.send(2)

// sink는 Subscriber를 만들고 바로 request 하는 operator입니다.

/*
 1. Publisher는 값이나 completion event를 Subscriber에게 전달합니다.
 2. Subsriber는 Subscription을 통해 Publisher에게 값을 요청합니다.
 3. Subscription은 Publisher와 Subscriber 사이를 연결합니다.
 4. Subscription은 cancel()을 통해 취소할 수 있으며 이때 호출될 클로저를 설정할 수 있습니다.
 */

let anyPublisher1 = [1, nil, 3].publisher
    .flatMap { value -> AnyPublisher<Int, Never> in
        if let value {
            return Just(value).eraseToAnyPublisher()
        }
        
        return Empty().eraseToAnyPublisher()
    }.eraseToAnyPublisher()

anyPublisher1.sink {
    print("AnyPublisher completion: \($0)")
} receiveValue: {
    print("value: \($0 as Any)")
}

/*
 ========= Subject =========
 */

// 1. Current Value Subject
let currentValueSubject = CurrentValueSubject<String, Never>("1")
currentValueSubject
    .sink { completion in
        print("1 번째 sink completion: \(completion)")
    } receiveValue: { value in
        print("1 번째 sink value: \(value)")
    }

currentValueSubject
    .sink { completion in
        print("2 번째 sink completion: \(completion)")
    } receiveValue: { value in
        print("2 번째 sink value: \(value)")
    }
    .cancel()

currentValueSubject
    .sink { completion in
        print("3 번째 sink completion: \(completion)")
    } receiveValue: { value in
        print("3 번째 sink value: \(value)")
    }

currentValueSubject.send("2")
currentValueSubject.send("3")
currentValueSubject.send(completion: .finished)

// 2. PassthroughSubject
/*
 정의를 보니 "downstream의 subscriber들에게 값을 전파한다"라고 되어있네요.
 그리고 아까 알아본 CurrentValuSubject와 다르게 생성할 때 딱히 초기값이 필요하지 않다고 합니다.
 또한 최신 값을 저장하기 위한 공간도 필요 없죠.
 이름에서 느낄 수 있듯이 그냥 값을 스쳐 보내는 쿨한 녀석입니다.
 따라서 만약에 subscriber가 없거나 Demand가 0이라면 값을 보내더라도 아무 일도 발생하지 않게 됩니다.
 */

let passthroughSubject = PassthroughSubject<String, Never>()

passthroughSubject
    .sink {
        print("1 번째 Passthrough sink completion: \($0)")
    } receiveValue: {
        print("1 번째 Passthrough sink value: \($0)")
    }

passthroughSubject
    .sink {
        print("2 번째 Passthrough sink completion: \($0)")
    } receiveValue: {
        print("2 번째 Passthrough sink value: \($0)")
    }

passthroughSubject.send("ee")
passthroughSubject.send("ff")
passthroughSubject.send(completion: .finished)

// Assign
class SampleObject {
    var intValue: Int {
        didSet {
            print("intValue Changed: \(intValue)")
        }
    }
    
    init(intValue: Int) {
        self.intValue = intValue
    }
    
    deinit {
        print("SampleObject deinit")
    }
}

let sampleObject = SampleObject(intValue: 5)
let assign = Subscribers.Assign<SampleObject, Int>(object: sampleObject, keyPath: \.intValue)
let intArrayPublisher = [6, 19, 34, 55, 390].publisher
intArrayPublisher.subscribe(assign)
print("Final IntValue:", sampleObject.intValue)
/*
 intArrayPublisher
     .assign(to: \.intValue, on: myObject)
 */

// Demand
// Demand는 누적되는 값이다, 음수를 넣어서 감소시킬 수는 없다! 정도만 알면 사용할 때 큰 문제는 없겠어요.
class DemandTestSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        print("[DEMAND] subscribe 시작!")
        // 여기서 Demand를 설정해줄 수도 있어요!
        // 현재 요청횟수는 1
        subscription.request(.max(1))
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("[DEMAND] receive input: \(input)")
        
        // input 값이 333일때만 요청횟수를 1 증가
        if input == 333 {
            return .max(1)
        } else {
            return .none
        }
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("[DEMAND] receive completion: \(completion)")
    }
}

print("===== DEMAND =====")
[2, 333, 4, 5].publisher
    .print()
    .subscribe(DemandTestSubscriber())
print("==================")

/*
 결과
 (1) input값이 1일 때만 요청횟수를 1 증가
 ===== DEMAND =====
 receive subscription: ([2, 333, 4, 5])
 [DEMAND] subscribe 시작!
 request max: (1)
 receive value: (2)
 [DEMAND] receive input: 2
 request max: (1) (synchronous)
 receive value: (333)
 [DEMAND] receive input: 333
 ==================
 
 (2)input값이 333일 때만 요청횟수를 1 증가
 ===== DEMAND =====
 receive subscription: ([2, 333, 4, 5])
 [DEMAND] subscribe 시작!
 request max: (1)
 receive value: (2)
 [DEMAND] receive input: 2
 ==================
 */

class DemandTestSubscriber2: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        print("[DEMAND] subscribe 시작!")
        // 여기서 Demand를 설정해줄 수도 있어요!
        // 현재 요청횟수는 1
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("[DEMAND] receive completion: \(completion)")
    }
}

print("===== DEMAND2 =====")
[2, 333, 4, 5].publisher
    .print()
    .subscribe(DemandTestSubscriber2())
print("==================")

// Completion

// custom Error를 만듭니다.
enum PinguError: Error {
    case pinguIsBaboo
    case elementIsNil
}

class PinguSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = PinguError
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("receive input: \(input)")
        return .none
    }
    
    func receive(completion: Subscribers.Completion<PinguError>) {
        // .pinguIsBaboo 수신시 실행
        if completion == .failure(.pinguIsBaboo) {
            print("Pingu는 바보입니다.")
        } else {
            print("finished!")
        }
    }
}

let pinguSubject = PassthroughSubject<Int, PinguError>()
let pinguSubscriber = PinguSubscriber()

pinguSubject.subscribe(pinguSubscriber)
pinguSubject.send(100)
pinguSubject.send(completion: .failure(.pinguIsBaboo))
pinguSubject.send(200)

// AnySubscriber
let pinguAnySubscriber = AnySubscriber(pinguSubscriber)
let anySubject1 = PassthroughSubject<Int, PinguError>()
anySubject1.subscribe(pinguAnySubscriber)
anySubject1.send(130300)
anySubject1.send(completion: .failure(.pinguIsBaboo))

/*
 ===============================================
 */
/*
 Subscription에는 특정 Subscriber가 Publisher를 subscribe 할 때 정의되는 ID가 있어서 Class로만 정의해야 한다고 합니다. 또한 Subscription을 cancel 하는 작업은 스레드로부터 안전해야 한다고 하며 cancel은 한 번만 할 수 있다고 해요. Subscription을 cancel 하면 Subscriber를 연결해서 할당된 모든 리소스도 해제된다고 합니다.
 */

struct YoutubeSubscriber {
    let name: String
    let age: Int
}

final class PandaSubscription<S: Subscriber>: Subscription where S.Input == YoutubeSubscriber {
    var requested: Subscribers.Demand = .none
    var youtubeSubscribers: [YoutubeSubscriber]
    var subscriber: S?
    
    init(subscriber: S, youtubeSubscribers: [YoutubeSubscriber]) {
        print("PandaSubscription 생성")
        self.subscriber = subscriber
        self.youtubeSubscribers = youtubeSubscribers
    }
    
    func request(_ demand: Subscribers.Demand) {
        print("요청받은 demand : \(demand)")
        for youtubeSubscriber in youtubeSubscribers {
            subscriber?.receive(youtubeSubscriber)
        }
    }
    
    func cancel() {
        print("PandaSubscription이 cancel됨!")
        youtubeSubscribers.removeAll()
        subscriber = nil
    }
}

extension Publishers {
    struct PandaPublisher: Publisher {
        typealias Output = YoutubeSubscriber
        typealias Failure = Never
        
        var youtubeSubscribers: [YoutubeSubscriber]
        
        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = PandaSubscription(subscriber: subscriber, youtubeSubscribers: youtubeSubscribers)
            subscriber.receive(subscription: subscription)
        }
        
        mutating func append(subscriber: YoutubeSubscriber) {
            youtubeSubscribers.append(subscriber)
        }
    }
    
    static func panda(youtubeSubscribers: [YoutubeSubscriber]) -> Publishers.PandaPublisher {
        return Publishers.PandaPublisher(youtubeSubscribers: youtubeSubscribers)
    }
}

print("======= PandaSubscription =======")
var pandaSubscriptions = Set<AnyCancellable>()
var youtubeSubscribers = [
    YoutubeSubscriber(name: "FuBao", age: 3),
    YoutubeSubscriber(name: "AiBao", age: 10),
    YoutubeSubscriber(name: "LeBao", age: 11),
]

let pandaPublisher = Publishers.panda(youtubeSubscribers: youtubeSubscribers)
pandaPublisher
    .sink {
        print("PandaPublisher:", $0)
    } receiveValue: {
        print("PandaPublisher: name: \($0.name), age: \($0.age)")
    }
    .store(in: &pandaSubscriptions)

pandaSubscriptions.forEach {
    $0.cancel()
}
print("=================================")

// Operators
/*
 ===============================================
 */
let intPublisher = [1, 2, 3, 4, 5, 6, 7].publisher
intPublisher
    .map { element in
        return element * 2
    }
    .sink(receiveValue: { print($0, terminator: " ") })
print()

struct Point {
    let x: Int
    let y: Int
    let z: Int
}

let pointPublisher = PassthroughSubject<Point, Never>()

pointPublisher
    // KeyPath를 이용한 매핑: x, y, z를 다음 sink 등에 보냄
    // 최대 3개
    .map(\.x, \.y, \.z)
    .sink { x, y, z in
        print("x: \(x), y: \(y), z: \(z)")
    }

pointPublisher.send(Point(x: 344, y: 483, z: 932))

// TryMap
func checkNil(_ element: Int?) throws -> Int {
    guard let element else {
        throw PinguError.elementIsNil
    }
    
    return element
}

let tryMapPublisher = [1, 2, nil, 4].publisher

let tryMapSink: ((Subscribers.Completion<Error>) -> Void) = {
    switch $0 {
    case .failure(let error):
        print("TryMapPublisher:", error)
    case .finished:
        print("TryMapPublisher: THE END")
    }
}

tryMapPublisher
    .tryMap {
        try checkNil($0)
    }
    .sink(receiveCompletion: tryMapSink) {
        print("TryMapPublisher:", $0)
    }
/*
 1
 2
 The operation couldn’t be completed. (__lldb_expr_39.(unknown context at $107ab7534).(unknown context at $107ab7570).(unknown context at $107ab7578).PinguError error 0.)
 결과를 보면 publisher가 가지고 있던 값은 4개인데, 3번째 element에서 에러를 받으면 failure를 받아 publish가 끝나서 4번째 값은 방출이 안된 것을 볼 수 있습니다.
 */

// MapError
enum PandaError: Error {
    case thisIsBlackBear
}

tryMapPublisher
    .tryMap {
        try checkNil($0)
    }
    .mapError {
        $0 as? PandaError ?? .thisIsBlackBear
    }
    .sink(receiveCompletion: tryMapSink) {
        print("TryMapPublisher:", $0)
    }

// Scan: 배열의 Reduce와 비슷한 것
pandaPublisher
    .scan(0) { accumulatedResult, currentSubscriber in
        print("accumulatedResult: \(accumulatedResult), currentSubscriber: \(currentSubscriber)")
        return accumulatedResult + currentSubscriber.age
    }
    .sink(receiveValue: { print("AgeSum:", $0) })

// TryScan
tryMapPublisher
    .tryScan(0) { accResult, currValue in
        try accResult + checkNil(currValue)
    }
    .sink(receiveCompletion: { print("[TryScan]", $0) }, receiveValue: { print("[TryScan]", $0) })

// SetFailureType
let stfPublisher = [1, 2, 3, 4].publisher
let pinguErrorPublisher = PassthroughSubject<Int, PinguError>()

stfPublisher
    .setFailureType(to: PinguError.self)
    .combineLatest(pinguErrorPublisher)
    .sink(receiveCompletion: { print("[SetFailureType]", $0) }, receiveValue: { print("[SetFailureType]", $0) })

pinguErrorPublisher.send(0)
/*
 위 코드와 같이 combineLatest와 같이 여러 개의 publisher들을 함께 사용해야 하는 경우가 있습니다. 이런 경우에는 Publisher의 Output, Failure 타입이 같아야 사용이 가능한데요, 이럴 때 Failure 타입을 맞춰주기 위해 setFailureType을 사용하게 됩니다.
 */

// Filter, TryFilter
[1, 2, 3, 4, 5, 6, 7].publisher
    .filter { $0 % 2 == 0 }
    .sink { _ in
        print()
    } receiveValue: {
        print($0, terminator: " ")
    }


[2, 2, 4, 4, 5, 6].publisher
    .tryFilter { element in
        if element % 2 == 0 {
            return true
        } else {
            throw PinguError.elementIsNil
        }
    }
    .sink { completion in
        switch completion {
        case .failure(let error):
            print("TryFilter:", error)
        case .finished:
            print("All is even")
        }
    } receiveValue: { value in
        print("TryFilter:", value)
    }

// CompactMap, TryCompactMap
["100", "235456", "a.b", "4443", "eefef", "45678.5"].publisher
    .compactMap { Int($0) }
    .sink(receiveCompletion: { _ in print() }, receiveValue: { print($0, terminator: " ") })

["100", "235456", "a.b", "4443", "babo", "45678.5"].publisher
    .tryCompactMap {
        if $0 == "babo" {
            throw PinguError.pinguIsBaboo
        }
        
        return Int($0)
    }
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("OK")
        case .failure(let error):
            print("TryCompactMap:", error)
        }
    }, receiveValue: { print($0, terminator: " ") })

// RemoveDuplicates, TryRemoveDuplicates
struct Name {
    let lastName: String
    let firstName: String

    func printName() {
        print(lastName + firstName)
    }
}

[
    Name(lastName: "Pin", firstName: "gu"),
    Name(lastName: "Pin", firstName: "ga"),
    Name(lastName: "Ro", firstName: "By"),
    Name(lastName: "Ro", firstName: "From"),
    Name(lastName: "Ro", firstName: "Yume"),
    Name(lastName: "O", firstName: "dung")
]
    .publisher
    .removeDuplicates { prev, curr in
        // true이면 중복이라고 판단
        prev.lastName == curr.lastName
    }
    .sink { $0.printName() }

/*
 Pingu
 RoBy
 Odung
 */

[1, 2, 2, 3, 3]
    .publisher
    .tryRemoveDuplicates { prev, curr in
        if prev == curr {
            throw PinguError.pinguIsBaboo
        }
        
        return false
    }
    .sink { completion in
        switch completion {
        case .failure(let error):
            print("[TryReduceDuplicates]", error)
        case .finished:
            print("중복값 없음")
        }
    } receiveValue: { value in
        print(value, terminator: " ")
    }


// ReplaceEmpty
Empty<[String], Never>()
    .replaceEmpty(with: ["EE", "EE"])
    .sink { print("[ReplaceEmpty]", $0) }

[Int]().publisher
    .replaceEmpty(with: 5)
    .sink { print("[ReplaceEmpty]", $0) }

// ReplaceError
["1", "2", "a.b", "3"].publisher
    .tryCompactMap {
        if Int($0) != nil {
            return $0
        }
        
        throw PandaError.thisIsBlackBear
    }
    .replaceError(with: "FuBao")
    .sink { completion in
        switch completion {
        case .failure(let error):
            print(error.localizedDescription)
        case .finished:
            print("[ReplaceError] 로 인해 에러가 없어졌다.")
        }
    } receiveValue: { value in
        print("[ReplaceError]", value)
    }

/*
 [ReplaceEmpty] 5
 [ReplaceError] 1
 [ReplaceError] 2
 [ReplaceError] FuBao
 [ReplaceError] 로 인해 에러가 없어졌다.
 
 replaceError는 하나의 Element를 보내고 스트림을 종료해서 에러를 처리하려는 경우에 유용하다고 하네요. catch라는 Operator를 사용해서 에러를 처리해주는 게 좋다고 합니다.
 */

// Catch
["1", "2", "a.b", "3"].publisher
    .tryCompactMap {
        if Int($0) != nil {
            return $0
        }
        
        throw PandaError.thisIsBlackBear
    }
    .catch { _ in
        Just("Monika")
    }
    .sink { completion in
        switch completion {
        case .failure(let error):
            print(error.localizedDescription)
        case .finished:
            print("[Catch] 로 인해 에러가 없어졌다.")
        }
    } receiveValue: { value in
        print("[Catch]", value)
    }


// ==================== 1, 2일차 끝 =======================
