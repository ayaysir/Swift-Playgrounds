import UIKit

class Counter {
    var count: Int = 0
    
    func increment() {
        self.count += 1
    }
}

let counter = Counter()
// global
DispatchQueue.global().async {
     counter.increment()
}
// main
DispatchQueue.main.async {
    counter.increment()
}

counter.count

// 플레이그라운드에서는 발생하지 않는데
// data race : 2개 이상의 개별 쓰레드가 동시에 동일한 데이터에 접근하고, 이러한 접근 중 하나 이상이 write일 때 발생.
// data race가 발생하는 원인은 데이터가 shared mutable state이기 때문.


// Actor는 그냥 Swift의 새로운 타입임. 클래스와 가장 유사.
// 클래스와 달리 Actor는 한번에 하나의 작업만 변경 가능한 상태(mutable state)에 접근할 수 있도록 허용.
// 클래스와 달리 상속을 지원하지 않음.

actor Counter1 {
    var count: Int = 0
    
    func increment() {
        self.count += 1
    }
}

// Actor는 data race를 피하기 위해서 잠시동안 호출코드를 "기다리게" 할 수 있음
// 보통 외부에서 호출할 때는 async / await과 함께 쓰게 될 것.

func runCounter1() async {
    let counter = Counter1()
    await counter.increment()
}

// 'async' call in a function that does not support concurrency
// runCounter1()


/// URL로부터 JSON을 읽어와 [String: Any]? 형태의 파라미터를 받는 클로저로 처리할 수 있는 함수
func fetchData(_ urlString: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let url = URL(string: urlString)!
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // let shorthand: Swift version 5.7부터 도입
        guard let data else {
            return
        }
        
        do {
            if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                completion(array, nil)
            }
        } catch {
            print(error)
            completion(nil, error)
        }
        
    }
    
    task.resume()
}


// print("====== Callback Start ======")
// fetchData("https://reqres.in/api/users?delay=2") { dict, error in
//     debugPrint("page 1:", dict!["support"]!)
//
//     fetchData("https://reqres.in/api/users?delay=2") { dict, error in
//         debugPrint("page 2:", dict!["support"]!)
//
//         fetchData("https://reqres.in/api/users?delay=2") { dict, error in
//             debugPrint("page 3:", dict!["support"]!)
//         }
//     }
// }

/// URL로부터 JSON을 읽어와 [String: Any]를 반환하는 async 함수
func fetchDataAsync(_ urlString: String) async throws -> [String: Any] {
    let url = URL(string: urlString)!
    
    // try를 제외한 경우: Call can throw, but it is not marked with 'try' and the error is not handled
    let (data, _) = try await URLSession.shared.data(from: url)
    
    do {
        if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            return array
        }
    } catch {
        throw error
    }
    
    return [:]
}


Task {
    print("====== Async/Await Start ======")
    print("page 1:", try await fetchDataAsync("https://reqres.in/api/users?delay=2")["support"]!)
    print("page 2:", try await fetchDataAsync("https://reqres.in/api/users?delay=2")["support"]!)
    print("page 3:", try await fetchDataAsync("https://reqres.in/api/users?delay=2")["support"]!)
}
