import UIKit

func 단일책임원칙() {
    class API관리자_SRP위반 {
        func 관리한다() {
            let 데이터 = API에_데이터를_요청한다()
            let 배열 = 응답을_파싱한다(data: 데이터)
            데이터베이스에_저장한다(array: 배열)
        }
    
        private func API에_데이터를_요청한다() -> Data {
            // 네트워크에 요청하고 응답을 기다립니다.
    
            return .init()
        }
    
        private func 응답을_파싱한다(data: Data) -> [String] {
            // 받은 응답을 파싱하여 String 배열에 저장합니다.
    
            return []
        }
    
        private func 데이터베이스에_저장한다(array: [String]) {
            // 파싱한 배열을 데이터베이스에 저장합니다.
        }
    }
     
    class 관리자 {
        let api관리자: APIHandler
        let 파싱관리자: ParseHandler
        let 데이터베이스관리자: DatabaseHandler
    
        // 생성자
        init(api관리자: APIHandler, 파싱관리자: ParseHandler, 데이터베이스관리자: DatabaseHandler) {
            self.api관리자 = api관리자
            self.파싱관리자 = 파싱관리자
            self.데이터베이스관리자 = 데이터베이스관리자
        }
        func 관리한다() {
            let 데이터 = api관리자.요청한다()
            let 배열 = 파싱관리자.파싱한다(데이터: 데이터)
            데이터베이스관리자.저장한다(배열)
        }
    }

    // 단일 책임 원칙에 따라 분리

    class APIHandler {
        func 요청한다() -> Data {
            // 네트워크에 요청하고 응답을 기다립니다.
            return Data()
        }
    }
    
    class ParseHandler {
        func 파싱한다(데이터: Data) -> [String] {
            // 받은 응답을 파싱하여 String 배열에 저장합니다.
            return []
        }
    }
    
    class DatabaseHandler {
        func 저장한다(_ array: [String]) {
            // 파싱한 배열을 데이터베이스에 저장합니다.
        }
    }
}



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

// https://inpa.tistory.com/entry/OOP-%F0%9F%92%A0-%EC%95%84%EC%A3%BC-%EC%89%BD%EA%B2%8C-%EC%9D%B4%ED%95%B4%ED%95%98%EB%8A%94-LSP-%EB%A6%AC%EC%8A%A4%EC%BD%94%ED%94%84-%EC%B9%98%ED%99%98-%EC%9B%90%EC%B9%99
func LiskovPrinciple() {
    // Case 1: 자식의 잘못된 메소드 오버로딩
    class Animal {
        var speed: Int = 100
        
        func move(distance: Int) {
            speed * distance
        }
        
        /// case 2에서 사용: 여기에 실제 동물을 입력하면 종류를 알려줍니다. (함부로 바꾸지 마)
        var type: NaturalType {
            NaturalType(animal: self)
        }
    }
    
    class Eagle: Animal {
        func move(distance: Int, isFlying: Bool) {
            "\(distance) 만큼 \(isFlying ? "날아서" : "걸어서") 갔어요."
        }
    }
    
    let eagle: Animal = Eagle()
    // // Extra argument 'isFlying' in call - 그런거 없다
    // eagle.move(distance: 3, isFlying: true)
    
    // Case 2: 부모의 의도와 다르게 메소드 오버라이딩
    class NaturalType {
        var typeText: String
        
        init(animal: Animal) {
            self.typeText = switch animal {
            case is Cat:
                "포유류"
            case is Kraken:
                "연체동물"
            default:
                "알 수 없는 종류"
            }
        }
        
        func description() -> String {
            "이 동물의 종류는 " + typeText + " 입니다."
        }
    }
    
    class Cat: Animal {}
    
    let cat: Animal = Cat()
    print(cat.type.description()) // 이 동물의 종류는 포유류 입니다.
    
    // 어느 미친 고양이가 트롤링 시전
    
    class Kraken: Animal {}
    
    class CrazyCat: Animal {
        override var type: NaturalType {
            .init(animal: Kraken())
        }
        
        var getDescription: String {
            "이 동물의 종류는 포유류 입니다."
        }
    }
    
    let crazyCat: Animal = CrazyCat()
    print(crazyCat.type.description()) // 이 동물의 종류는 연체동물 입니다.
 
}
LiskovPrinciple()

protocol AbstractAnimal {
    func speak()
}

extension AbstractAnimal {
    /// 동물들의 우는 소리를 콘솔에 출력합니다.
    func speak() {}
}

