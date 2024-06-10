import UIKit

var str = "Hello, playground"

// URL: 한글, 띄어쓰기 등 인식 못함 -> encoding 필요
let urlString = "https://itunes.apple.com/search?media=music&entity=musicVideo&term=collier"
let url = URL(string: urlString)

url?.absoluteString // 절대주소
url?.scheme // http? htttps?
url?.host // "itunes.apple.com"
url?.path // "/search"
url?.query // "media=music&entity=musicVideo&term=collier"
url?.baseURL

let baseURL = URL(string: "https://itunes.apple.com")
let relativeURL = URL(string: "search", relativeTo: baseURL)
relativeURL?.absoluteString
relativeURL?.baseURL
relativeURL?.path

// URLComponents - 한글, 띄어쓰기 등 가능
var urlComponents = URLComponents(string: "https://itunes.apple.com/search?")!
let mediaQuery = URLQueryItem(name: "media", value: "music")
let entityQuery = URLQueryItem(name: "entity", value: "song")
let termQuery = URLQueryItem(name: "term", value: "jacob collier")

urlComponents.queryItems?.append(mediaQuery)
urlComponents.queryItems?.append(entityQuery)
urlComponents.queryItems?.append(termQuery)

urlComponents.url?.scheme
urlComponents.string
urlComponents.queryItems
let requestURL = urlComponents.url!

// URLSession - configuration 먼저 필요
let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)

struct Response: Codable {
    let resultCount: Int
    let tracks: [Track]
    
    enum CodingKeys: String, CodingKey {
        case resultCount
        case tracks = "results"
    }
}

struct Track: Codable {
    let title: String   // trackName
    let artistName: String  // artistName
    let thumbnailPath: String   // artworkUrl100
    
    // 실제 JSON 키와 매핑 (똑같다면 놔두고, 다르다면 오른쪽에 JSON 키이름 입력
    enum CodingKeys: String, CodingKey {
        case title = "trackName"
        case artistName
        case thumbnailPath = "artworkUrl100"
    }
    
}



let dataTask = session.dataTask(with: requestURL) { (data, response, error) in
    
    guard error == nil else { return }
    
    guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
    let successRange = 200..<300
    
    guard successRange.contains(statusCode) else { return }
    
    guard let resultData = data else { return }
    String(data: resultData, encoding: .utf8)
    
    // 트랙 목록을 가져오기 -> 트랙 오브젝트, struct로 파싱 (Codable)
    // - JSON 파일, 데이터 > 오브젝트
    // - Response, Track struct 생성
    // - struct 프로퍼티 이름과 실제 데이터의 키 맞추기 (CodingKey)
    // - 파싱(decoding)
    
    do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(Response.self, from: resultData)
        let tracks = response.tracks
        tracks.count
        tracks.first?.title
        print(tracks.first?.thumbnailPath ?? "error")
    } catch {
        print("error: " + error.localizedDescription)
    }
    
}

dataTask.resume()
