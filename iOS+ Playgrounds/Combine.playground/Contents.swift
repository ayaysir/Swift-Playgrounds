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

// Scan: 배열의 Reduce와 비슷한(???)
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

extension String {
    func printWithResult(_ object: Any) {
        print("[\(self)] \(object)")
    }
}

/*
 // Reducing Elements로 분류된 Publisher
 
 - Collect
 - CollectByCount
 - CollectByTime
 - IgnoreOutput
 - Reduce
 - TryReduce
 
 이를 활용한 Operator
 - collect()
 - collect(_:)
 - collect(_:options:)
 - TimeGroupingStrategy
 - ignoreOutput()
 - reduce(_:_:)
 - tryReduce(_:_:)
 */

// 1. collect: Upstream에서 받은 값을 모두 모아서 하나의 배열을 만들어 Downstream으로 보내주는 역할
[1, 2, 3, 4, 5].publisher
    .collect()
    .sink { "Collect".printWithResult($0) }

// CollectByCount
[1, 2, 3, 4, 5, 6, 7].publisher
    .collect(3)
    .sink { "CollectByCount".printWithResult($0) }
/*
 [CollectByCount] [1, 2, 3]
 [CollectByCount] [4, 5, 6]
 [CollectByCount] [7]
 */

// CollectByTime
var cbtSubscription = Set<AnyCancellable>()
let timerPublisher = Timer.publish(every: 100, on: .main, in: .default)
timerPublisher
    // Automates the process of connecting or disconnecting from this connectable publisher.
    .autoconnect()
    // byTime: A grouping that collects and periodically publishes items.
    // case: byTime(Context, Context.SchedulerTimeType.Stride)
    .collect(.byTime(DispatchQueue.main, .seconds(400)))
    // .collect(.byTimeOrCount(DispatchQueue.main, .seconds(12), 3))
    .sink { "CollectByTime".printWithResult($0) }
    .store(in: &cbtSubscription)
/*
 출판을 1초마다 하고 콜렉트를 4초로 설정하면 1초 단위로 4개씩 모이고 방출
 [CollectByTime] [2023-08-18 05:58:05 +0000, 2023-08-18 05:58:06 +0000, 2023-08-18 05:58:07 +0000, 2023-08-18 05:58:08 +0000]
 [CollectByTime] [2023-08-18 05:58:09 +0000, 2023-08-18 05:58:10 +0000, 2023-08-18 05:58:11 +0000, 2023-08-18 05:58:12 +0000]
 [CollectByTime] [2023-08-18 05:58:13 +0000, 2023-08-18 05:58:14 +0000, 2023-08-18 05:58:15 +0000, 2023-08-18 05:58:16 +0000]
 [CollectByTime] [2023-08-18 05:58:17 +0000, 2023-08-18 05:58:18 +0000, 2023-08-18 05:58:19 +0000, 2023-08-18 05:58:20 +0000]
 ...
 */

// IgnoreOutput
[1, 2, 3, 4, 5].publisher
    .ignoreOutput()
    .sink(receiveCompletion: { "IgnoreOutput".printWithResult($0) },
          receiveValue: { print($0) })

[1, 2, 3, 4, 5].publisher
    .reduce(0, { $0 + $1 })
    .sink { "Reduce1".printWithResult($0) }
/*
 [Reduce1] 15
 */

/*
 [참고] Scan과 비교: scan은 값을 매번 방출하는 반면, reduce는 누적된 값을 한번에 방출한다.
 
 pandaPublisher
     .scan(0) { accumulatedResult, currentSubscriber in
         print("accumulatedResult: \(accumulatedResult), currentSubscriber: \(currentSubscriber)")
         return accumulatedResult + currentSubscriber.age
     }
     .sink(receiveValue: { print("AgeSum:", $0) })
 
 accumulatedResult: 0, currentSubscriber: YoutubeSubscriber(name: "FuBao", age: 3)
 AgeSum: 3
 accumulatedResult: 3, currentSubscriber: YoutubeSubscriber(name: "AiBao", age: 10)
 AgeSum: 13
 accumulatedResult: 13, currentSubscriber: YoutubeSubscriber(name: "LeBao", age: 11)
 AgeSum: 24
 */

[1, 2, 3, -10, 4].publisher
    .tryReduce(0) { reduceValue, newValue in
        if reduceValue + newValue < 0 {
            throw PinguError.pinguIsBaboo
        }
        return reduceValue + newValue
    }
    .sink(receiveCompletion: { "TryReduce Comp".printWithResult($0) },
          receiveValue: { "TryReduce Val".printWithResult($0) })

/*
 =======================================
 */

/*
 Applying Mathematical Operations on Elements
 - Count
 - Comparison
 - TryComparison
 
 Operators
 - count()
 - max()
 - max(by:)
 - tryMax(by:)
 - min()
 - min(by:)
 - tryMin(by:)
 */


// Count
[Int](repeating: 0, count: 123).publisher
    .count()
    .sink { "Count".printWithResult($0) }

// Max
[5, 4, 107, 2, 1].publisher
    .max()
    .sink { "Max".printWithResult($0) }

protocol Ikimono {}

struct Person: Ikimono {
    let name: String
    let age: Int
}
struct Panda: Ikimono {
    let name: String
    let age: Int
}

[
    Person(name: "FuBao", age: 3),
    Person(name: "AiBao", age: 10),
    Person(name: "LeBao", age: 11),
].publisher
    .max { $0.age < $1.age }
    .sink { "Max".printWithResult($0) }

([
    Panda(name: "FuBao", age: 3),
    Person(name: "AiBao", age: 10),
    Person(name: "LeBao", age: 11),
] as [Ikimono]).publisher
    .tryMax { first, second in
        if first is Panda {
            return true
        } else {
            throw PandaError.thisIsBlackBear
        }
    }
    .sink(receiveCompletion: { "TryMax".printWithResult($0) },
              receiveValue: { "TryMax".printWithResult($0) })
    
// Min
[5, 4, 107, 2, 1].publisher
    .min()
    .sink { "Min".printWithResult($0) }

[
    Person(name: "FuBao", age: 3),
    Person(name: "AiBao", age: 10),
    Person(name: "LeBao", age: 11),
].publisher
    // 오름차순이라 가정할 때 true가 나와야 min을 찾을 수 있다.
    .min { $0.age < $1.age }
    .sink { "Min".printWithResult($0) }