func LiskovPrinciple_Case3_1() {
    // Case 3: 잘못된 상속 관계 구성으로 인한 메서드 정의
    
    class Dog: AbstractAnimal {
        func speak() {
            print("멍멍")
        }
    }
    
    class LeBao: AbstractAnimal {
        func speak() {
            print("ㅓㅗㅗㅔㅔㅓㅢㅔ")
        }
    }
    
    class InsaneCat: AbstractAnimal {
        func speak() {
            fatalError("나̶̨̡̛̛̛͇̹̜͓͙͕̩̘͓̯̤̮̹͈̫̪͓̯̗̳̈́̿͑̈́̈́̔͂̂͊̐͌́͐̔̇͂̚는̵̡̧̢̢̧̛͚̯̬̩̩̝̫̯̜͖͎͎̱̣̜͙̝̫̰̤̱̋̈̀̒̔͐͑̌̄̒̾̋̌͆͊̄̀͐͂̓͛̄̓̕͘͝͠͝ ̵̧̧̨̡̛͇̫̣̜̘̖̭̩̼̞̯̺̰̦̜̼̞̣͌̒́͌͋̒͐̀̒̓̒͂̓̈́̈̚̚͜͠͝바̷̨̨̡̖̫͙̖̼̲̳͖̞͔̺̟͚͎̹̝̺͖̱͕͍͇̙̣̜̳̩̃͆̇̌̇́̀̓̉́̐͜͠다̷̬͈̪̙̗̟̬̦͔͇͙͉̣̻̦͔̠̼͈̺͎̀̌̀̈̀̂̃̀̉͜ͅͅ의̵̢̨̲̗̺͕̼̰̬͖̰̘̬̘̯̫͖̞̯̝̭̬̦̰͕͉̜͐̊̀́̄͘̚͠ͅ ̴̧̨̡͔̣̪͍͓͔̲̹̹̺͚̳̼̣̱͉̄̌͌͊̎̽̌̌̉̀̅̅̇͘͜͠왕̴̢̡͓̠̩̝̙̲͕̟͉̬͓̼̭͓̍̀͛͂̎̍̍̆͜ͅ자̴̡̧̭̜̳̥̥̖͈̱̘̭̻͔̉͋̐̀̈̏̅͆̊̋͂̀̑̅̍̅̉͊̓́͒̏̇̋̅̂̕̚͘͝ ̶̨̱̱̺̙̘̓͂̓͊͂̇͊̊͆̇́͋̒̈͐͋̓̎͆̍͋̍̓͝͝벵̴̧̢̡̡̧̢̛͈̳̪̤̞̼͉͉͍̦̗̻̟̯͇̭̜̘̥̳̫̫͖̰̍͊̈͊ͅͅ골̷̧̨̧̬̻̤̯̮̻̘̳̞̖̯̭͓̻̞͈̮̱̮̻͙̯̗̯̯̽̐̈͌̓͒̇̂̄̿̄͑̃͜͝ͅͅͅ호̷̠̘̪͍͖̲͚̰̳̝̞̩̪̳͚̼̦́͌̔̎̈́̅́̈̌̒͑̀̍͊̀͂̿̃̆̈̐͋̒̉̂̍̂͋̇̂͘͘̚͜ͅ랑̶̡̛̲̥̗̝͉̺̱̭̤̩̬̪͚͈̜͈̫ͅ이̵̧̲̯̟̦̺͉̜̤͙̀이̴̢̡͇̭̠̝̙̼̖̣̪̲̦̗͚̱̺̦͎͓̬͓̠̾̌͝다̷̰͍̝̩̺̦̜̬̟̻̺̟͔̩̱̫͓͖̺̺̮̥͖̈́͒̒̒̈́͗́͂̽͑̈͂̄͋̌̀̑̈́̾̓͒́͒̒̔̑̔̂͘̕̚͝͠.̶̧̡͚̱̬̥̪̭͍͈̙̥̝̜̹̺̪̫̞͙̝͓̮̻̗̮̪̦͈̝͖͂͑͒̾̉̑̿̋̆́̌̈́̐̒̍̅̉̓͂͘͜")
        }
    }
    
    let animals: [AbstractAnimal] = [Dog(), LeBao(), InsaneCat()]
    animals.forEach { animal in
        animal.speak()
    }
    /*
     멍멍
     ㅓㅗㅗㅔㅔㅓㅢㅔ
     __lldb_expr_1985/SOLID Principles.playground:285: Fatal error: 나̶̨̡̛̛̛͇̹̜͓͙͕̩̘͓̯̤̮̹͈̫̪͓̯̗̳̈́̿͑̈́̈́̔͂̂͊̐͌́͐̔̇͂̚는̵̡̧̢̢̧̛͚̯̬̩̩̝̫̯̜͖͎͎̱̣̜͙̝̫̰̤̱̋̈̀̒̔͐͑̌̄̒̾̋̌͆͊̄̀͐͂̓͛̄̓̕͘͝͠͝ ̵̧̧̨̡̛͇̫̣̜̘̖̭̩̼̞̯̺̰̦̜̼̞̣͌̒́͌͋̒͐̀̒̓̒͂̓̈́̈̚̚͜͠͝바̷̨̨̡̖̫͙̖̼̲̳͖̞͔̺̟͚͎̹̝̺͖̱͕͍͇̙̣̜̳̩̃͆̇̌̇́̀̓̉́̐͜͠다̷̬͈̪̙̗̟̬̦͔͇͙͉̣̻̦͔̠̼͈̺͎̀̌̀̈̀̂̃̀̉͜ͅͅ의̵̢̨̲̗̺͕̼̰̬͖̰̘̬̘̯̫͖̞̯̝̭̬̦̰͕͉̜͐̊̀́̄͘̚͠ͅ ̴̧̨̡͔̣̪͍͓͔̲̹̹̺͚̳̼̣̱͉̄̌͌͊̎̽̌̌̉̀̅̅̇͘͜͠왕̴̢̡͓̠̩̝̙̲͕̟͉̬͓̼̭͓̍̀͛͂̎̍̍̆͜ͅ자̴̡̧̭̜̳̥̥̖͈̱̘̭̻͔̉͋̐̀̈̏̅͆̊̋͂̀̑̅̍̅̉͊̓́͒̏̇̋̅̂̕̚͘͝ ̶̨̱̱̺̙̘̓͂̓͊͂̇͊̊͆̇́͋̒̈͐͋̓̎͆̍͋̍̓͝͝벵̴̧̢̡̡̧̢̛͈̳̪̤̞̼͉͉͍̦̗̻̟̯͇̭̜̘̥̳̫̫͖̰̍͊̈͊ͅͅ골̷̧̨̧̬̻̤̯̮̻̘̳̞̖̯̭͓̻̞͈̮̱̮̻͙̯̗̯̯̽̐̈͌̓͒̇̂̄̿̄͑̃͜͝ͅͅͅ호̷̠̘̪͍͖̲͚̰̳̝̞̩̪̳͚̼̦́͌̔̎̈́̅́̈̌̒͑̀̍͊̀͂̿̃̆̈̐͋̒̉̂̍̂͋̇̂͘͘̚͜ͅ랑̶̡̛̲̥̗̝͉̺̱̭̤̩̬̪͚͈̜͈̫ͅ이̵̧̲̯̟̦̺͉̜̤͙̀이̴̢̡͇̭̠̝̙̼̖̣̪̲̦̗͚̱̺̦͎͓̬͓̠̾̌͝다̷̰͍̝̩̺̦̜̬̟̻̺̟͔̩̱̫͓͖̺̺̮̥͖̈́͒̒̒̈́͗́͂̽͑̈͂̄͋̌̀̑̈́̾̓͒́͒̒̔̑̔̂͘̕̚͝͠.̶̧̡͚̱̬̥̪̭͍͈̙̥̝̜̹̺̪̫̞͙̝͓̮̻̗̮̪̦͈̝͖͂͑͒̾̉̑̿̋̆́̌̈́̐̒̍̅̉̓͂͘͜
     */
}

