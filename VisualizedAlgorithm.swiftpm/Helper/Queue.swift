//
//  Queue.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/07.
//

import Foundation

struct Queue<T> {
    private class Node {
        var value: T
        var next: Node?

        init(_ value: T) {
            self.value = value
        }
    }

    private var head: Node?
    private var tail: Node?

    mutating func enqueue(_ element: T) {
        let newNode = Node(element)
        if head == nil {
            head = newNode
            tail = newNode
        } else {
            tail?.next = newNode
            tail = newNode
        }
    }

    mutating func dequeue() -> T? {
        let value = head?.value
        head = head?.next
        if head == nil {
            tail = nil
        }
        return value
    }

    var isEmpty: Bool {
        return head == nil
    }
}
