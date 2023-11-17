import SwiftUI

struct CellData {
    var title: String
    var comment: String
}

struct ContentView: View {
    let data: [CellData] = [
        .init(title: "QR코드 스캔", comment: "결제 확인, 로그인"),
        .init(title: "QR코드 스캔", comment: "결제 확인, 로그인"),
        .init(title: "QR코드 스캔", comment: "결제 확인, 로그인"),
        .init(title: "QR코드 스캔", comment: "결제 확인, 로그인"),
    ]
    
    var body: some View {
        // VStack {
        //     HStack(alignment: .top) {
        //         Spacer()
        //         Image(systemName: "gear")
        //     }.padding(.horizontal, 10)
        //
        //     Spacer()
        //
        //     if #available(iOS 16.0, *) {
        //         NavigationStack {
        //             ScrollView {
        //                 ForEach(0..<4) { index in
        //                     CardCell(cellData: .init(title: data[index].title, comment: data[index].comment))
        //                 }
        //             }
        //             .navigationTitle("Card")
        //         }
        //         .ignoresSafeArea()
        //     } else {
        //         EmptyView()
        //     }
        // }
        
        VStack {
            Spacer(minLength: 20)
            Text("A")
                .font(.system(size: 160, weight: .heavy))
            Spacer()
            LazyVGrid(columns: [
                .init(),
                .init(),
                .init()
            ], spacing: 70) {
                ForEach(0..<9) { index in
                    Circle()
                        .frame(width: 10)
                        
                }
            }
            .padding(50)
            
            Spacer(minLength: 60)
            Text("혹시 패턴을 잊으셨나요?")
                .foregroundColor(.gray)
                .underline()
        }
    }
}

struct CardCell: View {
    var cellData: CellData
    
    var body: some View {
        HStack {
            VStack {
                Text(cellData.title)
                    .font(.title)
                Text(cellData.comment)
            }
            Spacer()
            Image(systemName: "gear")
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }
}
