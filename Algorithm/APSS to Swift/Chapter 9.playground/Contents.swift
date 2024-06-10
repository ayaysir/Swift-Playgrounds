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

// ====================================================================== //

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

// ====================================================================== //

func Chapter_9_4() {
    /*
     https://jaimemin.tistory.com/347
     */
    
    /* ************ C++ 코드 ************
     // Online C++ compiler to run C++ program online
     #include <iostream>
     #include <cstring>
     #include <cmath>

     using namespace std;

     // n: 문장을 구성하는 단어의 개수 (composition)
     // m: 원문에 출현할 수 있는 단어의 수 (wordNum)
     // sentenceNum: 처리할 문장의 수
     int n, m, sentenceNum;

     // 분류기가 반환한 문장, 단어 번호로 변환되어 있음 (classified)
     int R[100];

     // B: i번째 단어가 첫 단어로 나올 확률 (begin)
     double B[501];

     // T[i][j] = i 단어 이후에 j 단어가 나올 확률의 로그값 (rightAfter)
     double T[501][501];

     // M[i][j] = i 단어가 j 단어로 분류될 확률의 로그값 (mismatched)
     double M[501][501];

     int choice[102][105];
     // 확률은 [0, 1] 범위의 실수이기 때문에 확률의 로그값은 항상 0 이하
     // 1로 초기화한다.
     double cache[102][502];

     // Q[segment] 이후를 채워서 얻을 수 있는 최대 g() 곱의 로그값을 반환한다.
     // Q[segment - 1 == previousMatch라고 가정한다.
     double recognize(int segment, int previousMatch) {
         if(segment == n)    return 0;
         double& ret = cache[segment][previousMatch];
         if(ret != 1.0)  return ret;
         
         ret = -1e200; // log(0) = -Infinity에 해당하는 값
         int& choose = choice[segment][previousMatch];
         
         // R[segment]에 대응되는 단어를 찾는다.
         for(int thisMatch = 1; thisMatch <= m; ++thisMatch) {
             // g(thisMatch) = T(previousMatch, thisMatch) * M(thisMatch, R[segment])
             double cand = T[previousMatch][thisMatch]
                         + M[thisMatch][R[segment]]
                         + recognize(segment + 1, thisMatch);
             if(ret < cand) {
                 ret = cand;
                 choose = thisMatch;
             }
         }
         
         return ret;
     }

     // 입력받은 단어들의 목록
     // corpus: [언어] 언어 자료; 전자 코퍼스 (컴퓨터로 읽을 수 있는 텍스트·예문 등의 집합체)
     string corpus[501];

     string reconstruct(int segment, int previousMatch) {
         int choose = choice[segment][previousMatch];
         string ret = corpus[choose];
         if(segment < n - 1) {
             ret = ret + " " + reconstruct(segment + 1, choose);
         }
         return ret;
     }

     //캐시 초기화
     void initialize() {
         for (int i = 0; i < n; i++)
             for (int j = 0; j <= m; j++)
                 cache[i][j] = 1.0;
     }

     int main() {
         cin >> m >> sentenceNum;
         // cout << m << sentenceNum << endl;
         if (m < 1 || m > 500 || sentenceNum < 1 || sentenceNum > 100)
             exit(-1);
             
         for(int i = 1; i <= m; i++) {
             cin >> corpus[i];
             // cout << corpus[i] << endl;
         }
         
         // B
         for(int i = 1; i <= m; i++) {
             cin >> B[i];
             B[i] = log(B[i]);
             // cout << B[i] << endl;
         }
         
         // cout << "==== T ====" << endl;
         
         // T
         for(int i = 0; i <= m; i++) {
             for(int j = 1; j <= m; j++) {
                 // 책의 트릭을 이용하여 시작단어를 [0][j] 인덱스에 저장
                 // 즉, Q[0]가 항상 시작단어라고 지정
                 // 그렇게 하면 P(Q)=∏(rightAfter(Q[i-1], Q[i])) => Begin(Q[0])*∏(rightAfter(Q[i-1], Q[i]))보다 간단해졌다
                 if(i == 0) {
                     T[i][j] = B[j];
                     // cout << "1. " << T[i][j] << endl;
                 } else {
                     cin >> T[i][j];
                     T[i][j] = log(T[i][j]);
                     // cout << "2." << T[i][j] << endl;
                 }
             }
         }
         
         // cout << "==== M ====" << endl;
         
         // M
         for(int i = 1; i <= m; i++) {
             for(int j = 1; j <= m; j++) {
                 cin >> M[i][j];
                 M[i][j] = log(M[i][j]);
                 // cout << "M. " << M[i][j] << endl;
             }
         }
         
         cout << "==== RESULT ====" << endl;
         
         for(int s = 0; s < sentenceNum; s++) {
             cin >> n;
             if (n < 1 || n > 100)
                 exit(-1);
             
             initialize();
             
             for(int i = 0; i < n; i++) {
                 string input;
                 cin >> input;
                 for(int j = 1; j <= m; j++) {
                     if(input == corpus[j]) {
                         R[i] = j;
                         break;
                     }
                 }
             }
             recognize(0, 0);
             cout << reconstruct(0, 0) << endl;
         }
         
         cout << "==== END ====" << endl;

         return 0;
     }
     */
    
    // n: 문장을 구성하는 단어의 개수 (composition)
    // m: 원문에 출현할 수 있는 단어의 수 (wordNum)
    // sentenceNum: 처리할 문장의 수
    var n, m, sentenceNum: Int
    
    // 분류기가 반환한 문장, 단어 번호로 변환되어 있음 (classified)
    var R: [Int] = [Int](repeating: 0, count: 100)
    
    // B: i번째 단어가 첫 단어로 나올 확률 (begin)
    var B: [Double]
    
    // T[i][j] = i 단어 이후에 j 단어가 나올 확률의 로그값 (rightAfter)
    var T: [[Double]]
    
    // M[i][j] = i 단어가 j 단어로 분류될 확률의 로그값 (mismatched)
    var M: [[Double]]
    
    var choice: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: 502), count: 102)
    
    // 확률은 [0, 1] 범위의 실수이기 때문에 확률의 로그값은 항상 0 이하
    // 1로 초기화한다.
    var cache: [[Double]]
    
    // Q[segment] 이후를 채워서 얻을 수 있는 최대 g() 곱의 로그값을 반환한다.
    // Q[segment - 1 == previousMatch라고 가정한다.
    func recognize(_ segment: Int, _ previousMatch: Int) -> Double {
        if segment == n {
            return 0
        }
        
        var ret: Double {
            get {
                return cache[segment][previousMatch]
            } set {
                cache[segment][previousMatch] = newValue
            }
        }
        
        if ret != 1.0 {
            return ret
        }
        
        ret = -1e200; // log(0) = -Infinity에 해당하는 값
        
        var choose: Int {
            get {
                return choice[segment][previousMatch]
            } set {
                choice[segment][previousMatch] = newValue
            }
        }
        
        // R[segment]에 대응되는 단어를 찾는다.
        for thisMatch in 0..<m {
            // g(thisMatch) = T(previousMatch, thisMatch) * M(thisMatch, R[segment])
            let cand: Double = T[previousMatch][thisMatch]
            + M[thisMatch][R[segment]]
            + recognize(segment + 1, thisMatch)
            
            if ret < cand {
                ret = cand
                choose = thisMatch
            }
        }
        
        return ret
    }
    
    // 입력받은 단어들의 목록
    // corpus: [언어] 언어 자료; 전자 코퍼스 (컴퓨터로 읽을 수 있는 텍스트·예문 등의 집합체)
    var corpus: [String]
    
    func reconstruct(_ segment: Int, _ previousMatch: Int) -> String {
        var choose: Int = choice[segment][previousMatch]
        var ret: String = corpus[choose]
        
        if segment < n - 1 {
            ret = ret + " " + reconstruct(segment + 1, choose)
        }
        
        return ret
    }
    /*
     5 3
     I am a boy buy
     1.0 0.0 0.0 0.0 0.0
     
     0.1 0.6 0.1 0.1 0.1
     0.1 0.1 0.6 0.1 0.1
     0.1 0.1 0.1 0.6 0.1
     0.2 0.2 0.2 0.2 0.2
     0.2 0.2 0.2 0.2 0.2
     
     0.8 0.1 0.0 0.1 0.0
     0.1 0.7 0.0 0.2 0.0
     0.0 0.1 0.8 0.0 0.1
     0.0 0.0 0.0 0.5 0.5
     0.0 0.0 0.0 0.5 0.5
     4 I am a buy
     4 I I a boy
     4 I am am boy
     */

    m = 5
    sentenceNum = 3
    
    // === corpus ===
    // for(int i = 1; i <= m; i++)
    // index: [0, 1, 2, 3, 4, 5]
    corpus = ["", "I", "am", "a", "boy", "buy"]
    
    // === B ===
    // for(int i = 1; i <= m; i++)
    B = [0.0, 1.0, 0.0, 0.0, 0.0, 0.0].logarithmize()
    
    // === T(rightAfter) ===
    // for(int i = 0; i <= m; i++)
    //  for(int j = 1; j <= m; j++)
    
    // 책의 트릭을 이용하여 시작단어를 [0][j] 인덱스에 저장
    // 즉, Q[0]가 항상 시작단어라고 지정
    // 그렇게 하면 P(Q)=∏(rightAfter(Q[i-1], Q[i])) => Begin(Q[0])*∏(rightAfter(Q[i-1], Q[i]))보다 간단해졌다.
    T = [
        B,
        [0.0, 0.1, 0.6, 0.1, 0.1, 0.1].logarithmize(),
        [0.0, 0.1, 0.1, 0.6, 0.1, 0.1].logarithmize(),
        [0.0, 0.1, 0.1, 0.1, 0.6, 0.1].logarithmize(),
        [0.0, 0.2, 0.2, 0.2, 0.2, 0.2].logarithmize(),
        [0.0, 0.2, 0.2, 0.2, 0.2, 0.2].logarithmize(),
    ]

    // === M(mismatched) ===
    // for(int i = 1; i <= m; i++)
    //  for(int j = 1; j <= m; j++)
    M = [
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0].logarithmize(),
        [0.0, 0.8, 0.1, 0.0, 0.1, 0.0].logarithmize(),
        [0.0, 0.1, 0.7, 0.0, 0.2, 0.0].logarithmize(),
        [0.0, 0.0, 0.1, 0.8, 0.0, 0.1].logarithmize(),
        [0.0, 0.0, 0.0, 0.0, 0.5, 0.5].logarithmize(),
        [0.0, 0.0, 0.0, 0.0, 0.5, 0.5].logarithmize(),
    ]

    var N = [4, 4, 4]
    var inputWords = [
        ["I", "am", "a", "buy"],
        ["I", "I", "a", "boy"],
        ["I", "am", "am", "buy"],
    ]
    
    // === RESULT ===
    for s in 0..<sentenceNum {
        n = N[s]
        // initialize cache
        cache = [[Double]](repeating: [Double](repeating: 1, count: 502), count: 102)
        
        for i in 0..<n {
           var input = inputWords[s][i]
            for j in 1...m {
                // print(input, s, i, j, corpus[j])
                if input == corpus[j] {
                    R[i] = j
                    break
                }
            }
            // print(R)
        }
        // Do DP
        _ = recognize(0, 0)
        let reconstructed = reconstruct(0, 0)
        print(reconstructed)
    }
   
}

