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
    // print(cache, choices)
    // 0번 인덱스부터 시작하는 LIS의 실제 원소들을 result에 저장
    reconstruct(start: -1, seq: &result)
    
    print(result)
}

Chapter_9_1(S: [4, 7, 6, 9, 8, 10])
// 결과: [4, 7, 9, 10]
// Chapter_9_1(S: [15, 3, 4, 15, 7, 8, 12, 19, 30, 16])
// 결과: [3, 4, 7, 8, 12, 19, 30]

func Chapter_9_2() {
    /*
     https://jaimemin.tistory.com/344
     */
    
    /* ************ C++ 코드 ************
     #include <iostream>
     #include <vector>
     #include <cstring> // memset 사용 위해

     using namespace std;

     // 입력의 첫 줄: 테스트 케이스의 수 c (1 <= c <= 50)
     // 각 테스트 케이스의 첫 줄 : 가져가고 싶은 물건의 수 n (1 <= n <= 100)와
     //  캐리어의 용량 w(1 <= w <= 1000)
     // 이후 n 줄에 각 물건의 정보 (물건의 이름, 부피, 절박도 순서)
     // 이름은 공백 없는 알파벳 대소문자 1글자 이상 20글자 이하 문자열
     // 부피와 절박도는 1000 이하의 자연수
     int n;
     int capacity;

     // https://stackoverflow.com/questions/8021801/array-of-strings-initialization-in-c
     int volume[100];
     int need[100];
     int cache[1001][100];

     string name[100];

     // vector<int> volume;
     // vector<int> need;
     // vector<vector<int>> cache;

     // vector<string> name;

     // 캐리어에 남은 용량이 capacity일 때, item 이후의 물건들을
     // 담아 얻을 수 있는 최대 절박도의 합을 반환
     int pack(int capacity, int item) {
         // 기저 사례: 더 담을 물건이 없을 때
         if(item == n)   return 0;
         int& ret = cache[capacity][item];
         if(ret != -1)   return ret;
         
         // 이 물건을 담지 않을 경우
         ret = pack(capacity, item + 1);
         
         // 이 물건을 담을 경우
         if(capacity >= volume[item]) {
             ret = max(ret, pack(capacity - volume[item], item + 1) + need[item]);
         }
         
         return ret;
     }

     void reconstruct(int capacity, int item, vector<string>& picked) {
         // 기저 사례: 모든 물건을 다 고려
         if(item == n)   return;
         
         if(pack(capacity, item) == pack(capacity, item + 1)) {
             reconstruct(capacity, item + 1, picked);
         } else {
             picked.push_back(name[item]);
             reconstruct(capacity - volume[item], item + 1, picked);
         }
     }

     int main() {
         // n = 6;
         // capacity = 10;
         // name = {"laptop", "camera", "xbox", "grinder", "dumbell", "encyclopedia"};
         // volume = {4, 2, 6, 4, 2, 10};
         // need = {7, 10, 6, 7, 5, 4};
         
         // pack(capacity, 0);
         
         int test_case;
         cin >> test_case;
         if(test_case < 1 || test_case > 50)   exit(-1);
         
         for(int i = 0; i < test_case; i++) {
             vector<string> picked;
             cin >> n >> capacity;
             if(n < 1 || n > 100 || capacity < 1 || capacity > 1000)
                 exit(-1);
             for(int j = 0; j < n; j++) {
                 cin >> name[j] >> volume[j] >> need[j];
                 if(name[j].empty() || name[j].size() > 21 || volume[j] < 1 || volume[j]>1000 || need[j] < 1 || need[j]>1000)
                     exit(-1);
             }
             
             // memset 함수는 메모리의 내용(값)을 원하는 크기만큼 특정 값으로 세팅할 수 있는 함수
             // void* memset(void* ptr, int value, size_t num);
             memset(cache, -1, sizeof(cache));
             reconstruct(capacity, 0, picked);
             cout << pack(capacity, 0) << " " << picked.size() << endl;
             
             for(int j = 0; j < picked.size(); j++) {
                 cout << picked[j] << endl;
             }
         }
         
         return 0;
     }
     */
    
    // 입력의 첫 줄: 테스트 케이스의 수 c (1 <= c <= 50)
    // 각 테스트 케이스의 첫 줄 : 가져가고 싶은 물건의 수 n (1 <= n <= 100)와
    //  캐리어의 용량 w(1 <= w <= 1000)
    // 이후 n 줄에 각 물건의 정보 (물건의 이름, 부피, 절박도 순서)
    // 이름은 공백 없는 알파벳 대소문자 1글자 이상 20글자 이하 문자열
    // 부피와 절박도는 1000 이하의 자연수
    var n: Int
    var capacity: Int
    
    var volume: [Int]
    var need: [Int]
    var cache: [[Int]]

    var name: [String]
    var picked: [String]
    
    // 캐리어에 남은 용량이 capacity일 때, item 이후의 물건들을
    // 담아 얻을 수 있는 최대 절박도의 합을 반환
    func pack(_ capacity: Int, _ item: Int) -> Int {
        // 기저 사례: 더 담을 물건이 없을 때
        
        if item == n {
            return 0
        }
        
        // 이 물건을 담지 않을 경우
        cache[capacity][item] = pack(capacity, item + 1)
        
        // 이 물건을 담을 경우
        if capacity >= volume[item] {
            cache[capacity][item] = max(cache[capacity][item],  pack(capacity - volume[item], item + 1) + need[item])
        }
        
        return cache[capacity][item]
    }
    
    // pack(capacity, item)이 선택한 물건들의 목록을 picked에 저장
    func reconstruct(_ capacity: Int, _ item: Int, _ picked: inout [String]) {
        // 기저 사례: 모든 물건을 다 고려
        if item == n {
            return
        }
        
        if pack(capacity, item) == pack(capacity, item + 1) {
            reconstruct(capacity, item + 1, &picked)
        } else {
            picked.append(name[item])
            reconstruct(capacity - volume[item], item + 1, &picked)
        }
    }
    
    // === Test Case 1 ===
    
    n = 6
    capacity = 10
    name = ["laptop", "camera", "xbox", "grinder", "dumbell", "encyclopedia"]
    volume = [4, 2, 6, 4, 2, 10]
    need = [7, 10, 6, 7, 5, 4]
    picked = []
    
    cache = [[Int]](repeating: [Int](repeating: -1, count: 1001), count: 1001)
    reconstruct(capacity, 0, &picked)
    
    let packResult = pack(capacity, 0)
    print(packResult, picked.count)
    print(picked)
    
    // === Test Case 2 ===
    n = 6
    capacity = 17
    name = ["laptop", "camera", "xbox", "grinder", "dumbell", "encyclopedia"]
    volume = [4, 2, 6, 4, 2, 10]
    need = [7, 10, 6, 7, 5, 4]
    picked = []
    
    cache = [[Int]](repeating: [Int](repeating: -1, count: 1001), count: 1001)
    reconstruct(capacity, 0, &picked)
    
    let packResult2 = pack(capacity, 0)
    print(packResult2, picked.count)
    print(picked)
}
Chapter_9_2()
