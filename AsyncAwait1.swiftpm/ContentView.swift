import SwiftUI

struct ContentView: View {
    let randomImageUrlBase:String  = "https://source.unsplash.com/random/?"

    @State var image: UIImage? = nil
    @State var thumbnail: UIImage? = nil
    @State var isLoading: Bool = false
    @State var query: String = ""

    private func loadRandomImage() {
        let urlString = randomImageUrlBase + query
        
        // dataTask(with:completionHandler:)로 데이터를 가져와서
        guard let url = URL(string: urlString) else {
            print("url is malformed")
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data else {
                print("data is nil")
                return
            }
            
            guard let image = UIImage(data: data) else {
                print("image creation failed")
                return
            }
            
            self.image = image
            
            image.prepareThumbnail(of: .init(width: 100, height: 100)) { thumbnail in
                self.thumbnail = thumbnail
                isLoading = false
            }
        }
        
        task.resume()
        // UIImage(data:)로 이미지를 만들고
        // prepareThumbnail(of:completionHandler:) 로 썸네일을 만드세요
    }
    
    private func loadRandomImageAsync() async throws {
        let urlString = randomImageUrlBase + query
        
        // dataTask(with:completionHandler:)로 데이터를 가져와서
        guard let url = URL(string: urlString) else {
            print("url is malformed")
            return
        }
        
        let request = URLRequest(url: url)
        let result = try await URLSession.shared.data(for: request)
        let data = result.0
        let response = result.1
        
        guard let image = UIImage(data: data) else {
            return
        }
        self.image = image
        
        guard let thumbnail = await image.byPreparingThumbnail(ofSize: .init(width: 100, height: 100)) else {
            return
        }
        self.thumbnail = thumbnail
    }

    var body: some View {
        VStack {
            ZStack {
                if let image, !isLoading {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                
                if isLoading {
                    Text("로딩중...")
                }
            }
            
            if let thumbnail, !isLoading {
                Image(uiImage: thumbnail)
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            
            Button {
                Task {
                    isLoading = true
                    try await loadRandomImageAsync()
                    isLoading = false
                }
                
            } label: {
                Text("불러오기")
            }
        }
        
    }
}
