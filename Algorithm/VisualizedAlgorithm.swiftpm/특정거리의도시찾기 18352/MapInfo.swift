//
//  MapInfo.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/08.
//

import Foundation

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
        
    }
    
    mutating func traverse() -> (result: [Int], histories: [TraverseHistory]) {
        q = Queue<Int>()
        q.enqueue(startCity)
        
        visited = .init(repeating: false, count: cityCount + 1)
        visited[startCity] = true
                        
        distance = .init(repeating: -1, count: cityCount + 1)
        distance[startCity] = 0
        
        var histories: [TraverseHistory] = []
        
        while !q.isEmpty {
            let now = q.dequeue()!
            
            histories.append(TraverseHistory(now: now, next: -1, graph: [], state: .before, visited: visited, distance: distance))
            
            for next in matrix[now] {
                
                histories.append(TraverseHistory(now: now, next: next, graph: matrix[now], state: .before, visited: visited, distance: distance))
                if !visited[next] {
                    visited[next] = true
                    q.enqueue(next)
                    distance[next] = distance[now] + 1
                    
                    histories.append(TraverseHistory(now: now, next: next, graph: matrix[now], state: .after, visited: visited, distance: distance))
                }
            }
        }
        
        let result = (1...cityCount).filter { city in
            distance[city] == shortestDistance
        }
        
        return (result, histories)
    }
}
