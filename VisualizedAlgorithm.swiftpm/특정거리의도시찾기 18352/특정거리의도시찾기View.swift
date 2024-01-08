//
//  특정거리의도시찾기View.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/02.
//

import SwiftUI

struct 특정거리의도시찾기View: View {
    enum CityViewMode {
        case city, road
    }
    
    @StateObject var viewModel = 특정거리의도시찾기ViewModel()
    @State private var connect: [Int: [Bool]] = [
        1: .init(repeating: false, count: 5),
        2: .init(repeating: false, count: 5),
        3: .init(repeating: false, count: 5),
        4: .init(repeating: false, count: 5),
    ]
    @State private var currentExample = 1
    @State private var currentResult: [Int] = []
    @State private var currentHistories: [TraverseHistory] = []
    
    @State private var sliderValue: Double = 0.0
    
    private func connectPath(_ key: Int, _ destination: Int) -> Binding<Bool> {
        .init {
            self.connect[key]![destination]
        } set: {
            self.connect[key]![destination] = $0
        }
    }
    
    // History 관련
    @State var currentHistory: TraverseHistory?
    @State var currentFrame = 0
    @State var enableNavigationButton = true
    
    var body: some View {
        VStack {
            Text("특정 거리의 도시 찾기")
                .font(.largeTitle)
            
            Picker("", selection: $currentExample) {
                ForEach(viewModel.mapInfos.indices, id: \.self) { index in
                    if index != 0 {
                        Text("예제 \(index)")
                            .tag(index)
                    }
                }
            }
            .pickerStyle(.segmented)
            
            Spacer()
                .frame(height: 50)
            
            HStack {
                cityArea(1)
                
                // 1-2, 2-1
                ArrowSet(direction: .right, isOneOn: connectPath(1, 2), isTwoOn: connectPath(2, 1))
                
                cityArea(2)
            }
            HStack {
                // 1-3, 3-1
                ArrowSet(direction: .down, isOneOn: connectPath(1, 3), isTwoOn: connectPath(3, 1))
                ZStack {
                    // 3-2, 2-3
                    ArrowSet(direction: .diagonal, isOneOn: connectPath(3, 2), isTwoOn: connectPath(2, 3))
                    // 1-4, 4-1
                    ArrowSet(direction: .diagonalReverse, isOneOn: connectPath(1, 4), isTwoOn: connectPath(4, 1))
                }
                // 2-4, 4-2
                ArrowSet(direction: .down, isOneOn: connectPath(2, 4), isTwoOn: connectPath(4, 2))
            }
            HStack {
                cityArea(3)
                
                // 3-4, 4-3
                ArrowSet(direction: .right, isOneOn: connectPath(3, 4), isTwoOn: connectPath(4, 3))
                
                cityArea(4)
            }
            
            Spacer()
                .frame(height: 25)
            VStack {
                if let currentHistory {
                    if currentHistory.vistedNext, currentHistory.state == .before {
                        Text("이미 방문한 경우엔 그냥 지나갑니다!")
                    } else if currentHistory.now >= 1, currentHistory.distancePrev == -99 {
                        Text("여기서부터 다음 도시들까지 방문 여부를 측정!")
                    } else if currentHistory.state == .before && currentHistory.distanceNext == -1 {
                        Text("처음 발을 닿은 것 같습니다!")
                    } else if currentHistory.vistedNext, currentHistory.state == .after  {
                        Text("여기까지 거리(\(currentHistory.distanceNext)) = 현재도시의 누적거리(\(currentHistory.distancePrev))\n+ 다음도시까지의 거리(1)")
                    }
                }
            }
            .frame(height: 50)
            Divider()
            
            VStack {
                Text("목표 최단거리: \(viewModel.mapInfos[currentExample]!.shortestDistance) \t ") + Text("결과: \(resultFormatter(currentResult))")
            }
            
            Divider()
            
            HStack {
                Button("", systemImage: "backward.end.fill") {
                    guard currentFrame > 0 else {
                        return
                    }
                    
                    currentFrame -= 1
                    drawHistory(currentHistories[currentFrame])
                }
                .disabled(!enableNavigationButton)
                
                Button("", systemImage: "play.fill") {
                    currentFrame = 0
                    enableNavigationButton = false
                    
                    drawHistory(currentHistories[currentFrame])
                    currentFrame += 1
                    
                    Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { timer in
                        guard currentFrame < currentHistories.count else {
                            timer.invalidate()
                            enableNavigationButton = true
                            return
                        }
                        
                        drawHistory(currentHistories[currentFrame])
                        currentFrame += 1
                    }
                }
                .disabled(!enableNavigationButton)
                
                Button("", systemImage: "forward.end.fill") {
                    guard currentFrame < currentHistories.count - 1 else {
                        return
                    }
                    
                    currentFrame += 1
                    drawHistory(currentHistories[currentFrame])
                }
                .disabled(!enableNavigationButton)
                
                Text("\(currentFrame)")
                    .foregroundStyle(.gray)
            }
            
            Divider()
            
            // Text("distanceNow: \(currentHistory?.distancePrev ?? -1)")
            // Text("distanceNext: \(currentHistory?.distanceNext ?? -1)")
            // Text("state: \(currentHistory?.state == .before ? "before" : "after")")
            
        }
        .padding()
        .onAppear {
            drawMap(currentExample)
        }
        .onChange(of: currentExample) { _ in
            currentFrame = 0
            drawMap(currentExample)
            drawHistory(currentHistories[currentFrame])
        }
    }
    
