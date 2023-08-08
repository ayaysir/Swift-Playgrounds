import UIKit

/*
 choice[102][502]를 만드는 방법
 */
var choice: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: 502), count: 102)
choice[101][501]

var m = 5
var B = [0.0, 1.0, 0.0, 0.0, 0.0, 0.0]
var T = [[Double]](repeating: [Double](repeating: 0, count: m + 1), count: m + 1)

for i in 0...m {
    for j in 1...m {
        if i == 0 {
            T[i][j] = B[j]
        } else {
            T[i][j] = 43949.3939
        }
    }
}

print(T)

// for(int i = 1; i <= m; i++) {
//     for(int j = 1; j <= m; j++) {
//         cin >> M[i][j];
//         M[i][j] = log(M[i][j]);
//         // cout << "M. " << M[i][j] << endl;
//     }
// }

var M = [[Double]](repeating: [Double](repeating: 0, count: m + 1), count: m + 1)
for i in 1...m {
    for j in 1...m {
        M[i][j] = Double.random(in: 30.0...90.0)
    }
}

print(M)

var N = [4, 4, 4]
var n: Int
var inputWords = [
    ["I", "am", "a", "buy"],
    ["I", "I", "a", "boy"],
    ["I", "am", "am", "buy"],
]

var corpus = ["", "I", "am", "a", "boy", "buy"]
var R: [Int] = [Int](repeating: 0, count: 100)

for s in 0..<3 {
    n = N[s]
    // initialize cache
    
    for i in 0..<n {
       var input = inputWords[s][i]
        for j in 1...m {
            print(input, s, i, j, corpus[j])
            if input == corpus[j] {
                R[i] = j
                break
            }
        }
        print(R)
    }
    // Do DP
}

 // for(int s = 0; s < sentenceNum; s++) {
 //     cin >> n;
 //     if (n < 1 || n > 100)
 //         exit(-1);
 //
 //     initialize();
 //
 //     for(int i = 0; i < n; i++) {
 //         string input;
 //         cin >> input;
 //         for(int j = 1; j <= m; j++) {
 //             if(input == corpus[j]) {
 //                 R[i] = j;
 //                 break;
 //             }
 //         }
 //     }
 //     recognize(0, 0);
 //     cout << reconstruct(0, 0) << endl;
 // }