Chapter_9_4()

// ====================================================================== //

func Chapter_9_6() {
    /* ************ C++ 코드 ************
     #include <iostream>
     #include <cstring>
     using namespace std;

     // s: 지금까지 만든 신호
     // n: 더 필요한 -의 개수
     // m: 더 필요한 o의 개수

     void generate(int n, int m, string s) {
         // 기저 사례 n = m = 0
         if(n == 0 && m == 0) {
             cout << s << endl;
             return;
         }
         
         if(n > 0)   generate(n - 1, m, s + "-");
         if(m > 0)   generate(n, m - 1, s + "o");
     }

     int skip;
     // skip 개를 건너뛰고 출력한다
     void generate2(int n, int m, string s) {
         // 기저사례: skip < 0
         if(skip < 0)    return;
         
         // 기저사례: n = m = 0
         if(n == 0 && m == 0) {
             // 더 건너뛸 신호가 없는 경우
             if(skip == 0)   cout << s << endl;
             
             --skip;
             return;
         }
         
         if(n > 0)   generate2(n - 1, m, s + "-");
         if(m > 0)   generate2(n, m - 1, s + "o");
     }

     // 좀 더 똑똑하게 건너뛰기

     // K의 최대값 +100, 오버플로를 막기 위해 이보다 큰 값은 구하지 않는다.
     // 입력 가능 개수 k가 10억 이하인 점을 이용
     const int M = 1000000000 + 100;
     int bino[201][201];

     // 필요한 모든 이항계수를 미리 계산해둔다.
     void calcBino() {
         memset(bino, 0, sizeof(bino));
         for(int i = 0; i <= 200; ++i) {
             // 다중 할당: bino[i][0] = 1 AND bino[i][i] = 1
             bino[i][0] = bino[i][i] = 1;
             for(int j = 1; j < i; j++) {
                 bino[i][j] = min(M, bino[i - 1][j - 1] + bino[i - 1][j]);
                 // cout << i << ","<< j << " " << bino[i][j] << endl;
             }
         }
     }

     // skip개를 건너뛰고 출력한다
     void generate3(int n, int m, string s) {
         // 기저사례: skip < 0
         if(skip < 0)    return;
         
         // 기저사례: n = m = 0
         if(n == 0 && m == 0) {
             // 더 건너뛸 신호가 없는 경우
             if(skip == 0)   cout << s << endl;
             
             --skip;
             return;
         }
         
         if(bino[n + m][n] <= skip) {
             skip -= bino[n + m][n];
             return;
         }
         
         if(n > 0)   generate3(n - 1, m, s + "-");
         if(m > 0)   generate3(n, m - 1, s + "o");
     }

     // n개의 -, m개의 o 신호로 구성 된 신호 중 skip 개를 건너뛰고
     // 만들어지는 신호를 반환
     string kth(int n, int m, int skip) {
         // n == 0 인 경우, 나머지 부분은 전부 o일 수 밖에 없다.
         if(n == 0)  return string(m, 'o');
         
         if(skip < bino[n + m - 1][n - 1]) {
             return "-" + kth(n - 1, m, skip);
         }
         
         return "o" + kth(n, m - 1, skip - bino[n + m - 1][n - 1]);
     }

     int main() {
         generate(2, 2, "");
         cout << "========" << endl;
         skip = 3;   // zero-based
         generate2(2, 2, "");
         
         calcBino();
         skip = 3;
         generate3(2, 2, "");
         
         cout << kth(2, 2, 3);
         cout << kth(15, 15, 792);

         return 0;
     }
     */
    
    func generate(_ n: Int, _ m: Int, _ s: String = "") {
        // 기저 사례 n = m = 0
        if n == 0 && m == 0 {
            print(s)
            return
        }
        
        if n > 0 {
            generate(n - 1, m, s + "-")
        }
        
        if m > 0 {
            generate(n, m - 1, s + "o")
        }
    }
    
    var skip: Int
    func generate2(_ n: Int, _ m: Int, _ s: String = "") {
        // 기저사례: skip < 0
        if skip < 0 {
            return
        }
        
        // 기저사례: n = m = 0
        if n == 0 && m == 0 {
            // 더 건너뛸 신호가 없는 경우
            if skip == 0 {
                print(s)
            }
            
            skip -= 1
            return
        }
        
        if n > 0 {
            generate2(n - 1, m, s + "-")
        }
        
        if m > 0 {
            generate2(n, m - 1, s + "o")
        }
        
    }
    
    // 필요한 모든 이항계수를 미리 계산해둔다.
    // void calcBino() {
    //     memset(bino, 0, sizeof(bino));
    //     for(int i = 0; i <= 200; ++i) {
    //         bino[i][0] = bino[i][i] = 1;
    //         for(int j = 1; j < i; j++) {
    //             bino[i][j] = min(M, bino[i - 1][j - 1] + bino[i - 1][j]);
    //             // cout << i << ","<< j << " " << bino[i][j] << endl;
    //         }
    //     }
    // }
    
    // K의 최대값 +100, 오버플로를 막기 위해 이보다 큰 값은 구하지 않는다.
    // 입력 가능 개수 k가 10억 이하인 점을 이용
    let M = 1_000_000_000 + 100
    var bino: [[Int]] {
        var twoDimArray = [[Int]](repeating: [Int](repeating: 0, count: 201), count: 201)
        
        for i in 0...200 {
            twoDimArray[i][0] = 1
            twoDimArray[i][i] = 1
            if i == 0 { continue }
            for j in 1..<i {
                twoDimArray[i][j] = min(M, twoDimArray[i - 1][j - 1] + twoDimArray[i - 1][j])
            }
        }
        
        return twoDimArray
    }
    
    func generate3(_ n: Int, _ m: Int, _ s: String = "") {
        // 기저사례: skip < 0
        if skip < 0 {
            return
        }
        
        // 기저사례: n = m = 0
        if n == 0 && m == 0 {
            // 더 건너뛸 신호가 없는 경우
            if skip == 0 {
                print(s)
            }
            
            skip -= 1
            return
        }
        
        if bino[n + m][n] <= skip {
            skip -= bino[n + m][n]
            return
        }
    
        if n > 0 {
            generate3(n - 1, m, s + "-")
        }
        
        if m > 0 {
            generate3(n, m - 1, s + "o")
        }
    }
    
    func kth(_ n: Int, _ m: Int, _ skip: Int) -> String {
        // n == 0 인 경우 나머지 부분은 전부 o 일수 밖에 없다
        // print(n, m, skip)
        if n == 0 {
            return String(repeating: "o", count: m)
        }
        // print(" -> ", bino[n + m - 1][n - 1], n + m - 1, n - 1)
        
        if skip < bino[n + m - 1][n - 1] {
            // print(skip, bino[n + m + 1][n - 1])
            return "-\(kth(n - 1, m, skip))"
        }
        
        return "o\(kth(n, m - 1, skip - bino[n + m - 1][n - 1]))"
    }
    
    generate(2, 2)
    
    print("===================")
    
    skip = 3
    generate2(2, 2)
    
    skip = 3
    generate3(2, 2)
    
    print(kth(2, 2, 3))
    let kth2 = kth(15, 15, 792)
    print(kth2, kth2 == "------------ooooooooooo-oo-oo-")
}
Chapter_9_6()