([
    Panda(name: "FuBao", age: 3),
    Person(name: "AiBao", age: 10),
    Person(name: "LeBao", age: 11),
] as [Ikimono]).publisher
    .tryMax { first, second in
        if first is Panda {
            return true
        } else {
            throw PandaError.thisIsBlackBear
        }
    }
    .sink(receiveCompletion: { "TryMin".printWithResult($0) },
              receiveValue: { "TryMin".printWithResult($0) })

/*
 Applying Matching Criteria to Elements
 
 - Contains
 - ContainsWhere
 - TryContainsWhere
 - AllStatisfy
 - TryAllSatisfy
 
 Operators
 - contains(_:)
 - contains(where:)
 - tryContains(where:)
 - allSatisfy(_:)
 - tryAllSatisfy(_:)
 */

// Contains
[192, 199, 196, 100, 104].publisher
    .contains(196)
    .sink { "Contains".printWithResult($0) }

[192, 199, 196, 100, 104].publisher
    .contains(-348)
    .sink { "Contains".printWithResult($0) }

// Contains Where
["murmur", "twins", "another"].publisher
    .contains(where: { $0.count == 5 })
    .sink { "Contains".printWithResult($0) }

// TryContainsWhere: 값 탐색 중 true가 나오면 이후 과정은 무시, 값 탐생 중 true가 나오지 않은 상태에서 에러 발생시 throw
[2, 4, 8, 12, -105, 3, 6, 8].publisher
    .tryContains {
        if $0 >= 0 && $0 % 2 == 0 {
            return true
        } else {
            throw PinguError.pinguIsBaboo
        }
    }
    .sink {
        "TryContains Comp 1".printWithResult($0)
    } receiveValue: {
        "TryContains Val 1".printWithResult($0)
    }

[2, 4, 8, 12, -105, 3, 6, 8].publisher
    .tryContains {
        if $0 >= 0 && $0 % 2 == 1 {
            return true
        } else {
            throw PinguError.pinguIsBaboo
        }
    }
    .sink {
        "TryContains Comp 2".printWithResult($0)
    } receiveValue: {
        "TryContains Val 2".printWithResult($0)
    }

// AllSatisfy
[2, 4, 6, 8, 10].publisher
    .allSatisfy { $0 % 2 == 0 }
    .sink { "AllSatisfy".printWithResult($0) }

[2, 4, 6, 8, 9, 10].publisher
    .allSatisfy { $0 % 2 == 0 }
    .sink { "AllSatisfy".printWithResult($0) }

[2, 4, 6, 8, 9, -9, 10].publisher
    .tryAllSatisfy {
        if $0 % 2 == 0 {
            return true
        } else if $0 >= 0 {
            return false
        } else {
            throw PinguError.pinguIsBaboo
        }
    }
    .sink {
        "TryAllSatisfy 1 Comp".printWithResult($0)
    } receiveValue: {
        "TryAllSatisfy 1 Val".printWithResult($0)
    }

[2, 4, 6, 8, 222, -9, 10].publisher
    .tryAllSatisfy {
        if $0 % 2 == 0 {
            return true
        } else if $0 >= 0 {
            return false
        } else {
            throw PinguError.pinguIsBaboo
        }
    }
    .sink {
        "TryAllSatisfy 2 Comp".printWithResult($0)
    } receiveValue: {
        "TryAllSatisfy 2 Val".printWithResult($0)
    }

/*
 Applying Sequence Operations to Elements
 
 Publisher
 - DropUntilOutput
 - Drop
 - DropWhile
 - TryDropWhile
 - Concatenate
 - PrefixWhile
 - TryPrefixWhile
 - PrefixUntilOutput
 
 Operators
 - drop(untilOutputFrom:)
 - dropFirst(_:)
 - drop(while:)
 - append(_:)
 - prepend(_:)
 - prefix(_:)
 - prefix(while:)
 - tryPrefix(while:)
 - prefix(untilOutputFrom:)

 */

// DropUntilOutput
// Upstream
let synthPublisher = PassthroughSubject<Int, Never>()
// Downstream
let bassPublisher = PassthroughSubject<String, Never>()

synthPublisher
    .drop(untilOutputFrom: bassPublisher)
    .sink { "DropUntilOutput".printWithResult($0) }

bassPublisher
    .sink { "DropUntilOutput".printWithResult($0) }

for i in 1...8 {
    if i == 5 {
        bassPublisher.send("VERY BIG BASS DROP!!!")
        continue
    }
    
    synthPublisher.send(i)
}

/*
 [DropUntilOutput] VERY BIG BASS DROP!!!
 [DropUntilOutput] 6
 [DropUntilOutput] 7
 [DropUntilOutput] 8
 */

// Drop First
["A", "B", "C", "D", "E"].publisher
    // Zero-based, 3을 지정하면 인덱스 3'부터' 표시
    .dropFirst(3)
    .sink { "DropFirst".printWithResult($0) }

/*
 [DropFirst] D
 [DropFirst] E
 */

// Drop While: 매개변수로 받은 클로저가 ⭐️false를 반환할 때까지⭐️ Upstream publisher에서 받은 값을 무시 (true이면 무시)
["3", "4", "Crunchy", "Nuts", "5"].publisher
    .drop { Int($0) != nil }
    .sink { "DropWhile".printWithResult($0) }

/*
 [DropWhile] Crunchy
 [DropWhile] Nuts
 [DropWhile] 5
 */

// Try Drop While
["3", "4", "G", "Crunchy", "Nuts", "5"].publisher
    .tryDrop {
        if $0 == "G" {
            throw PinguError.pinguIsBaboo
        } else {
            return Int($0) != nil
        }
    }
    .sink {
        "TryDropWhile Comp".printWithResult($0)
    } receiveValue: {
        "TryDropWhile Val".printWithResult($0)
    }

// Append
[1, 2, 3, 4].publisher
    .append(5, 6)
    .append([7, 8, 9])
    .sink { _ in
        print()
    } receiveValue: {
        print($0, terminator: " ")
    }

/*
 1 2 3 4 5 6 7 8 9
 */

let appendPublisher = ["Dead", "or", "Alive"]
["Y&Co.", "is"].publisher
    .append(appendPublisher)
    .sink { _ in
        print()
    } receiveValue: {
        print($0, terminator: " ")
    }
