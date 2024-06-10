import UIKit

/*
 문제 설명
 n개의 음이 아닌 정수들이 있습니다. 이 정수들을 순서를 바꾸지 않고 적절히 더하거나 빼서 타겟 넘버를 만들려고 합니다. 예를 들어 [1, 1, 1, 1, 1]로 숫자 3을 만들려면 다음 다섯 방법을 쓸 수 있습니다.

 -1+1+1+1+1 = 3
 +1-1+1+1+1 = 3
 +1+1-1+1+1 = 3
 +1+1+1-1+1 = 3
 +1+1+1+1-1 = 3
 사용할 수 있는 숫자가 담긴 배열 numbers, 타겟 넘버 target이 매개변수로 주어질 때 숫자를 적절히 더하고 빼서 타겟 넘버를 만드는 방법의 수를 return 하도록 solution 함수를 작성해주세요.

 제한사항
 주어지는 숫자의 개수는 2개 이상 20개 이하입니다.
 각 숫자는 1 이상 50 이하인 자연수입니다.
 타겟 넘버는 1 이상 1000 이하인 자연수입니다.
 입출력 예
 numbers    target    return
 [1, 1, 1, 1, 1]    3    5
 [4, 1, 2, 1]    4    2
 입출력 예 설명
 입출력 예 #1

 문제 예시와 같습니다.

 입출력 예 #2

 +4+1-2+1 = 4
 +4-1+2-1 = 4
 총 2가지 방법이 있으므로, 2를 return 합니다.
 
 [리뷰]
 - DFS를 사용해서 풀어야 한다고 유추했음
 - 외부에서 반례 찾지 않고 풀었음
 - 자력으로 풀었으나 (A)의 이유로 시간이 많이 걸림
 */

/// https://school.programmers.co.kr/learn/courses/30/lessons/43165
func targetNumber(_ numbers: [Int], _ target: Int) -> Int {
    var numbers = numbers
    let maxDepth = numbers.count
    var resultCount = 0

    func dfs(baseValue: Int, addValue: Int, depth: Int = 0) {
        // A: Terminator가 dfs 재귀하기 이전에 있어야 함 (뒤에 있으면 결과 제대로 안나옴)
        if depth == maxDepth {
            resultCount += baseValue == target ? 1 : 0
            return
        }
        
        dfs(baseValue: baseValue + numbers[depth], addValue: numbers[depth], depth: depth + 1)
        dfs(baseValue: baseValue - numbers[depth], addValue: numbers[depth], depth: depth + 1)
        // print(baseValue, addValue, numbers[depth], depth)
    }
    
    dfs(baseValue: 0, addValue: numbers[0])
    
    return resultCount
}

targetNumber([1, 1, 1, 1, 1], 3)
targetNumber([4, 1, 2, 1], 4)

targetNumber([1, 1, 5], 5)

/*
 문제 설명
 네트워크란 컴퓨터 상호 간에 정보를 교환할 수 있도록 연결된 형태를 의미합니다. 예를 들어, 컴퓨터 A와 컴퓨터 B가 직접적으로 연결되어있고, 컴퓨터 B와 컴퓨터 C가 직접적으로 연결되어 있을 때 컴퓨터 A와 컴퓨터 C도 간접적으로 연결되어 정보를 교환할 수 있습니다. 따라서 컴퓨터 A, B, C는 모두 같은 네트워크 상에 있다고 할 수 있습니다.

 컴퓨터의 개수 n, 연결에 대한 정보가 담긴 2차원 배열 computers가 매개변수로 주어질 때, 네트워크의 개수를 return 하도록 solution 함수를 작성하시오.

 제한사항
 컴퓨터의 개수 n은 1 이상 200 이하인 자연수입니다.
 각 컴퓨터는 0부터 n-1인 정수로 표현합니다.
 i번 컴퓨터와 j번 컴퓨터가 연결되어 있으면 computers[i][j]를 1로 표현합니다.
 computer[i][i]는 항상 1입니다.
 입출력 예
 n    computers    return
 3    [[1, 1, 0], [1, 1, 0], [0, 0, 1]]    2
 3    [[1, 1, 0], [1, 1, 1], [0, 1, 1]]    1
 
 [리뷰]
 - 처음에는 백준 유기농벌레와 똑같은 유형인줄 알았으나 다름
 - 백준 바이러스 문제와 유사
 - 시간 오래 걸렸으나 자력으로 풀음
 */

