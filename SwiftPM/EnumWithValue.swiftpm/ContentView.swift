import SwiftUI

enum Direction: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case east = "동"
    case west = "서"
    case south = "남"
    case north = "북"
}

enum PostStateError: Error {
    case cannnotLoadPost
}

enum PostState: Hashable {
    case loading
    case post(String)
    case photo(Data)
    case video(URL)
    case error(PostStateError)
}



extension Array<Int> {
    func accumulate<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        /*
         rethrows
         - 클로저에서 발생한 에러를 다시 밖으로 던짐
         https://ios-development.tistory.com/941
         */
        
        var partialResult = initialResult
        
        try self.forEach { value in
            partialResult = try nextPartialResult(partialResult, value)
        }
        
        return partialResult
    }
}

func reduceTest1() {
    let array = [1, 2, 3, 4, 5]
    print(array.reduce(0, { $0 + $1 })) // 15
    print(array.accumulate(0, { $0 + $1 })) // 15
}

struct ContentView: View {
    @State var direction: Direction = .east
    @State var postState: PostState = .error(.cannnotLoadPost)
    
    var body: some View {
        VStack {
            Picker(selection: $direction) {
                ForEach(Direction.allCases, id: \.id) {
                    // Custom Enum인 경우 tag에 값 지정해야 변경됨
                    Text($0.rawValue).tag($0)
                }
            } label: {
                Text("방향을 선택하세요.")
            }
            
            switch postState {
            case .loading:
                Text("로딩 중...")
            case .post(let string):
                Text("게시글 표시: \(string)")
            case .photo(let data):
                Text("사진 - Data를 Image로 변환: \(data)")
            case .video(let url):
                Text("영상 - URL로부터 영상을 읽어와 플레이어 생성: \(url)")
            case .error(let postStateError):
                Text("에러 처리: \(postStateError.localizedDescription)")
            }
        }
        .onAppear {
            reduceTest1()
        }
    }
}
