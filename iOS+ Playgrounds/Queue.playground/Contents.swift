import UIKit

var queue: [Int] = []

queue.append(1)
queue.append(2)
queue.append(3)

queue.removeFirst() // 1
queue.removeFirst() // 2
queue.removeFirst() // 3
queue // []

// 

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

var gptQueue = Queue<Int>()

gptQueue.enqueue(1)
gptQueue.enqueue(2)
gptQueue.enqueue(3)

gptQueue.dequeue() // 1
gptQueue.dequeue() // 2
gptQueue.dequeue() // 3
gptQueue.isEmpty // true

func compareTime() {
    // ======= 기존 Array 방식 =======
    var arrayQ: [Int] = []
    let start = Date.now

    // Enqueue
    for i in 0..<15000 {
        arrayQ.append(i)
    }

    // dequeue
    for _ in 0..<arrayQ.count {
        arrayQ.removeFirst()
    }

    let end = Date.now
    end.timeIntervalSince1970 - start.timeIntervalSince1970

    // ======= Custom Queue 방식 =======

    var customQ = Queue<Int>()
    let startCQ = Date.now

    // Enqueue
    for i in 0..<15000 {
        customQ.enqueue(i)
    }

    // dequeue
    for _ in 0..<arrayQ.count {
        customQ.dequeue()
    }

    let endCQ = Date.now
    endCQ.timeIntervalSince1970 - startCQ.timeIntervalSince1970
}

// =======================

struct PriorityQueue_<T: Comparable> {
    private var elements: [T] = []

    var isEmpty: Bool {
        return elements.isEmpty
    }

    var count: Int {
        return elements.count
    }

    mutating func enqueue(_ element: T) {
        elements.append(element)
        heapifyUp()
    }

    mutating func dequeue() -> T? {
        guard !isEmpty else { return nil }

        elements.swapAt(0, count - 1)
        let dequeuedElement = elements.removeLast()
        heapifyDown()
        return dequeuedElement
    }

    private func findParentIndex(of index: Int) -> Int {
        guard index > 0 else {
            return 0
        }
        
        return (index - 1) / 2
    }

    private func leftChildIndex(of index: Int) -> Int {
        return 2 * index + 1
    }

    private func rightChildIndex(of index: Int) -> Int {
        return 2 * index + 2
    }

    private mutating func heapifyUp() {
        var currentIndex = count - 1
        var parentIndex = findParentIndex(of: currentIndex)

        while currentIndex > 0 && elements[currentIndex] < elements[parentIndex] {
            elements.swapAt(currentIndex, parentIndex)
            currentIndex = parentIndex
            parentIndex = findParentIndex(of: currentIndex)
        }
    }

    private mutating func heapifyDown() {
        var currentIndex = 0

        while true {
            let leftChildIndex = leftChildIndex(of: currentIndex)
            let rightChildIndex = rightChildIndex(of: currentIndex)

            var minIndex = currentIndex

            if leftChildIndex < count && elements[leftChildIndex] < elements[minIndex] {
                minIndex = leftChildIndex
            }

            if rightChildIndex < count && elements[rightChildIndex] < elements[minIndex] {
                minIndex = rightChildIndex
            }

            if minIndex == currentIndex {
                break
            }

            elements.swapAt(currentIndex, minIndex)
            currentIndex = minIndex
        }
    }
}

// 예제 사용
var priorityQueue = PriorityQueue<Int>()

priorityQueue.enqueue(3)
priorityQueue.enqueue(1)
priorityQueue.enqueue(4)
priorityQueue.enqueue(1)
priorityQueue.enqueue(5)

while let element = priorityQueue.dequeue() {
    print(element)
}


/// This is a simple Heap implementation which can be used as a priority queue.
class Heap<T: Comparable> {
    typealias HeapComparator<U: Comparable> = (_ l: U,_ r: U) -> Bool
    var heap = [T]()
    var count: Int {
        get {
            heap.count
        }
    }
    
    var comparator: HeapComparator<T>
    
    /// bubbleUp is called after appending the item to the end of the queue.  Depending on the comparator,
    /// it will bubbleUp to its approriate spot
    /// - Parameter idx: Index to bubble up.  This starts after insert with last index being passed in.
    private func bubbleUp(idx: Int) {
        let parent = (idx - 1) / 2
        
        if idx <= 0 {
            return
        }
        
        if comparator(heap[idx], heap[parent]) {
            heap.swapAt(parent, idx)
            bubbleUp(idx: parent)
        }
    }
    
    
    /// Heapify the current heap.  This method walks down the children and rearranges them in comparator order.
    /// - Parameter idx: index to heapify.
    private func heapify(_ idx: Int) {
        var left = idx * 2 + 1
        var right = idx * 2 + 2
        
        var comp = idx
        
        if count > left && comparator(heap[left], heap[comp]) {
            comp = left
        }
        
        if count > right && comparator(heap[right], heap[comp]) {
            comp = right
        }
        
        if comp != idx {
            heap.swapAt(comp, idx)
            heapify(comp)
        }
    }
    