protocol Speakable {
    func speak()
}

func LiskovPrinciple_Case3_2() {
    class Animal {}
    
    class Dog: Animal, Speakable {
        func speak() {
            print("멍멍")
        }
    }
    
    class LeBao: Animal, Speakable {
        func speak() {
            print("ㅓㅗㅗㅔㅔㅓㅢㅔ")
        }
    }
    
    class InsaneCat: Animal {
        func speak() {
            fatalError("나̶̨̡̛̛̛͇̹̜͓͙͕̩̘͓̯̤̮̹͈̫̪͓̯̗̳̈́̿͑̈́̈́̔͂̂͊̐͌́͐̔̇͂̚는̵̡̧̢̢̧̛͚̯̬̩̩̝̫̯̜͖͎͎̱̣̜͙̝̫̰̤̱̋̈̀̒̔͐͑̌̄̒̾̋̌͆͊̄̀͐͂̓͛̄̓̕͘͝͠͝ ̵̧̧̨̡̛͇̫̣̜̘̖̭̩̼̞̯̺̰̦̜̼̞̣͌̒́͌͋̒͐̀̒̓̒͂̓̈́̈̚̚͜͠͝바̷̨̨̡̖̫͙̖̼̲̳͖̞͔̺̟͚͎̹̝̺͖̱͕͍͇̙̣̜̳̩̃͆̇̌̇́̀̓̉́̐͜͠다̷̬͈̪̙̗̟̬̦͔͇͙͉̣̻̦͔̠̼͈̺͎̀̌̀̈̀̂̃̀̉͜ͅͅ의̵̢̨̲̗̺͕̼̰̬͖̰̘̬̘̯̫͖̞̯̝̭̬̦̰͕͉̜͐̊̀́̄͘̚͠ͅ ̴̧̨̡͔̣̪͍͓͔̲̹̹̺͚̳̼̣̱͉̄̌͌͊̎̽̌̌̉̀̅̅̇͘͜͠왕̴̢̡͓̠̩̝̙̲͕̟͉̬͓̼̭͓̍̀͛͂̎̍̍̆͜ͅ자̴̡̧̭̜̳̥̥̖͈̱̘̭̻͔̉͋̐̀̈̏̅͆̊̋͂̀̑̅̍̅̉͊̓́͒̏̇̋̅̂̕̚͘͝ ̶̨̱̱̺̙̘̓͂̓͊͂̇͊̊͆̇́͋̒̈͐͋̓̎͆̍͋̍̓͝͝벵̴̧̢̡̡̧̢̛͈̳̪̤̞̼͉͉͍̦̗̻̟̯͇̭̜̘̥̳̫̫͖̰̍͊̈͊ͅͅ골̷̧̨̧̬̻̤̯̮̻̘̳̞̖̯̭͓̻̞͈̮̱̮̻͙̯̗̯̯̽̐̈͌̓͒̇̂̄̿̄͑̃͜͝ͅͅͅ호̷̠̘̪͍͖̲͚̰̳̝̞̩̪̳͚̼̦́͌̔̎̈́̅́̈̌̒͑̀̍͊̀͂̿̃̆̈̐͋̒̉̂̍̂͋̇̂͘͘̚͜ͅ랑̶̡̛̲̥̗̝͉̺̱̭̤̩̬̪͚͈̜͈̫ͅ이̵̧̲̯̟̦̺͉̜̤͙̀이̴̢̡͇̭̠̝̙̼̖̣̪̲̦̗͚̱̺̦͎͓̬͓̠̾̌͝다̷̰͍̝̩̺̦̜̬̟̻̺̟͔̩̱̫͓͖̺̺̮̥͖̈́͒̒̒̈́͗́͂̽͑̈͂̄͋̌̀̑̈́̾̓͒́͒̒̔̑̔̂͘̕̚͝͠.̶̧̡͚̱̬̥̪̭͍͈̙̥̝̜̹̺̪̫̞͙̝͓̮̻̗̮̪̦͈̝͖͂͑͒̾̉̑̿̋̆́̌̈́̐̒̍̅̉̓͂͘͜")
        }
    }
    
    let animals: [Speakable] = [Dog(), LeBao()] // InsaneCat은 들어갈 수 없음
    animals.forEach { animal in
        animal.speak()
    }
}
LiskovPrinciple_Case3_2()
/*
 멍멍
 ㅓㅗㅗㅔㅔㅓㅢㅔ
 */