/// https://school.programmers.co.kr/learn/courses/30/lessons/43162
func network(_ n: Int, _ computers: [[Int]]) -> Int {
    // 그래프 만들기
    var graphs: [[Int]] = Array(repeating: [], count: n + 1)
    for i in 0..<n {
        for j in 0..<n {
            if computers[i][j] == 1 {
                graphs[i + 1].append(j + 1)
                graphs[i + 1].sort(by: >)
            }
        }
    }
    
    var result = 0
    var visited: Set<Int> = []
    
    func dfs(_ node: Int) {
        if !visited.contains(node) {
            visited.insert(node)
            
            for neighbor in graphs[node] {
                dfs(neighbor)
            }
        }
    }
    
    // 방문한 적이 없는 경우 count를 1 올리고 dfs
    for start in 1...n {
        if !visited.contains(start) {
            result += 1
            dfs(start)
        }
    }
    
    return result
}

network(3, [[1, 1, 0], [1, 1, 0], [0, 0, 1]]) // 2
network(3, [[1, 1, 0], [1, 1, 1], [0, 1, 1]]) // 1

network(3, [[1, 0, 0], [0, 1, 0], [0, 0, 1]]) // 3
network(2, [[1, 0], [0, 1]]) // 2
network(2, [[1, 1], [1, 1]]) // 1
network(1, [[1]]) // 1
network(4, [[1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0], [0, 0, 0, 1]]) // 4

network(4, [[1, 0, 0, 1],
            [0, 1, 1, 0],
            [0, 1, 1, 0],
            [1, 0, 0, 1]]) // 2
network(4, [[1, 0, 1, 1], [0, 1, 1, 0], [1, 1, 1, 0], [1, 0, 0, 1]]) // 1

/*
 https://school.programmers.co.kr/learn/courses/30/lessons/43163
 
 문제 설명
 두 개의 단어 begin, target과 단어의 집합 words가 있습니다. 아래와 같은 규칙을 이용하여 begin에서 target으로 변환하는 가장 짧은 변환 과정을 찾으려고 합니다.

 1. 한 번에 한 개의 알파벳만 바꿀 수 있습니다.
 2. words에 있는 단어로만 변환할 수 있습니다.
 예를 들어 begin이 "hit", target가 "cog", words가 ["hot","dot","dog","lot","log","cog"]라면 "hit" -> "hot" -> "dot" -> "dog" -> "cog"와 같이 4단계를 거쳐 변환할 수 있습니다.

 두 개의 단어 begin, target과 단어의 집합 words가 매개변수로 주어질 때, 최소 몇 단계의 과정을 거쳐 begin을 target으로 변환할 수 있는지 return 하도록 solution 함수를 작성해주세요.

 제한사항
 각 단어는 알파벳 소문자로만 이루어져 있습니다.
 각 단어의 길이는 3 이상 10 이하이며 모든 단어의 길이는 같습니다.
 words에는 3개 이상 50개 이하의 단어가 있으며 중복되는 단어는 없습니다.
 begin과 target은 같지 않습니다.
 변환할 수 없는 경우에는 0를 return 합니다.
 입출력 예
 begin    target    words    return
 "hit"    "cog"    ["hot", "dot", "dog", "lot", "log", "cog"]    4
 "hit"    "cog"    ["hot", "dot", "dog", "lot", "log"]    0
 
 https://velog.io/@euneun/%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%A8%B8%EC%8A%A4-%EB%8B%A8%EC%96%B4-%EB%B3%80%ED%99%98BFSDFS-C-v5lnyekn
 
 이렇게 예제 1번의 풀이과정을 가시화시켜보면 하나의 줄기를 탐색해나가며 변환단계의 최소값을 구하면 된다는 것을 알 수 있다.

 하나의 줄기씩 한 방향으로 갈 수 있을때까지 탐색해나가므로 dfs 풀이법을 떠올릴 수 있다.
 변환 단계의 최소값이므로 한번 사용한 단어는 재사용하지 않는것이 암묵적인 규칙임을 알 수 있다. (단어를 재사용하면 변환단계가 더 길어지므로 최소값이 될 수 없으므로 해가 될 수 없다.)
 -> 따라서 단어별로 방문여부를 체크할 배열이 필요하다.
 탐색함수를 재귀적으로 호출해나가면서 target단어와 같아졌을때는 함수호출을 종료하는 종료조건을 염두해둔다.
 문제에서 한 번에 한 개의 알파벳만 바꿀 수 있다고 하였다. 따라서 하나의 줄기씩 탐색을 해나갈때 words 벡터에서 현재의 단어와 한글자만 다른 단어만이 탐색 후보가 될 수 있으므로 다른 문자가 한개인지 판별하는 함수도 작성해야한다.
 
 문제 풀이 방법
 1. 가장 간단해 보이는 다른문자가 한개인지 판별하는 함수부터 작성해보자.
 2. 재귀함수를 작성해보자.
  - 해당 탐색과정에서 다시 가장 가까운 갈림길로 돌아와서 (back-tracking) 이곳부터 다른 방향으로 다시 탐색을 진행해야한다
 
 [리뷰]
 1. 자력으로 못품 - 블로그보고 베낌 (설명 위주로 보고)
 2. 외부 반례는 찾지 않고 80% 정답률일때 스스로 나머지 20% 해결
 */