/*
 Y&Co. is Dead or Alive
 */

// Prepend: Append는 뒤에 붙이고, Pretend는 앞에 붙임
[1, 2, 3, 4].publisher
    .prepend(5, 6)
    .prepend([7, 8, 9])
    .sink { _ in
        print()
    } receiveValue: {
        print($0, terminator: " ")
    }
/*
 7 8 9 5 6 1 2 3 4
 */

let prependPublisher = ["Who", "Cares"]
["About", "You"].publisher
    .prepend(prependPublisher)
    .sink { _ in
        print()
    } receiveValue: {
        print($0, terminator: " ")
    }
/*
 Who Cares About You
 */

// Prefix
[1, 2, 3, 4, 3, 2, 1].publisher
    .prefix(3)
    .sink { "Prefix".printWithResult($0) }
/*
 [Prefix] 1
 [Prefix] 2
 [Prefix] 3
 */

// PrefixWhile: ⭐️false를 반환할 때까지⭐️ 값을 방출 (DropWhile과 반대)
"FLYANDFLY".split(separator: "").publisher
    .prefix { $0 != "A" }
    .sink { "Prefix".printWithResult($0) }
/*
 [Prefix] F
 [Prefix] L
 [Prefix] Y
 */

// TryPrefixWhile
"FLY_ANDFLY".split(separator: "").publisher
    .tryPrefix {
        if $0.rangeOfCharacter(from: .alphanumerics) != nil {
            throw PinguError.pinguIsBaboo
        }
        
        return $0 != "A"
    }
    .sink { "TryPrefix Comp".printWithResult($0) } receiveValue: { "TryPrefix Val".printWithResult($0)  }

// Prefix UntilOutputFrom: 물줄기 틀어막기
// Upstream Publisher
let flowWaterPublisher = PassthroughSubject<Int, Never>()
// Blocking Publisher
let twistBlockingPublisher = PassthroughSubject<String, Never>()

flowWaterPublisher
    .prefix(untilOutputFrom: twistBlockingPublisher)
    .sink {
        print()
        "PrefixUntilOutputFrom Comp".printWithResult($0)
    } receiveValue: { print($0, terminator: " ")  }

for i in 1...15 {
    if i == 7 {
        twistBlockingPublisher.send("응안돼 돌아가")
        continue
    }
    
    flowWaterPublisher.send(i)
}

/*
 1 2 3 4 5 6
 [PrefixUntilOutputFrom Comp] finished
 */

/*
 =========================================
 */

/*
 Selecting Specific Elements
 
 Publishers
 - First
 - FirstWhere
 - TryFirstWhere
 - Last
 - LastWhere
 - TryLastWhere
 - Output
 
 Operators
 - first()
 - first(where:)
 - tryFirst(where:)
 - last()
 - last(where:)
 - tryLast(where:)
 - output(at:)
 - output(in:)
 */

// First
"FIRST".split(separator: "").publisher
    .first()
    .sink { "First".printWithResult($0) } // F

// FirstWhere
[1, 3, 5, 2, 4, 5, 7, 8].publisher
    .first { $0 % 2 == 0 }
    .sink { "First".printWithResult($0) } // 2

// TryFirstWhere
"FIRST".split(separator: "").publisher
    .tryFirst {
        if $0 == "S" {
            throw PinguError.pinguIsBaboo
        }
        
        return $0 == "T"
    }
    .sink { "TryFirstWhere Comp".printWithResult($0) } receiveValue: { "TryFirstWhere Val".printWithResult($0) }

// Last
let lastArrayPublisher = "LAST".split(separator: "").publisher
lastArrayPublisher
    .last()
    .sink { "Last".printWithResult($0) } // T

[1, 3, 5, 2, 4, 5, 7, 8].publisher
    .last { $0 % 2 == 1}
    .sink { "Last".printWithResult($0) } // 7

lastArrayPublisher
    .tryLast {
        if $0 == "T" // L을 입력하더라도 마찬가지로 에러 발생. 첫 요소부터 횡단??
        {
            throw PinguError.pinguIsBaboo
        }
        
        return $0 == "S"
    }
    .sink { "TryLastWhere Comp".printWithResult($0) } receiveValue: { "TryLastWhere Val".printWithResult($0) }

// Output: 특정 인덱스, 범위의 요소를 방출
[0, 2, 163, 4, 8].publisher
    .output(at: 2) // 인덱스
    .sink { "Last at".printWithResult($0) } // 163

[0, 2, 163, 4, 8, 66, 71727485, 49, 3, 5, 3468].publisher
    .print()
    .output(in: 2...6) // Zero-based
    .sink {
        "Last in".printWithResult($0)
    } receiveValue: {
        print($0)
    }
/*
 receive subscription: ([0, 2, 163, 4, 8, 66, 71727485, 49, 3, 5, 3468])
 request unlimited
 receive value: (0)
 request max: (1) (synchronous)
 receive value: (2)
 request max: (1) (synchronous)
 receive value: (163)
 163
 receive value: (4)
 4
 receive value: (8)
 8
 receive value: (66)
 66
 receive value: (71727485)
 71727485
 receive cancel
 [Last in] finished
 */

/*
 ===========================================
 */

/*
 Combining Elements from Multiple Publishers
 - CombineLatest: 여러 퍼블리셔로부터 마지막 요소를 모으고 재퍼블리싱
 - Merge: 여러 퍼블리셔를 재조립된 스트림으로 취급하여 재퍼블리싱
 - Zip: 여러 퍼블리셔로부터 가장 오래된 비방출 요소를 모아 재퍼블리싱
 
 Operators
 - combineLatest(_ other:, _ transform:)
 - combineLatest(_ other:)
 - combineLatest(_ publisher1:, _ publisher2:, _ transform:)
 - combineLatest(_ publisher1:, _ publisher2:)
 - combineLatest(_ publisher1:, _ publisher2:, _ publisher3:, _ transform:)
 - combineLatest(_ publisher1:, _ publisher 2:, _ publisher3:)
 */

// combineLatest(_ other:, _ transform:)
var firstCombinePublisher = PassthroughSubject<String, Never>()
var secondCombinePublisher = PassthroughSubject<String, Never>()