print("11 22 33".split(separator: " ").map({ Int($0)! }).reduce(0, +))

protocol DataProvider {
    func getData() -> String
}

func 의존성역전() {
    /*
     의존성 역전은 고수준 모듈이 저수준 모듈에 의존하면서 인터페이스에 의존해야 한다는 원칙입니다. 아래 코드에서 UserService는 DataProvider 프로토콜에 의존하면서 실제 데이터를 제공하는 DatabaseProvider와 APIProvider는 이 프로토콜을 따르도록 구현되어 있습니다. 이렇게 하면 UserService가 구체적인 데이터 제공자에 직접 의존하지 않고, 의존성 주입을 통해 원하는 데이터 제공자를 선택할 수 있게 됩니다.

     1. **고수준 모듈 (`UserService`)**
        - 의존성: `DataProvider` 프로토콜
        - 의존성 주입을 통해 저수준 모듈과의 결합을 유연하게 처리

     2. **저수준 모듈 (`DataProvider` 프로토콜을 따르는 `DatabaseProvider` 및 `APIProvider`)**
        - 의존성: `DataProvider` 프로토콜
        - `DatabaseProvider`와 `APIProvider`는 `DataProvider` 프로토콜을 구현하여 제공된 인터페이스를 고수준 모듈에 제공

     간단한 의존성 그래프는 다음과 같습니다:

     ```
                  +-----------------------+
                  |    UserService        |
                  |-----------------------|
                  |   - dataProvider:     |
                  |    DataProvider       |
                  +-----------------------+
                              ^
                              |
     +-------------------+    |    +-----------------+
     | DatabaseProvider  |----+----|   APIProvider   |
     |-------------------|         |-----------------|
     |   - getData()     |         |  - getData()    |
     |     -> String     |         |   -> String     |
     +------------------------+----------------------+
     ```

     이 그래프에서 `UserService`는 `DataProvider` 프로토콜에 의존하면서 실제 데이터를 제공하는 `DatabaseProvider` 및 `APIProvider`는 이 프로토콜을 따르도록 구현되어 있습니다. 의존성 주입을 통해 실제 사용할 데이터 제공자를 선택할 수 있습니다.
     */
    
    // 고수준 모듈
    class UserService {
        private let dataProvider: DataProvider
        
        init(dataProvider: DataProvider) {
            self.dataProvider = dataProvider
        }
        
        func getUser() -> String {
            return dataProvider.getData()
        }
    }
    
    /*
     // 저수준 모듈
     protocol DataProvider {
         func getData() -> String
     }
     */

    class DatabaseProvider: DataProvider {
        func getData() -> String {
            return "User data from database"
        }
    }

    class APIProvider: DataProvider {
        func getData() -> String {
            return "User data from API"
        }
    }

    // 의존성 주입
    let databaseProvider = DatabaseProvider()
    let userServiceWithDB = UserService(dataProvider: databaseProvider)
    print(userServiceWithDB.getUser())  // 출력: "User data from database"

    let apiProvider = APIProvider()
    let userServiceWithAPI = UserService(dataProvider: apiProvider)
    print(userServiceWithAPI.getUser())  // 출력: "User data from API"
}
의존성역전()