extension String {
    subscript(_ index: Int) -> Character? {
        guard index >= 0, index < self.count else {
            return nil
        }

        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

func onlyOneDifferent(_ lhs: String, _ rhs: String) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }
    
    var result = 0
    for i in 0..<lhs.count {
        if lhs[i] == rhs[i] {
            result += 1
        }
        
        // 주의: 단어 수는 3~10자
        if result == lhs.count - 1 {
            return true
        }
    }
    
    return false
}

func convertWord(_ begin: String, _ target: String, _ words: [String]) -> Int {
    guard words.contains(target) else {
        return 0
    }
    
    var visited: Set<String> = []
    var result = Int.max // words.count의 최대값
    
    func dfs(_ begin: String, _ target: String, _ step: Int) {
        if begin == target {
            result = min(step, result)
            return
        }
        
        if step > result {
            return
        }
        
        for word in words {
            if onlyOneDifferent(begin, word) && !visited.contains(word) {
                // 백트래킹: 밑으로 갈 때는 방문 표시했다가, 다시 위로 역류하는 경우 방문 표시 해제
                visited.insert(word)
                dfs(word, target, step + 1)
                visited.remove(word)
            }
        }
    }
    
    dfs(begin, target, 0)
    
    return result != Int.max ? result : 0
}


convertWord("hit", "cog", ["hot", "dot", "dog", "lot", "log", "cog"]) // 4
convertWord("hit", "cog", ["hot", "dot", "dog", "lot", "log"]) // 0

convertWord("hit", "hit", ["hot", "dog"]) // 0
convertWord("hit", "cog", ["hot", "cog"]) // 0
convertWord("hit", "lot", ["hot", "lot"]) // 2
convertWord("willow", "solloy", ["wollow", "solloy", "wolloy", "willew"]) // 3

/*
 여행경로
 https://school.programmers.co.kr/learn/courses/30/lessons/43164
 
 문제 설명
 주어진 항공권을 모두 이용하여 여행경로를 짜려고 합니다. 항상 "ICN" 공항에서 출발합니다.

 항공권 정보가 담긴 2차원 배열 tickets가 매개변수로 주어질 때, 방문하는 공항 경로를 배열에 담아 return 하도록 solution 함수를 작성해주세요.

 제한사항
 모든 공항은 알파벳 대문자 3글자로 이루어집니다.
 주어진 공항 수는 3개 이상 10,000개 이하입니다.
 tickets의 각 행 [a, b]는 a 공항에서 b 공항으로 가는 항공권이 있다는 의미입니다.
 주어진 항공권은 모두 사용해야 합니다.
 만일 가능한 경로가 2개 이상일 경우 알파벳 순서가 앞서는 경로를 return 합니다.
 모든 도시를 방문할 수 없는 경우는 주어지지 않습니다.
 입출력 예
 tickets    return
 [["ICN", "JFK"], ["HND", "IAD"], ["JFK", "HND"]]    ["ICN", "JFK", "HND", "IAD"]
 [["ICN", "SFO"], ["ICN", "ATL"], ["SFO", "ATL"], ["ATL", "ICN"], ["ATL","SFO"]]    ["ICN", "ATL", "ICN", "SFO", "ATL", "SFO"]
 입출력 예 설명
 예제 #1

 ["ICN", "JFK", "HND", "IAD"] 순으로 방문할 수 있습니다.

 예제 #2

 ["ICN", "SFO", "ATL", "ICN", "ATL", "SFO"] 순으로 방문할 수도 있지만 ["ICN", "ATL", "ICN", "SFO", "ATL", "SFO"] 가 알파벳 순으로 앞섭니다.

 [리뷰]
 - 테스트 케이스는 다 맞고, 첫 채점 결과 50% 정답률 (테스트 1, 2 실패 - 테스트 3, 4 성공)
 - 2는 반례 찾아 성공했지만 1은 끝까지 실패
 - 결국 다른 블로그 보고 베낌
 */


