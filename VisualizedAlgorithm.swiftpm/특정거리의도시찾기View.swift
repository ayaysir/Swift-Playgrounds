//
//  특정거리의도시찾기View.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/02.
//

import SwiftUI

struct TraverseHistory {
    /// Now (Dequeued)
    var now: Int
    var graph: [Int]
    var nexts: [Next] = []
    
    struct Next {
        enum State {
            case before, after
        }
        
        var state: State
        
        /// Next (Enqueued)
        var next: Int
        var now: Int
        var visited: [Bool]
        var distance: [Int]
        
        var vistedNext: Bool {
            visited[next]
        }
        
        var distancePrev: Int {
            distance[now]
        }
        
        var distanceNext: Int {
            distance[next]
        }
    }
}

struct MapInfo {
    /// 도시의 개수 N
    var cityCount: Int
    
    /// 도로의 개수 M
    var roadCount: Int
    
    /// 목표 최단 거리 정보 K
    var shortestDistance: Int
    
    /// 출발 도시의 번호 X
    var startCity: Int
    
    private(set) var matrix: [[Int]] = .init()
    private var distance: [Int] = .init()
    private var visited: [Bool] = .init()
    
    var q = Queue<Int>()
    
    init(rawText: String) {
        let splitted = rawText.split(separator: "\n")
        let firstLine = splitted[0].split(separator: " ").map { Int(String($0))! }
        
        self.cityCount = firstLine[0]
        self.roadCount = firstLine[1]
        self.shortestDistance = firstLine[2]
        self.startCity = firstLine[3]
        
        self.matrix = .init(repeating: [], count: cityCount + 1)
        self.distance = .init(repeating: -1, count: cityCount + 1)
        self.visited = .init(repeating: false, count: cityCount + 1)
        
        splitted[1...].forEach {
            let roads = String($0).split(separator: " ").map { Int($0)! }
            let (a, b) = (roads[0], roads[1])
            
            self.matrix[a].append(b)
        }
        
        q.enqueue(startCity)
        visited[startCity] = true
        distance[startCity] = 0
    }
    
    mutating func traverse() -> (result: [Int], histories: [TraverseHistory]) {
        var histories: [TraverseHistory] = []
        
        while !q.isEmpty {
            let now = q.dequeue()!
            // print("=========")
            // print("now:", now, graph[now])
            
            var history = TraverseHistory(now: now, graph: matrix[now])
            
            for next in matrix[now] {
                // print("next:", next)
                // print("visited[next]:", visited[next], visited)
                history.nexts.append(.init(state: .before, next: next, now: now, visited: visited, distance: distance))
                if !visited[next] {
                    visited[next] = true
                    q.enqueue(next)
                    distance[next] = distance[now] + 1
                    // print("distance:", distance[now], distance)
                }
                
                history.nexts.append(.init(state: .after, next: next, now: now, visited: visited, distance: distance))
            }
            
            histories.append(history)
        }
        
        let result = (1...cityCount).filter { city in
            distance[city] == shortestDistance
        }
        
        return (result, histories)
    }
}

final class 특정거리의도시찾기ViewModel: ObservableObject {
    @Published var mapInfos: [MapInfo?] = [
        nil,
        .init(rawText:
        """
        4 4 2 1
        1 2
        1 3
        2 3
        2 4
        """),
        .init(rawText:
        """
        4 3 2 1
        1 2
        1 3
        1 4
        """),
        .init(rawText:
        """
        4 4 1 1
        1 2
        1 3
        2 3
        2 4
        """)
    ]
}

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
    
    private func connectPath(_ key: Int, _ destination: Int) -> Binding<Bool> {
        .init {
            self.connect[key]![destination]
        } set: {
            self.connect[key]![destination] = $0
        }
    }
    
    var body: some View {
        VStack {
            Picker("", selection: $currentExample) {
                ForEach(viewModel.mapInfos.indices, id: \.self) { index in
                    if index != 0 {
                        Text("예제 \(index)")
                            .tag(index)
                    }
                }
            }
            .pickerStyle(.segmented)
            
            Divider()
            
            HStack {
                cityView(cityViewMode: .city, cityNumber: 1)
                // 1-2, 2-1
                ArrowSet(direction: .right, isOneOn: connectPath(1, 2), isTwoOn: connectPath(2, 1))
                cityView(cityViewMode: .city, cityNumber: 2)
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
                cityView(cityViewMode: .city, cityNumber: 3)
                // 3-4, 4-3
                ArrowSet(direction: .right, isOneOn: connectPath(3, 4), isTwoOn: connectPath(4, 3))
                cityView(cityViewMode: .city, cityNumber: 4)
            }
        }
        .onAppear {
            drawMap(currentExample)
            print(viewModel.mapInfos[currentExample]!.traverse())
        }
        .onChange(of: currentExample) { _ in
            print("onchange")
            drawMap(currentExample)
        }
    }
    
    @ViewBuilder func cityView(cityViewMode: CityViewMode, cityNumber: Int = 0) -> some View {
        switch cityViewMode {
        case .city:
            Rectangle()
                
                .frame(width: 100, height: 100)
                .overlay {
                    Text("\(cityNumber)")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                }
        case .road:
            Rectangle()
                .fill(.white)
                .frame(width: 100, height: 100)
        }
        
    }
    
    func drawMap(_ mapNumber: Int) {
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
                print(index, city, connect[1]![2])
            }
        }
    }
}

#Preview {
    특정거리의도시찾기View()
}
