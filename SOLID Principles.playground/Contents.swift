import UIKit

// class API관리자__ {
//     func 관리한다() {
//         let 데이터 = API에_데이터를_요청한다()
//         let 배열 = 응답을_파싱한다(data: 데이터)
//         데이터베이스에_저장한다(array: 배열)
//     }
//   
//     private func API에_데이터를_요청한다() -> Data {
//         // 네트워크에 요청하고 응답을 기다립니다.
//         
//         return .init()
//     }
//     
//     private func 응답을_파싱한다(data: Data) -> [String] {
//         // 받은 응답을 파싱하여 String 배열에 저장합니다.
//         
//         return []
//     }
//    
//     private func 데이터베이스에_저장한다(array: [String]) {
//         // 파싱한 배열을 데이터베이스에 저장합니다.
//     }
// }
 
// class 관리자 {
//     let api관리자: APIHandler
//     let 파싱관리자: ParseHandler
//     let 데이터베이스관리자: DatabaseHandler
//     
//     // 생성자
//     init(api관리자: APIHandler, 파싱관리자: ParseHandler, 데이터베이스관리자: DBHandler) {
//         self.api관리자 = api관리자
//         self.파싱관리자 = 파싱관리자
//         self.데이터베이스관리자 = 데이터베이스관리자
//     }
//     func 관리한다() {
//         let 데이터 = api관리자.요청한다()
//         let 배열 = 파싱관리자.파싱한다(데이터: 데이터)
//         데이터베이스관리자.저장한다(배열)
//     }
// }

// 단일 책임 원칙에 따라 분리

// class APIHandler {
//     func 요청한다() -> Data {
//         // 네트워크에 요청하고 응답을 기다립니다.
//     }
// }
// 
// class ParseHandler {
//     func 파싱한다(data: Data) -> [String] {
//         // 받은 응답을 파싱하여 String 배열에 저장합니다.
//     }
// }
// 
// class DatabaseHandler {
//     func 저장한다(_ array: [String]) {
//         // 파싱한 배열을 데이터베이스에 저장합니다.
//     }
// }

func OCP위반() {
    class 자이언트판다 {
        let 이름: String
        let 성별: String
        
        init(이름: String, 성별: String) {
            self.이름 = 이름
            self.성별 = 성별
        }
        
        func 특성을_출력한다() -> String {
            return "이름: \(이름), 성별: \(성별), 종: 자이어트판다"
        }
    }

    class 관찰일지 {
        func 데이터를_콘솔에_표시한다() {
            let 자이언트판다들 = [
                자이언트판다(이름: "루이바오", 성별: "암컷"),
                자이언트판다(이름: "후이바오", 성별: "암컷"),
            ]
            
            자이언트판다들.forEach { 판다 in
                print(판다.특성을_출력한다())
            }
        }
    }

    관찰일지().데이터를_콘솔에_표시한다()

    // 레서판다 클래스 추가
    class 레서판다 {
        let 이름: String
        let 성별: String
        
        init(이름: String, 성별: String) {
            self.이름 = 이름
            self.성별 = 성별
        }
        
        func 특성을_출력한다() -> String {
            return "이름: \(이름), 성별: \(성별), 종: 레서판다"
        }
    }

    class 관찰일지_v2 {
        func 데이터를_콘솔에_표시한다() {
            let 자이언트판다들 = [
                자이언트판다(이름: "루이바오", 성별: "암컷"),
                자이언트판다(이름: "후이바오", 성별: "암컷"),
            ]
            
            자이언트판다들.forEach { 판다 in
                print(판다.특성을_출력한다())
            }
            
            // 기능을 확장하기 위해 함수의 구현이 변경됨
            let 레서판다들 = [
                레서판다(이름: "레몬", 성별: "암컷"),
                레서판다(이름: "레시", 성별: "수컷"),
            ]
            
            레서판다들.forEach { 판다 in
                print(판다.특성을_출력한다())
            }
        }
    }

    관찰일지_v2().데이터를_콘솔에_표시한다()

}


protocol 출력가능한 {
    func 특성을_출력한다() -> String
}

func OCP준수() {
    
    class 자이언트판다: 출력가능한 {
        let 이름: String
        let 성별: String
        
        init(이름: String, 성별: String) {
            self.이름 = 이름
            self.성별 = 성별
        }
        
        func 특성을_출력한다() -> String {
            return "이름: \(이름), 성별: \(성별), 종: 자이어트판다"
        }
    }
    
    class 레서판다: 출력가능한 {
        let 이름: String
        let 성별: String
        
        init(이름: String, 성별: String) {
            self.이름 = 이름
            self.성별 = 성별
        }
        
        func 특성을_출력한다() -> String {
            return "이름: \(이름), 성별: \(성별), 종: 레서판다"
        }
    }

    class 관찰일지 {
        func 데이터를_콘솔에_표시한다() {
            let 판다들: [출력가능한] = [
                자이언트판다(이름: "루이바오", 성별: "암컷"),
                자이언트판다(이름: "후이바오", 성별: "암컷"),
                레서판다(이름: "레몬", 성별: "암컷"),
                레서판다(이름: "레시", 성별: "수컷"),
            ]
            
            판다들.forEach { 판다 in
                print(판다.특성을_출력한다())
            }
        }
    }
    
    관찰일지().데이터를_콘솔에_표시한다()
}

OCP준수()

func LiskovPrinciple() {
    
}

print("11 22 33".split(separator: " ").map({ Int($0)! }).reduce(0, +))