firstCombinePublisher
    .combineLatest(secondCombinePublisher) { firstPubValue, secondPubValue in
        return firstPubValue + ":" + secondPubValue
    }
    .sink { "Combine2 Comp".printWithResult($0) } receiveValue: { "Combine2 Val".printWithResult($0) }


firstCombinePublisher.send("E")
secondCombinePublisher.send("F")

secondCombinePublisher.send("G")
firstCombinePublisher.send("H")

// 두 개의 퍼블리셔를 모두 마감시켜야 finished 처리됨
firstCombinePublisher.send(completion: .finished)
secondCombinePublisher.send(completion: .finished)
/*
     E            H    |
 -------------------------------
           F    G      |
 
 [Combine2] E:F
 [Combine2] E:G
 [Combine2] H:G
 [Combine2 Comp] finished
 */

firstCombinePublisher = PassthroughSubject<String, Never>()
secondCombinePublisher = PassthroughSubject<String, Never>()

// combineLatest(_ other:) -> 튜플 형태로만 내보낼 수 있음
firstCombinePublisher
    .combineLatest(secondCombinePublisher)
    .sink { "CombineO Comp".printWithResult($0) } receiveValue: { "CombineO Val".printWithResult($0) }

firstCombinePublisher.send("E")
secondCombinePublisher.send("F")

secondCombinePublisher.send("G")
firstCombinePublisher.send("H")

firstCombinePublisher.send(completion: .finished)
secondCombinePublisher.send(completion: .finished)
/*
     E            H    |
 -------------------------------
           F    G      |
 
 [CombineO Val] ("E", "F")
 [CombineO Val] ("E", "G")
 [CombineO Val] ("H", "G")
 [CombineO Comp] finished
 */

firstCombinePublisher = PassthroughSubject<String, Never>()
secondCombinePublisher = PassthroughSubject<String, Never>()

// combineLatest(_ publisher1:, _ publisher2:, _ transform:)
var thirdCombinePublisher = PassthroughSubject<String, Never>()
/*
 B   O   U   N      C        Y
 ---------------------------------------------
       O       H        M   Y   G   O
 ---------------------------------------------
   F       A      S   H   I       O
 */

firstCombinePublisher
    .combineLatest(secondCombinePublisher, thirdCombinePublisher) { first, second, third in
        return first + ":" + second + ":" + third
    }
    .sink { "Combine3 Comp".printWithResult($0) } receiveValue: { "Combine3 Val".printWithResult($0) }

let firstCombineString = "BOUNCY"
let secondCombineString = "OHMYGO"
let thirdCombineString = "FASHIO"
let combine3Order = [1, 3, 1, 2, 1, 3, 1, 2, 3, 1, 3, 2, 3, 2, 1, 2, 3, 2]

var firstQueue = firstCombineString.split(separator: "")
var secondQueue = secondCombineString.split(separator: "")
var thirdQueue = thirdCombineString.split(separator: "")

combine3Order.forEach { combineIndex in
    switch combineIndex {
    case 1:
        firstCombinePublisher.send(String(firstQueue.removeFirst()))
    case 2:
        secondCombinePublisher.send(String(secondQueue.removeFirst()))
    case 3:
        thirdCombinePublisher.send(String(thirdQueue.removeFirst()))
    default:
        break
    }
}

firstCombinePublisher.send(completion: .finished)
secondCombinePublisher.send(completion: .finished)
thirdCombinePublisher.send(completion: .finished)

// emit Tuple
firstCombinePublisher = PassthroughSubject<String, Never>()
secondCombinePublisher = PassthroughSubject<String, Never>()
thirdCombinePublisher = PassthroughSubject<String, Never>()

firstCombinePublisher
    .combineLatest(secondCombinePublisher, thirdCombinePublisher)
    .sink { "Combine3o Comp".printWithResult($0) } receiveValue: { "Combine3o Val".printWithResult($0) }

firstQueue = firstCombineString.split(separator: "")
secondQueue = secondCombineString.split(separator: "")
thirdQueue = thirdCombineString.split(separator: "")

combine3Order.forEach { combineIndex in
    switch combineIndex {
    case 1:
        firstCombinePublisher.send(String(firstQueue.removeFirst()))
    case 2:
        secondCombinePublisher.send(String(secondQueue.removeFirst()))
    case 3:
        thirdCombinePublisher.send(String(thirdQueue.removeFirst()))
    default:
        break
    }
}

firstCombinePublisher.send(completion: .finished)
secondCombinePublisher.send(completion: .finished)
thirdCombinePublisher.send(completion: .finished)

/*
 B   O   U   N      C        Y
 ---------------------------------------------
       O       H        M   Y   G   O
 ---------------------------------------------
   F       A      S   H   I       O
 
 [Combine3 Val] O:O:F
 [Combine3 Val] U:O:F
 [Combine3 Val] U:O:A
 [Combine3 Val] N:O:A
 [Combine3 Val] N:H:A
 [Combine3 Val] N:H:S
 [Combine3 Val] C:H:S
 [Combine3 Val] C:H:H
 [Combine3 Val] C:M:H
 [Combine3 Val] C:M:I
 [Combine3 Val] C:Y:I
 [Combine3 Val] Y:Y:I
 [Combine3 Val] Y:G:I
 [Combine3 Val] Y:G:O
 [Combine3 Val] Y:O:O
 [Combine3 Comp] finished
 
 [Combine3o Val] ("O", "O", "F")
 [Combine3o Val] ("U", "O", "F")
 [Combine3o Val] ("U", "O", "A")
 [Combine3o Val] ("N", "O", "A")
 [Combine3o Val] ("N", "H", "A")
 [Combine3o Val] ("N", "H", "S")
 [Combine3o Val] ("C", "H", "S")
 [Combine3o Val] ("C", "H", "H")
 [Combine3o Val] ("C", "M", "H")
 [Combine3o Val] ("C", "M", "I")
 [Combine3o Val] ("C", "Y", "I")
 [Combine3o Val] ("Y", "Y", "I")
 [Combine3o Val] ("Y", "G", "I")
 [Combine3o Val] ("Y", "G", "O")
 [Combine3o Val] ("Y", "O", "O")
 [Combine3o Comp] finished
 */

