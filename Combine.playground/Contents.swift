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
