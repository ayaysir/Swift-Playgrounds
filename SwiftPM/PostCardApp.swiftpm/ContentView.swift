import SwiftUI

/// 생성자로 String 파라미터 한 개를 갖는 인터페이스입니다.
protocol HasStringParameter {
    init(_ stringParameter: String)
}

extension Text: HasStringParameter {}

extension Image: HasStringParameter {
    init(_ stringParameter: String) {
        self.init(stringParameter, bundle: nil)
    }
}

/// 링크 주소를 입력하면 하이퍼링크를 생성하는 뷰입니다.
struct WebLinkView: View, HasStringParameter {
    var url: URL
    var descriptionValue: String?
    
    init(_ stringParameter: String) {
        url = .init(string: stringParameter)!
    }
    
    init(stringParameter: String, descriptionValue: String? = nil) {
        url = .init(string: stringParameter)!
        self.descriptionValue = descriptionValue
    }
    
    var body: some View {
        Text("[\(descriptionValue ?? url.absoluteString)](\(url.absoluteString))")
    }
}

/// 블록뷰
struct BlockView<InnerView: View>: View where InnerView: HasStringParameter {
    let innerView: InnerView
    
    init(_ stringParameter: String) {
        innerView = InnerView(stringParameter)
    }
    
    var body: some View {
        innerView
    }
    
    @ViewBuilder func resizable() -> some View {
        if let innerView = innerView as? Image {
            innerView.resizable()
        } else {
            innerView
        }
        
    }
}

/// 포스트카드 모델
struct PostCard: Codable {
    var title: String
    var imageName: String
    var urlString: String
}

/// 포스트카드 표시 (헤더, 본문, 푸터)
struct PostCardView: View {
    enum Mode {
        case header, body, footer
    }
    
    @State var mode: Mode = .body
    @State var postCard: PostCard?
    
    var body: some View {
        switch mode {
        case .header:
            Text("Header")
        case .body:
            if let postCard  {
                VStack {
                    BlockView<Text>(postCard.title)
                        .font(.title)
                        .bold()
                    BlockView<Image>(postCard.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    BlockView<WebLinkView>(postCard.urlString)
                }
            } else {
                Text("Error")
            }
        case .footer:
            Text("Footer")
        }
        
        Divider()
    }
}

/// 메인 뷰
struct ContentView: View {
    @State var cards: [PostCard] = [
        .init(title: "홍길동", imageName: "sample1", urlString: "https://google.com"),
        .init(title: "임꺽정", imageName: "sample2", urlString: "https://apple.com"),
        .init(title: "이생원", imageName: "sample3", urlString: "https://microsoft.com"),
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                PostCardView(mode: .header)
                ForEach(cards, id: \.title) { card in
                    PostCardView(postCard: card)
                }
                PostCardView(mode: .footer)
            }
        }
    }
}