// Combine4: combineLatest(_ publisher1:, _ publisher2:, _ publisher3:, _ transform:)
firstCombinePublisher = PassthroughSubject<String, Never>()
secondCombinePublisher = PassthroughSubject<String, Never>()
thirdCombinePublisher = PassthroughSubject<String, Never>()
var fourthCombinePublisher = PassthroughSubject<String, Never>()

/*
 B    O   U    N         C         Y
 ---------------------------------------------
        O          H         M   Y      G   O
 ---------------------------------------------
   F         A        S    H   I          O
 ---------------------------------------------
     f           l                   y
 */

let fourthString = "fly"
let combine4Order = [1, 3, 4, 1, 2, 1, 3, 1, 4, 2, 3, 1, 3, 2, 3, 2, 1, 4, 2, 3, 2]

firstQueue = firstCombineString.split(separator: "")
secondQueue = secondCombineString.split(separator: "")
thirdQueue = thirdCombineString.split(separator: "")
var fourthQueue = fourthString.split(separator: "")

firstCombinePublisher
    .combineLatest(secondCombinePublisher, thirdCombinePublisher, fourthCombinePublisher)
    .sink { "Combine3o Comp".printWithResult($0) } receiveValue: { "Combine3o Val".printWithResult($0) }
    

combine4Order.forEach { combineIndex in
    switch combineIndex {
    case 1:
        firstCombinePublisher.send(String(firstQueue.removeFirst()))
    case 2:
        secondCombinePublisher.send(String(secondQueue.removeFirst()))
    case 3:
        thirdCombinePublisher.send(String(thirdQueue.removeFirst()))
    case 4:
        fourthCombinePublisher.send(String(fourthQueue.removeFirst()))
    default:
        break
    }
}

[
    firstCombinePublisher,
    secondCombinePublisher,
    thirdCombinePublisher,
    fourthCombinePublisher,
].forEach {
    $0.send(completion: .finished)
}

/*
 B    O   U    N         C         Y
 ---------------------------------------------
        O          H         M   Y      G   O
 ---------------------------------------------
   F         A        S    H   I          O
 ---------------------------------------------
     f           l                   y
 
 [Combine3o Val] ("O", "O", "F", "f")
 [Combine3o Val] ("U", "O", "F", "f")
 [Combine3o Val] ("U", "O", "A", "f")
 [Combine3o Val] ("N", "O", "A", "f")
 [Combine3o Val] ("N", "O", "A", "l")
 [Combine3o Val] ("N", "H", "A", "l")
 [Combine3o Val] ("N", "H", "S", "l")
 [Combine3o Val] ("C", "H", "S", "l")
 [Combine3o Val] ("C", "H", "H", "l")
 [Combine3o Val] ("C", "M", "H", "l")
 [Combine3o Val] ("C", "M", "I", "l")
 [Combine3o Val] ("C", "Y", "I", "l")
 [Combine3o Val] ("Y", "Y", "I", "l")
 [Combine3o Val] ("Y", "Y", "I", "y")
 [Combine3o Val] ("Y", "G", "I", "y")
 [Combine3o Val] ("Y", "G", "O", "y")
 [Combine3o Val] ("Y", "O", "O", "y")
 [Combine3o Comp] finished
 */

/*
 =======================================
 */

// MERGE: 8개까지 가능
// merge(with other: P)
var firstMergePublisher = PassthroughSubject<Int, Never>()
var secondMergePublisher = PassthroughSubject<Int, Never>()
// 퍼블리셔간 방출하는 값의 타입이 같아야 함

firstMergePublisher
    .merge(with: secondMergePublisher)
    .sink { "MergeO Comp".printWithResult($0) } receiveValue: { "MergeO Val".printWithResult($0) }

firstMergePublisher.send(1)
secondMergePublisher.send(38729857)
firstMergePublisher.send(2)
secondMergePublisher.send(19433338)
/*
 [MergeO Val] 1
 [MergeO Val] 38729857
 [MergeO Val] 2
 [MergeO Val] 19433338
 */

// MergeMany
var mergePublishers: [PassthroughSubject<Int, Never>] = (0..<20).map { index in
    PassthroughSubject<Int, Never>()
}
// Repeating, count로 반복 어레이를 생성하지 않아야 함 -> class 이므로 동일한 주소의 인스턴스가 들어감

Publishers.MergeMany(mergePublishers)
    .sink { print($0, terminator: " ") }

for (index, publisher) in mergePublishers.enumerated() {
    publisher.send(index)
}
print()
/*
 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
 */

/*
 ZIP
 - 여러 개의 Publisher에서 가장 오래 사용되지 않은 값들을 모아서 처리
 - Zip4까지 있음
 
 Operators
 - zip(_ other:)
 - zip(_ other: _ transform:)
 - zip(_ publisher1, _ publisher2)
 - zip(_ publisher1, _ publisher2, _ transform:)
 - zip(_ publisher1, _ publisher2, _ publisher3)
 - zip(_ publisher1, _ publisher2, _ publisher3, _ transform:)
 */

// zip(_ other:)
// zip은 (Zip2의 경우) 페어가 이루어져야만 방출됨
var firstZipPub = PassthroughSubject<Int, Never>()
var secondZipPub = PassthroughSubject<Int, Never>()

firstZipPub
    .zip(secondZipPub)
    .sink { "Zip2 Comp".printWithResult($0) } receiveValue: { "Zip2 Val".printWithResult($0) }

firstZipPub.send(1)
secondZipPub.send(11)

firstZipPub.send(2)
secondZipPub.send(12)

for i in 3...9 {
    firstZipPub.send(i)
}

// 페어가 완성되어야만 finished 될 수 있음
firstZipPub.send(completion: .finished)

// 아래 부분이 실행되지 않은 경우 (3, 13) ~ (9, 19)는 방출되지 않는다
for i in 3...9 {
    secondZipPub.send(i + 10)
}
/*
 [Zip2 Val] (1, 11)
 [Zip2 Val] (2, 12)
 [Zip2 Val] (3, 13)
 [Zip2 Val] (4, 14)
 [Zip2 Val] (5, 15)
 [Zip2 Val] (6, 16)
 [Zip2 Val] (7, 17)
 [Zip2 Val] (8, 18)
 [Zip2 Val] (9, 19)
 [Zip2 Comp] finished
 */

// zip(_ other:, _ transform:)
firstZipPub = PassthroughSubject<Int, Never>()
secondZipPub = PassthroughSubject<Int, Never>()
var thirdZipPub = PassthroughSubject<Int, Never>()