func pathOfJourney실패(_ tickets: [[String]]) -> [String] {
    // var ticketsSet = Set<[String]>()
    // tickets.forEach { ticketRow in
    //     ticketsSet.insert(ticketRow)
    // }
    // ticketsSet
    
    var pathMap: [String: [String]] = [:]
    for ticketPath in tickets {
        pathMap[ticketPath[0], default: []].append(ticketPath[1])
        pathMap[ticketPath[0], default: []].sort()
        
        // pathMap[ticketPath[1], default: []].append(ticketPath[0])
        // pathMap[ticketPath[1], default: []].sort()
    }
    pathMap
    
    var ticketsFlatMap = tickets.flatMap { $0 }
    var totalCount = ticketsFlatMap.count
    
    var currentCount = 0
    
    func dfs_recursive(_ start: String, _ graphs: [String: [String]]) -> [String] {
        var result: [String] = []
        var graphs = graphs
        var lastNode: String = "oo"
        
        func dfs(_ node: String) {
            currentCount += 1
            
            if currentCount <= totalCount {
                result.append(node)
                // if graphs[node, default: []].isEmpty {
                //     print(lastNode, "isEmpty", currentCount, totalCount, pathMap.values.allSatisfy({$0.count == 0}))
                //     print(pathMap[lastNode], pathMap[node])
                //     return
                // }
                
                if !graphs[node, default: []].isEmpty {
                    lastNode = node
                    let firstNode = graphs[node, default: []].removeFirst()
                    dfs(firstNode)
                    graphs[node, default: []].insert(node, at: 0)
                }
            }
        }
        
        dfs(start)
        return result
    }
    
    return dfs_recursive("ICN", pathMap)
}

func pathOfJourney(_ tickets: [[String]]) -> [String] {
    var answer: [String] = []
    
    var paths: [String: Array<String>] = [:]
    var visited: [String: Array<Bool>] = [:]
    
    for ticket in tickets {
        paths[ticket[0], default: .init()].append(ticket[1])
        paths[ticket[0], default: .init()].sort()
        visited[ticket[0], default: .init()].append(false)
    }
    
    print(paths, visited)
    
    func dfs(_ start: String, _ count: Int, _ list: [String], _ ticketCount: Int) {
        if count == ticketCount {
            answer.append(contentsOf: list)
            return
        }
        
        if answer.count >= ticketCount {
            return
        }
        
        guard let pathsStart = paths[start] else {
            print("pathstart is nil")
            return
        }
        
        for location in 0..<pathsStart.count {
            let isVisited = visited[start]![location]
            
            if !isVisited {
                visited[start]![location] = true
                let nextTarget = paths[start]![location]
                dfs(nextTarget, count + 1, list + [nextTarget], ticketCount)
                visited[start]![location] = false
            }
        }
    }
    
    dfs("ICN", 0, ["ICN"], tickets.count)
    return answer
}

pathOfJourney( [
    ["ICN", "JFK"],
    ["HND", "IAD"],
    ["JFK", "HND"]
] ) //  ["ICN", "JFK", "HND", "IAD"]

pathOfJourney( [
    ["ICN", "SFO"],
    ["ICN", "ATL"],
    ["SFO", "ATL"],
    ["ATL", "ICN"],
    ["ATL", "SFO"]
] ) // ["ICN", "ATL", "ICN", "SFO", "ATL", "SFO"]

pathOfJourney(
    [
        ["ICN", "JFK"],
        ["ICN", "JFK"],
        ["HND", "IAD"],
        ["JFK", "HND"],
        ["IAD", "ICN"]
    ]
)

// 반례
pathOfJourney([
    ["ICN", "JFK"],
    ["ICN", "AAD"],
    ["JFK", "ICN"]
]) // ["ICN", "JFK", "ICN", "AAD"]

pathOfJourney([
    ["ICN", "BOO"],
    ["ICN", "COO"],
    ["COO", "DOO"],
    ["DOO", "COO"],
    ["BOO", "DOO"],
    ["DOO", "BOO"],
    ["BOO", "ICN"],
    ["COO", "BOO"]
])
// ["ICN", "BOO", "DOO", "BOO", "ICN", "COO", "DOO", "COO", "BOO"]
