import UIKit

func Chapter_9_1(S: [Int]) {
    /*
     LIS: Longest Increasing Subsequence
     부분 수열에 포함된 숫자들이 strictly increasing 한다.
     
     예) S = [1, 3, 4, 2, 4]인 경우
     [1, 2, 4]는 LIS이며 [1, 4, 4]는 아님
     */

    /*
     ************ C++ 코드 ************
     
     #include <iostream>
     #include <vector>

     using namespace std;

     int n = 6;
     int S[] = {4, 7, 6, 9, 8, 10};

     int cache[101], choices[101];
     vector<int> result; // lis 실제 결과를 담는 벡터.

     // S[start]에서 시작하는 증가 부분 수열 중 최대 길이를 반환
     int lis4(int start) {
         int& ret = cache[start + 1];
         if(ret != -1)   return ret;
         
         // 항상 S[start]는 있기 떄문에 길이는 최하 1
         ret = 1;
         int bestNext = -1;
         
         for(int next = start + 1; next < n; ++next) {
             if(start == -1 || S[start] < S[next]) {
                 int cand = lis4(next) + 1;
                 if(cand > ret) {
                     ret = cand;
                     bestNext = next;
                 }
             }
         }
         
         choices[start + 1] = bestNext;
         return ret;
     }

     // S[start]에서 시작하는 LIS를 seq에 저장
     void reconstruct(int start, vector<int>& seq) {
        // 멤버 함수 push_back은 vector의 끝에 요소를 추가할때 사용하는 함수
         if(start != -1) seq.push_back(S[start]);
         int next = choices[start + 1];
         if(next != -1)  reconstruct(next, seq);
     }

     int main() {
         for(int i = 0; i < 100; i++) {
             cache[i] = -1;
             choices[i] = -1;
         }
         
         // 0번 인덱스부터 시작하는 LIS의 최대 길이와 최적화된 원소들의 인덱스를 choice에 저장
         lis4(-1);
         // 0번 인덱스부터 시작하는 LIS의 실제 원소들을 result에 저장
         reconstruct(-1, result);
         
         for (const int &n : result) {
             cout << n << "  ";
         }
     }
     */

    var n: Int = S.count
    
    var cache: [Int] = [Int](repeating: -1, count: 1001)
    var choices: [Int] = [Int](repeating: -1, count: 1001)
    var result: [Int] = []
    
    /// S[start]에서 시작하는 증가 부분 수열 중 최대 길이를 반환
    func lis4(start: Int) -> Int {
        var retIndex = start + 1
        if cache[retIndex] != -1 {
            return cache[retIndex]
        }
        
        // 항상 S[start]는 있기 떄문에 길이는 최하 1
        cache[retIndex] = 1
        var bestNext: Int = -1
        
        for next in retIndex ..< n {
            if start == -1 || S[start] < S[next] {
                var cand: Int = lis4(start: next) + 1
                if cand > cache[retIndex] {
                    cache[retIndex] = cand
                    bestNext = next
                }
            }
        }
        
        choices[start + 1] = bestNext
        return cache[retIndex]
    }
    
    /// S[start]에서 시작하는 LIS를 seq에 저장
    func reconstruct(start: Int, seq: inout [Int]) {
        if start != -1 {
            seq.append(S[start])
        }
        
        var next: Int = choices[start + 1]
        
        if next != -1 {
            reconstruct(start: next, seq: &seq)
        }
    }
    
    // 0번 인덱스부터 시작하는 LIS의 최대 길이와 최적화된 원소들의 인덱스를 choice에 저장
    lis4(start: -1)
    // 0번 인덱스부터 시작하는 LIS의 실제 원소들을 result에 저장
    reconstruct(start: -1, seq: &result)
    
    print(result)
}

Chapter_9_1(S: [4, 7, 6, 9, 8, 10])
// 결과: [4, 7, 9, 10]
Chapter_9_1(S: [15, 3, 4, 15, 7, 8, 12, 19, 30, 16])
// 결과: [3, 4, 7, 8, 12, 19, 30]