firstZipPub
    .zip(secondZipPub, thirdZipPub)
    .sink { "Zip3 Comp".printWithResult($0) } receiveValue: { "Zip3 Val".printWithResult($0) }

for i in 1...3 {
    firstZipPub.send(i)
}

for i in 1...3 {
    thirdZipPub.send(i * 100)
}

thirdZipPub.send(completion: .finished)

for i in 1...3 {
    secondZipPub.send(i * 10)
}

/*
 [Zip3 Val] (1, 10, 100)
 [Zip3 Val] (2, 20, 200)
 [Zip3 Val] (3, 30, 300)
 [Zip3 Comp] finished
 */

/*
 ===============================
 */

/*
 Republishing Elements by Subscribing to New Publishers

 Publishers
 - FlatMap
 - SwitchToLatest
 
 Operators
 - flatMap(maxPublishers:,_:)
 - switchToLatest()
 */

// FlatMap
typealias PassThruSubjString = PassthroughSubject<String, Never>

let fmPub1 = PassThruSubjString()
let fmPub2 = PassThruSubjString()
let fmPubs = PassthroughSubject<PassThruSubjString, Never>()

fmPubs
    // 최대 퍼블리셔 처리 개수
    .flatMap(maxPublishers: .max(2)) { publisher in
        publisher
    }
    .sink { "FlatMap Comp".printWithResult($0) } receiveValue: { "FlatMap Val".printWithResult($0) }

fmPubs.send(fmPub2)
fmPubs.send(fmPub1)

fmPub1.send("Hell")
fmPub1.send("World")

fmPub2.send("Kwangya")
fmPub2.send("ZZZZ")

/*
 max 1:
 [FlatMap Val] Kwangya
 [FlatMap Val] ZZZZ
 
 max 2:
 [FlatMap Val] Hell
 [FlatMap Val] World
 [FlatMap Val] Kwangya
 [FlatMap Val] ZZZZ
 */

// 아스키코드 정수 배열을 받아서 문자열로 변환
let decodeOnlyAlphabet: ([Int]) -> AnyPublisher<String, Never> = { codes in
    Just(
        codes
            .compactMap { code in
                guard (65...90).contains(code) || (97...122).contains(code) else { return nil }
                return String(UnicodeScalar(code) ?? " ")
            }
            .joined()
    )
    .eraseToAnyPublisher()
}

let intArrayFMPublisher = PassthroughSubject<[Int], Never>()
intArrayFMPublisher
    .flatMap(decodeOnlyAlphabet)
    .sink { "FlatMap Comp".printWithResult($0) } receiveValue: { "FlatMap Val".printWithResult($0) }

intArrayFMPublisher.send([1, 80, 105, 110, 103, 117])
intArrayFMPublisher.send([1, 80, 105, 110, 103, 97])
intArrayFMPublisher.send(completion: .finished)
/*
 [FlatMap Val] Pingu
 [FlatMap Val] Pinga
 [FlatMap Comp] finished
 */

// switchToLatest()
typealias PssthrusbjInt = PassthroughSubject<Int, Never>
let slPub1 = PssthrusbjInt()
let slPub2 = PssthrusbjInt()
let slPub3 = PssthrusbjInt()
let slPubs = PassthroughSubject<PssthrusbjInt, Never>()

slPubs
    .switchToLatest()
    .sink { "SwitchToLatest Comp".printWithResult($0) } receiveValue: { "SwitchToLatest Val".printWithResult($0) }

slPubs.send(slPub1)
slPub1.send(99)
slPub1.send(18)

slPubs.send(slPub2)
slPub1.send(73939)
slPub2.send(-999)

slPubs.send(slPub3)
slPub1.send(245243939)
slPub2.send(182435)
slPub3.send(111111)

slPub3.send(completion: .finished)
slPubs.send(completion: .finished)
/*
 [SwitchToLatest Val] 99
 [SwitchToLatest Val] 18
 [SwitchToLatest Val] -999
 [SwitchToLatest Val] 111111
 [SwitchToLatest Comp] finished
 */


var utSubsc = Set<AnyCancellable>()
func userTapMockUp() {
    let url = URL(string: "https://source.unsplash.com/random")!
    
    func getImage() -> AnyPublisher<UIImage?, Never> {
        URLSession.shared
            .dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    let userTap = PassthroughSubject<Void, Never>()
    userTap
        .map { _ in getImage() }
        .switchToLatest()
        .sink { "UserTap Comp".printWithResult($0 as Any) } receiveValue: { "UserTap Val".printWithResult($0 as Any) }
        // Stores this type-erasing cancellable instance in the specified set.
        .store(in: &utSubsc)
    
    userTap.send()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        userTap.send()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
        userTap.send()
    }
}
userTapMockUp()
/*
 [UserTap Val] Optional(<UIImage:0x600001d187e0 anonymous {1080, 1441} renderingMode=automatic(original)>)
 [UserTap Val] Optional(<UIImage:0x600001d18990 anonymous {1080, 1620} renderingMode=automatic(original)>)
 */

/*
 ===========================================
 */

/*
 Handling Errors
 
 Publishers
 - AssertNoFailure
 - Catch
 - TryCatch
 - Retry
 
 Operators
 - assertNoFailure(_:file:line:)
 - catch(_:)
 - tryCatch(_:)
 - retry(_:)
 */

// assertNoFailure(_:file:line:)
let intPub1 = PassthroughSubject<Int, PinguError>()

intPub1
    .assertNoFailure()
    .sink { "assertNoFailure Comp".printWithResult($0) } receiveValue: { "assertNoFailure Val".printWithResult($0) }

intPub1.send(1)
intPub1.send(2)
// intPub1.send(completion: .failure(.pinguIsBaboo)) // FatalError 발생


[4, 6, 0, 1, 3, 7].publisher
    .tryMap {
        guard $0 != 0 else { throw PinguError.pinguIsBaboo }
        return $0 * 2
    }
    .catch { _ in Just(-999) }
    .sink { "catch Comp".printWithResult($0) } receiveValue: { "catch Val".printWithResult($0) }

/*
 [catch Val] 8
 [catch Val] 12
 [catch Val] -999
 [catch Comp] finished
 */

