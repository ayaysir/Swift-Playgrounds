import SwiftUI

struct ContentView: View {
    let keywords = ["chives (산파, 백합과)", "fern-leaf (고사리잎) lavender"]
    
    let landscapeName = "Pink_Peony"
    let landscapeCaption = "This photo is wider than it is tall."
    let portraitName = "Yellow_Daisy"
    let portraitCaption = "This photo is taller than it is wide."
    
    let event = Event(title: "Buy Daisies", date: .now, location: "Flower Shop", symbol: "gift")
    
    var body: some View {
        ScrollView {
            VStack {
                TrainCar(.front)
                DefaultSpacing()
                SpecificSpacing()
                ScaledSpacing()
                
                EventTile(event: event)
                
                Divider()
                
                IfElseTrain(longerTrain: true)
                IfElseTrain(longerTrain: false)
                
                Divider()
                
                // Preview -> Dynamic Type 조정해보기
                ForEach(keywords, id: \.self) { word in
                    KeywordBubbleDefaultPadding(keyword: word, symbol: "leaf")
                }
                
                Divider()
                
                ForEach(keywords, id: \.self) { word in
                    KeywordBubble(keyword: word, symbol: "leaf")
                }
                
                Divider()
                
                CaptionedPhoto(assetName: portraitName, captionText: portraitCaption)
                CaptionedPhoto(assetName: landscapeName,
                               captionText: landscapeCaption)
                // Preview -> ColorScheme 조정
                
                Divider()
                
                
            }
        }
    }
}

// 4: Scaling views to complement text
struct KeywordBubbleDefaultPadding: View {
    let keyword: String
    let symbol: String
    
    var body: some View {
        Label(keyword, systemImage: symbol)
            .font(.title)
            .foregroundColor(.white)
            .padding()
            .background(.purple.opacity(0.75), in: Capsule())
    }
}

struct KeywordBubble: View {
    let keyword: String
    let symbol: String
    
    /// This paddingWidth variable provides a value of 14.5 for content in a `DynamicTypeSize.large` Dynamic Type environment. With the `ScaledMetric` property wrapper, the value is proportionally larger or smaller, according to the current value of `dynamicTypeSize`.
    @ScaledMetric(relativeTo: .title) var paddingWidth = 14.5
    
    var body: some View {
        Label(keyword, systemImage: symbol)
            .font(.title)
            .foregroundColor(.white)
            .padding(paddingWidth) // DynamicSize에 따라 패딩이 자동으로 늘어남
            .background {
                Capsule()
                    .fill(.purple.opacity(0.75))
            }
        
        
    }
}

// 5: Layering content
struct CaptionedPhoto: View {
    let assetName: String
    let captionText: String
    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .overlay(alignment: .bottom) {
                Caption(text: captionText)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding()
    }
}

struct Caption: View {
    let text: String
    
    var body: some View {
        Text(text)
        // This padding(_:_:) modifier adds some space between the words and the edges of the contrasting background underneath. The structure of the code matches the visual appearance of the view — the padding is between the text and the background.
        // Text 외부에 패딩
            .padding()
            .background(Color("TextContrast").opacity(0.75), in: RoundedRectangle(cornerRadius: 10.0, style: .continuous))
        // This additional padding(_:_:) around the background adds space between the outside of the Caption view and the container it appears inside; in this case, CaptionedPhoto is the containing view.
        // 사진과 캡션 사이
            .padding()
            
    }
}

// 6: Choosing the right way to hide a view
struct IfElseTrain: View {
    var longerTrain: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "train.side.rear.car")
                
                // 1: if ~ else
                // When longerTrain is false, the middle car doesn’t exist, and the other cars are closer together.
                if longerTrain {
                    Image(systemName: "train.side.middle.car")
                }
                
                // 2: opcaity
                // But when longerTrain is false, the middle car still takes up space in this train.
                Image(systemName: "train.side.middle.car")
                    .opacity(longerTrain ? 1 : 0)
                
                Image(systemName: "train.side.front.car")
            }
            
            Divider()
        }
    }
}

// 7: Organizing and aligning content with stacks
struct Event {
    let title: String
    let date: Date
    let location: String
    let symbol: String
}

struct EventTile: View {
    let event: Event
    let stripeHeight = 15.0
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: event.symbol)
            // The title font makes the title text and the gift image more prominent than any content in the default body font.
                .font(.title)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title)
                Text(
                    event.date,
                    format: Date.FormatStyle()
                        .day(.defaultDigits)
                        .month(.wide)
                )
                Text(event.location)
            }
        }
        .padding()
        .padding(.top, stripeHeight)
        .background {
            ZStack(alignment: .top) {
                // 배경 사각형
                Rectangle()
                    .opacity(0.3)
                // 상단 stripeHeight 높이만큼의 사각형 (더 밝은)
                Rectangle()
                    .frame(maxHeight: stripeHeight)
            }
            .foregroundColor(.teal)
        }
        .clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
    }
}

// 8: Adjusting the space between views
enum TrainSymbol: String {
    case front = "train.side.front.car"
    case middle = "train.side.middle.car"
    case rear = "train.side.rear.car"
}

struct TrainCar: View {
    let position: TrainSymbol
    let showFrame: Bool
    
    init(_ position: TrainSymbol, showFrame: Bool = true) {
        self.position = position
        self.showFrame = showFrame
    }
    
    var body: some View {
        Image(systemName: position.rawValue)
            .background(.pink)
    }
}

struct TrainTrack: View {
    var body: some View {
        Divider()
            .frame(maxWidth: 200)
    }
}

struct DefaultSpacing: View {
    var body: some View {
        Text("Defàult Spacing")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        TrainTrack()
    }
}

struct SpecificSpacing: View {
    var body: some View {
        Text("Spécific Spacing")
        HStack(spacing: 20) {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        TrainTrack()
    }
}

struct ScaledSpacing: View {
    /// The `ScaledMetric` property wrapper configures the `trainCarSpace` property to change in proportion to the current `body` font size.
    @ScaledMetric var trainCarSpace = 5
    
    var body: some View {
        Text("Scaled Spacing")
        HStack(spacing: trainCarSpace) {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        TrainTrack()
    }
}

struct ZeroSpacing: View {
    var body: some View {
        Text("Scaled Spacing")
        HStack(spacing: 0) {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        TrainTrack()
    }
}