    @ViewBuilder func cityArea(_ cityNumber: Int) -> some View {
        ZStack(alignment: .bottomTrailing) {
            cityView(
                cityViewMode: .city,
                cityNumber: cityNumber,
                isHighlight: currentHistory?.now == cityNumber,
                isBorder: currentHistory?.next == cityNumber
            )
            visitedMark(cityNumber)
            askVisit(cityNumber)
            showDistance(cityNumber)
            showStartCity(cityNumber)
        }
    }
    
    @ViewBuilder func cityView(
        cityViewMode: CityViewMode,
        cityNumber: Int = 0,
        isHighlight: Bool = false,
        isBorder: Bool = false
    ) -> some View {
        switch cityViewMode {
        case .city:
            Rectangle()
                .fill(isHighlight ? .green : .black)
                .frame(width: 100, height: 100)
                .overlay {
                    Text("\(cityNumber)")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                }
                .border(.red, width: isBorder ? 5 : 0)
        case .road:
            Rectangle()
                .fill(.white)
                .frame(width: 100, height: 100)
        }
    }
    
    @ViewBuilder func visitedMark(_ cityNum: Int) -> some View {
        if currentHistory?.visited[cityNum] ?? false {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.pink)
                .offset(x: -8, y: -8)
        }
    }
    
    @ViewBuilder func askVisit(_ cityNum: Int) -> some View {
        if currentHistory?.next == cityNum {
            let nextVisited = currentHistory?.vistedNext ?? false
            Text(nextVisited ? "방문했네요!" : "방문했나요?")
                .foregroundStyle(.white)
                .offset(x: -10, y: -70)
        }
    }
    
    @ViewBuilder func showDistance(_ cityNum: Int) -> some View {
        if let currentHistory {
            let visited = currentHistory.distance[cityNum] >= 0 ? currentHistory.distance[cityNum] : 0
            Text("\(visited)")
                .foregroundStyle(.gray)
                .offset(x: -80, y: -8)
        }
    }
    
    @ViewBuilder func showStartCity(_ cityNum: Int) -> some View {
        if let startCity = viewModel.mapInfos[currentExample]?.startCity,
           startCity == cityNum {
            Image(systemName: "house.fill")
                .foregroundStyle(.yellow)
                .offset(x: -60, y: -40)
        }
    }
    
    private func drawMap(_ mapNumber: Int) {
        connect = [
            1: .init(repeating: false, count: 5),
            2: .init(repeating: false, count: 5),
            3: .init(repeating: false, count: 5),
            4: .init(repeating: false, count: 5),
        ]
        
        let targetGraph = viewModel.mapInfos[currentExample]!.matrix
        
        // 연결 그리기
        for (index, cities) in targetGraph.enumerated() {
            if index == 0 {
                continue
            }
            
            for city in cities {
                connect[index]![city] = true
                // print(index, city, connect[1]![2])
            }
        }
        
        (currentResult, currentHistories) = viewModel.mapInfos[currentExample]!.traverse()
    }
    
    private func drawHistory(_ history: TraverseHistory) {
        // 초기화
        
        currentHistory = history
        
        guard history.next >= 1 else {
            return
        }
    }
    
    private func resultFormatter(_ result: [Int]) -> String {
        result.isEmpty ? "없음" : result.map(String.init).joined(separator: ", ")
    }
}

#Preview {
    특정거리의도시찾기View()
}