    init(comparator: @escaping HeapComparator<T>) {
        self.comparator = comparator
    }
    
    
    /// Insert item into the heap.  This walks up the parents. This is a O(log n) operation
    /// - Parameter item: item that is comparable.
    func insert(item: T) {
        heap.append(item)
        bubbleUp(idx: count-1)
    }
    
    
    /// Get the top item in the heap based on comparator. This is a 0(1) operation
    /// - Returns: top item or nil if empty.
    func getTop() -> T? {
        return heap.first
    }
    
    
    /// Remove the top item.  This is a O(log n) operation
    /// - Returns: returns top item based on comparator or nil if empty.
    func popTop() -> T? {
        var item: T? = heap.first
        if count > 1 {
            // set the top to the last element and heapify
            // this means we can remove the last after "poping" the first.
            heap[0] = heap[count-1]
            heap.removeLast()
            heapify(0)
        }
        else if count == 1 {
            heap.removeLast()
        }
        else {
            return nil
        }
        
        return item
    }
}

let heap = Heap<Int> { l, r in
    l > r
}

heap.insert(item: 1)
heap.insert(item: 10)
heap.insert(item: 100)
heap.insert(item: 55)
heap.insert(item: 16)
heap.insert(item: 200)
heap.insert(item: 300)
heap.insert(item: 500)
heap.insert(item: 20)
heap.insert(item: 20)
heap.insert(item: 500)

print("\(heap.heap)")
print("\(heap.getTop())")
print("\(heap.popTop())")
print("\(heap.heap)")
print("\(heap.popTop())")
print("\(heap.heap)")
print("\(heap.popTop())")
print("\(heap.heap)")
print("\(heap.popTop())")
print("\(heap.heap)")
print("\(heap.popTop())")
print("\(heap.heap)")
print("\(heap.popTop())")
print("\(heap.heap)")
heap.insert(item: 300)
heap.insert(item: 500)
print("\(heap.heap)")
print("\(heap.popTop())")
print("\(heap.heap)")
print("\(heap.count)")

// =========================== //


struct PriorityQueue<T: Comparable> {
    private var elements: [T] = []

    var isEmpty: Bool {
        return elements.isEmpty
    }

    var count: Int {
        return elements.count
    }

    mutating func enqueue(_ element: T) {
        elements.append(element)
        heapifyUp()
    }

    mutating func dequeue() -> T? {
        guard !isEmpty else { return nil }

        elements.swapAt(0, count - 1)
        let dequeuedElement = elements.removeLast()
        heapifyDown()
        return dequeuedElement
    }

    private mutating func heapifyUp() {
        var currentIndex = count - 1
        var parentIndex = self.parentIndex(of: currentIndex)

        while currentIndex > 0 && elements[currentIndex] < elements[parentIndex] {
            // 부모 인덱스의 값보다 자식 인덱스의 값이 작으면 스왑 (최소 힙을 유지하기 위해)
            elements.swapAt(currentIndex, parentIndex)
            currentIndex = parentIndex
            parentIndex = self.parentIndex(of: currentIndex)
        }
    }

    private mutating func heapifyDown() {
        var currentIndex = 0

        while true {
            let leftChildIndex = leftChildIndex(of: currentIndex)
            let rightChildIndex = rightChildIndex(of: currentIndex)

            var minIndex = currentIndex

            // minIndex의 값보다 왼쪽 자식 인덱스의 값이 작다면 => minIndex를 갱신
            if leftChildIndex < count && elements[leftChildIndex] < elements[minIndex] {
                minIndex = leftChildIndex
            }

            if rightChildIndex < count && elements[rightChildIndex] < elements[minIndex] {
                minIndex = rightChildIndex
            }

            // 어떠한 조건도 만족하지 않는다면 (minIndex가 변경되지 않은 상태라면) 중지
            if minIndex == currentIndex {
                break
            }

            // 작은 값과 현재 값을 스왑
            elements.swapAt(currentIndex, minIndex)
            currentIndex = minIndex
            
            /*
             예)
                      10 (currentIndex)
                     /  \
                    15   7 (minIndex)
             
             인 경우 7(minIndex)과 10을 스왑하며 7이 새로운 currentIndex가 됩니다.
             
                     7 (currentIndex == minIndex)
                    /  \
                   15   10
                      
             */
        }
    }

    private func parentIndex(of index: Int) -> Int {
        guard index > 0 else {
            return 0
        }
        
        return (index - 1) / 2
    }

    private func leftChildIndex(of index: Int) -> Int {
        return 2 * index + 1
    }

    private func rightChildIndex(of index: Int) -> Int {
        return 2 * index + 2
    }
}

var pq: PriorityQueue<Int> = .init()
pq.enqueue(5)
pq.enqueue(77)
pq.enqueue(1)
pq.enqueue(4)
pq.enqueue(19)
pq.enqueue(5113)

while !pq.isEmpty {
    print(pq.dequeue()!)
}