// ============================================================ //
// 프로토콜 분리 전
protocol Worker {
    func work()
    func takeBreak()
    func attendMeeting()
}

class Employee_HasHeavyProtocol: Worker {
    func work() {
        // 직원의 업무 수행 로직
    }

    func takeBreak() {
        // 휴식을 취하는 로직
    }

    func attendMeeting() {
        // 회의 참석 로직
    }
}

// 프로토콜 분리 후
protocol Workable {
    func work()
}

protocol Breakable {
    func takeBreak()
}

protocol Attendable {
    func attendMeeting()
}

class Employee: Workable, Breakable, Attendable {
    func work() {
        // 직원의 업무 수행 로직
    }

    func takeBreak() {
        // 휴식을 취하는 로직
    }

    func attendMeeting() {
        // 회의 참석 로직
    }
}

/*
 프로토콜 분리 원칙은 하나의 프로토콜이 너무 많은 기능을 포함하지 않고 특정 관심사에 집중해야 한다는 원칙입니다. 이를 통해 코드 유지보수성과 재사용성을 향상시킬 수 있습니다.
 위의 코드에서 프로토콜 분리 전에는 하나의 Worker 프로토콜이 모든 기능을 포함하고 있었습니다. 그러나 프로토콜 분리 후에는 Workable, Breakable, Attendable과 같이 각각의 관심사에 맞게 프로토콜을 정의하였습니다. 이렇게 함으로써 각 클래스나 타입은 필요한 기능만을 채택하여 사용할 수 있게 되어 불필요한 의존성을 제거하고 코드를 더욱 모듈화하고 유연하게 만들 수 있습니다.
 */

func exampleFunction() {
    defer {
        print("This is a deferred closure.")
    }

    // 어떤 작업들

    let closure = {
        print("This is a closure inside exampleFunction.")
    }

    closure()

    // 어떤 작업들
}

// 함수 호출
exampleFunction()
/*
 This is a closure inside exampleFunction.
 This is a deferred closure.
 */
