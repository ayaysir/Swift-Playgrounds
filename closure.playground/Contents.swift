import UIKit

// Closure expression
// 익명 함수: 이름이 없고, func 키워드 필요 없음
// First-citizen class

// Completion block
// High order function: 파라미터를 함수로 받을 수 있는 함수

// syntax
// { (parameters) -> return type in statements }

// 1. 단순 클로저
let simpleClosure = {
    
} // type: () -> ()
simpleClosure()

// 2. 코트 블록을 구현한 클로저
let codeBlockClosure = {
    print("code block closure")
} // type: () -> ()
codeBlockClosure()

// 3. 인풋 파라미터를 받는
let inputClosure: (String) -> Void = { value in
    print("name: \(value)")
}
inputClosure("disease")

// 4. 값을 리턴하는
let addClosure: (Int, Int) -> Int = { a, b in
    return a + b
}
addClosure(3, 5)

// 5. 클로저를 파라미터로 받는 함수
func highOrderFunc(closure: () -> Void) {
    print("high order function")
    closure()
}
highOrderFunc {
    print("function as a parameter")
}

// 6. Trailing closure
func hofWithTrailing(message: String, closure: () -> Void) {
    print("message: \(message)")
    closure()
}
hofWithTrailing(message: "trailing closure") {
    print("closure")
}

// 클로저가 파라미터의 마지막에 위치 시 생략 문법 사용 가능
hofWithTrailing(message: "message1", closure: {
    print("not omit")
})
hofWithTrailing(message: "message2") {
    print("omitted")
}


