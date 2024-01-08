//
//  TraverseHistory.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/08.
//

import Foundation

struct TraverseHistory {
    enum VisitCheckState {
        case before, after
    }
    
    /// Now (Dequeued)
    var now: Int
    /// Next (Enqueued)
    var next: Int
    
    var graph: [Int]
    
    var state: VisitCheckState
    
    var visited: [Bool]
    var distance: [Int]
    
    var vistitedNow: Bool {
        guard !visited.isEmpty && next >= 1 else {
            return false
        }
        
        return visited[now]
    }
    
    var vistedNext: Bool {
        guard !visited.isEmpty && next >= 1 else {
            return false
        }
        
        return visited[next]
    }
    
    var distancePrev: Int {
        guard !distance.isEmpty && next >= 1 else {
            return -99
        }
        
        return distance[now]
    }
    
    var distanceNext: Int {
        guard !distance.isEmpty && next >= 1 else {
            return -99
        }
        
        return distance[next]
    }
}