let intPub2 = [4, 6, 0, 1, 3, 7].publisher
let anotherIntPub2 = [99, 999, 9999].publisher

intPub2
    .tryMap {
        guard $0 != 0 else { throw PinguError.pinguIsBaboo }
        return $0 * 2
    }
    .tryCatch { error -> AnyPublisher<Int, Never> in
        if error is PinguError { throw PandaError.thisIsBlackBear }
        return anotherIntPub2.eraseToAnyPublisher()
    }
    .sink { "tryCatch Comp".printWithResult($0) } receiveValue: { "tryCatch Val".printWithResult($0) }
    
/*
 * tryCatch에 에러 변환을 지정하지 않았을 경우
 [tryCatch Val] 8
 [tryCatch Val] 12
 [tryCatch Val] 99
 [tryCatch Val] 999
 [tryCatch Val] 9999
 [tryCatch Comp] finished
 
 * tryCatch에 에러 변환을 지정한 경우
 [tryCatch Val] 8
 [tryCatch Val] 12
 [tryCatch Comp] failure(__lldb_expr_85.PandaError.thisIsBlackBear)
 */

// Retry
var retryCount: Int = 0
func retryTest() throws {
    if retryCount < 2 {
        retryCount += 1
        print("\(retryCount) 번째 재시도")
        throw PandaError.thisIsBlackBear
    }
}

[1, 2, 3, 4].publisher
    .tryMap { value in
        try retryTest()
        return value
    }
    .retry(3)
    .sink { "retry Comp".printWithResult($0) } receiveValue: { "retry Val".printWithResult($0) }

/*
 retryCount < 2
 1 번째 재시도
 2 번째 재시도
 [retry Val] 1
 [retry Val] 2
 [retry Val] 3
 [retry Val] 4
 [retry Comp] finished
 
 retryCount < 4
 1 번째 재시도
 2 번째 재시도
 3 번째 재시도
 4 번째 재시도
 [retry Comp] failure(__lldb_expr_91.PandaError.thisIsBlackBear)
 */

/*
 ==================================
 */

/*
 Controlling Timing
 Publishers
 - MeasureInterval
 - Debounce
 - Delay
 - Throttle
 - Timeout
 
 Operators
 - measureInterval(using:options:)
 - debounce(for:scheduler:options:)
 - delay(for:tolerance:scheduler:options:)
 - throttle(for:scheduler:latest:)
 - timeout(_:,scheduler:options:customError:)
 */

// measureInterval(using:options:)
var miSubsc = Set<AnyCancellable>()
let miPub = PssthrusbjInt()
miPub
    .measureInterval(using: DispatchQueue.main)
    .sink {
        "MeasureInterval".printWithResult($0)
    } receiveValue: { nanosecond in
        print("Measure Time:", Double(nanosecond.magnitude) / 1000000000.0)
    }
    .store(in: &miSubsc)

miPub.send(1)
sleep(1)
miPub.send(3584)
sleep(3)
miPub.send(56245)

/*
 Measure Time: 0.000358334
 Measure Time: 1.002780583
 Measure Time: 3.001439042
 */

// Debounce: debounce(for:scheduler:options:)
var dbcSubsc = Set<AnyCancellable>()
let operationQueue: OperationQueue = {
    let operaionQueue = OperationQueue()
    operaionQueue.maxConcurrentOperationCount = 1
    return operaionQueue
}()

let textField = PassThruSubjString()
let bounces: [(String, TimeInterval)] = [ // 입력값, 입력 후 기다리는 시간
    ("www", 0.5),
    (".", 0.5),
    ("p", 1),
    ("ing", 0.5),
    ("u", 0.5),
    (".", 1.2),
    ("co", 0.5),
    ("m", 5),
]

var requestString = ""
textField
    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
    .sink { print("이번에 받은 값: \($0) , Network Request with: \(requestString)") }
    .store(in: &dbcSubsc)

for bounce in bounces {
    operationQueue.addOperation {
        requestString += bounce.0
        textField.send(bounce.0)
        
        usleep(UInt32(bounce.1 * 1000000))
    }
}
/*
 이번에 받은 값: p , Network Request with: www.p
 이번에 받은 값: . , Network Request with: www.pingu.
 이번에 받은 값: m , Network Request with: www.pingu.com
 */

// Delay
// delay(for:tolerance:scheduler:options:)
var delaySubsc = Set<AnyCancellable>()
let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .long
    return dateFormatter
}()

Timer.publish(every: 1, on: .main, in: .default)
// Automates the process of connecting or disconnecting from this connectable publisher.
    .autoconnect()
    .handleEvents(receiveOutput:  { date in
        print("[Delay HE] Downstream으로 보낸값(현재시간): \(dateFormatter.string(from: date))")
    })
    .delay(for: .seconds(3), scheduler: RunLoop.main, options: .none)
    .sink {
        "Delay Comp".printWithResult($0)
    } receiveValue: {
        let now = Date()
        print("[Delay Val] 받은 값: \(dateFormatter.string(from: $0)) | 보낸시간: \(String(format: "%2.f", now.timeIntervalSince($0)))초 전")
    }
    .cancel()
    // .store(in: &delaySubsc)

/*
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:47 PM GMT+9 (A)
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:48 PM GMT+9 (B)
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:49 PM GMT+9 (C)
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:50 PM GMT+9 (D)
 [Delay Val] 받은 값: 1:40:47 PM GMT+9 | 보낸시간:  3초 전    (A)
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:51 PM GMT+9
 [Delay Val] 받은 값: 1:40:48 PM GMT+9 | 보낸시간:  3초 전    (B)
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:52 PM GMT+9
 [Delay Val] 받은 값: 1:40:49 PM GMT+9 | 보낸시간:  3초 전    (C)
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:53 PM GMT+9
 [Delay Val] 받은 값: 1:40:50 PM GMT+9 | 보낸시간:  3초 전    (D)
 [Delay HE] Downstream으로 보낸값(현재시간): 1:40:54 PM GMT+9
 
 즉 Upstream Publisher에서 내려보낸 값이 3초 뒤에야 Downstream에 전달되는 것이죠.
 Downstream에서 받은 값은 현재 시간보다 3초 전의 값인 것을 볼 수 있어요.
 */

// Throttle: 지정된 시간 간격마다 Upstream Publisher가 보낸 가장 최근 값 혹은 가장 첫 번째 값을 Downstream으로 전달
/*
 Debounce: 값의 수신이 멈추면 일정 시간을 기다린 후 가장 최신 값을 Downstream으로 전달합니다.
 Throttle: 일정 시간을 기다린 뒤 해당 시간 동안 수신한 값 중 가장 첫 번째 값이나 최신 값을 Downstream으로 전달합니다.
 */

// throttle(for:scheduler:latest:)
// - interval: 값을 내려보내기 전 Upstream 퍼블리셔에게 값을 받는 시간 간격
// - latest: 받은 값 중 최신 값을 내려보낼지(true) 첫 번째 값을 내보낼지(false) 결정하는 Bool

var thrSubsc = Set<AnyCancellable>()
let thrOpQue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
}()

let textField2 = PassthroughSubject<String, Never>()
let throttles: [(String, TimeInterval)] = bounces
var requestString2 = ""

textField2
    .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: true)
    .sink {
        "Throttle Comp".printWithResult($0)
    } receiveValue: {
        print("[Throttle] 이번시간동안 받은 값중 최신값: \($0), 현재시간: \(Date().description), Network Request with: \(requestString)")
    }
    .cancel()
    // .store(in: &thrSubsc)

textField2
    .sink(receiveCompletion: { print($0) },
          receiveValue: { string in
        print("[Throttle] 현재시간: \(Date().description), 이번에 내려보낸 값: \(string)")
    })
    .cancel()
    // .store(in: &thrSubsc)

for throttle in throttles {
    thrOpQue.addOperation {
        requestString2 += throttle.0
        textField2.send(throttle.0)
        
        usleep(UInt32(throttle.1 * 1_000_000))
    }
}



/*
 Network Request를 2초마다 보냄
 
 [Throttle] 현재시간: 2023-08-19 04:57:23 +0000, 이번에 내려보낸 값: www
 [Throttle] 이번시간동안 받은 값중 최신값: www, 현재시간: 2023-08-19 04:57:24 +0000, Network Request with: www
 [Throttle] 현재시간: 2023-08-19 04:57:24 +0000, 이번에 내려보낸 값: .
 [Throttle] 현재시간: 2023-08-19 04:57:25 +0000, 이번에 내려보낸 값: p
 [Throttle] 현재시간: 2023-08-19 04:57:26 +0000, 이번에 내려보낸 값: ing
 [Throttle] 이번시간동안 받은 값중 최신값: ing, 현재시간: 2023-08-19 04:57:26 +0000, Network Request with: www.ping
 [Throttle] 현재시간: 2023-08-19 04:57:26 +0000, 이번에 내려보낸 값: u
 [Throttle] 현재시간: 2023-08-19 04:57:27 +0000, 이번에 내려보낸 값: .
 [Throttle] 이번시간동안 받은 값중 최신값: ., 현재시간: 2023-08-19 04:57:28 +0000, Network Request with: www.pingu.co
 [Throttle] 현재시간: 2023-08-19 04:57:28 +0000, 이번에 내려보낸 값: co
 [Throttle] 현재시간: 2023-08-19 04:57:28 +0000, 이번에 내려보낸 값: m
 [Throttle] 이번시간동안 받은 값중 최신값: m, 현재시간: 2023-08-19 04:57:30 +0000, Network Request with: www.pingu.com
 */

// Timeout
// timeout(_:scheduler:options:customError:)
/*
 - interval: 값을 전달받지 않아도 되는 최대 시간
 - customError: 일정 시간동안 값을 받지 못했을 때 실행되는 클로저, 또는 Failure 타입 방출 가능
 */

struct TimeoutError: Error {}
let ttIntPublisher = PassthroughSubject<Int, TimeoutError>()
ttIntPublisher
    .timeout(.seconds(2), scheduler: DispatchQueue.main) {
        return TimeoutError()
    }
    .sink { "Timeout Comp".printWithResult($0) } receiveValue: { "Timeout Val".printWithResult($0) }
    .store(in: &thrSubsc)

ttIntPublisher.send(1)
ttIntPublisher.send(2)
// timeout 최대 시간이 2초 설정인데 2.5초뒤에 send되도록 함
DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
    ttIntPublisher.send(3)
}

/*
 [Timeout Val] 1
 [Timeout Val] 2
 [Timeout Comp] failure(__lldb_expr_120.TimeoutError())
 
 customError 클로저에서 에러를 반환하지 않으면 그냥 finished 됩니다!
 */

/*
 =============================================
 */

/*
 Encoding and Deconding
 
 Publishers
 - Encode
 - Decode
 
 Operators
 - encode(encoder:)
 - decode(type:decoder:)
 
 encode는 어떤 정보를 컴퓨터에서 사용하는 형태(코드)로 바꾸는 것이고,
 decode는 반대로 컴퓨터에서 사용하는 형태(코드)로 바꿔진 값을 원래대로 되돌리는 것입니다.
 */

// encode(encoder:)
struct GiantPanda: Codable {
    let name: String
    let age: Int
    let address: String
}

let gPandaPub = PassthroughSubject<GiantPanda, Never>()
gPandaPub
    .encode(encoder: JSONEncoder())
    .sink {
        "Encode Comp".printWithResult($0)
    } receiveValue: { data in
        print("[Encode Val] 인코딩된 값: \(data)")
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }
        print("[Encode Val] 인코딩 값의 문자열 표현: \(string)")
    }

gPandaPub.send(.init(name: "FuBao", age: 3, address: "용인시"))
/*
 [Encode Val] 인코딩된 값: 46 bytes
 [Encode Val] 인코딩 값의 문자열 표현: {"name":"FuBao","age":3,"address":"용인시"}
 */

// decode(type:decoder:)
let gPandaDataPub = PassthroughSubject<Data, Never>()
gPandaDataPub
    .decode(type: GiantPanda.self, decoder: JSONDecoder())
    .sink{
        "Decode Comp".printWithResult($0)
    } receiveValue: { decoded in
        "Decode Val".printWithResult(decoded)
    }

let jsonString = """
    {"name":"LeBao","age":11,"address":"용인시"}
"""
let lebaoData = Data(jsonString.utf8)
gPandaDataPub.send(lebaoData)
/*
 [Decode Val] GiantPanda(name: "LeBao", age: 11, address: "용인시")
 */

