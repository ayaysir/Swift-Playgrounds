import Foundation

func logger(_ array: any Collection, title: String? = nil) {
  print("=============\(title ?? "")=============")
  print("count:", array.count)
  array.forEach { print($0) }
}

/// `Complex` 구조체는 **복소수(Complex Number)**를 표현하기 위한 사용자 정의 타입입니다. Swift 5.5에는 복소수를 기본으로 지원하는 타입이 없기 때문에, 직접 구조체를 만들어야 합니다.
/// - Parameters:
///   - re: 실수(real) 부분
///   - im: 허수(imaginary) 부분
struct Complex {
  var re: Double
  var im: Double

  init(_ re: Double, _ im: Double) {
    self.re = re
    self.im = im
  }

  static func + (a: Complex, b: Complex) -> Complex {
    return Complex(a.re + b.re, a.im + b.im)
  }

  static func - (a: Complex, b: Complex) -> Complex {
    return Complex(a.re - b.re, a.im - b.im)
  }

  static func * (a: Complex, b: Complex) -> Complex {
    return Complex(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re)
  }

  static func / (a: Complex, b: Double) -> Complex {
    return Complex(a.re / b, a.im / b)
  }
  
  /// 복합 연산자 (곱셈)
  static func *= (a: inout Complex, b: Complex) {
    a = a * b
  }
  
  /// 복합 연산자 (나눗셈)
  static func /= (a: inout Complex, b: Double) {
    a = a / b
  }
}

/// fft는 **Fast Fourier Transform(고속 푸리에 변환)**의 약자로, 입력 배열을 시간 영역 → 주파수 영역으로 바꾸는 함수입니다.
/// - 왜 쓰는가?
///   - 컨볼루션을 빠르게 계산하기 위해서입니다.
///   - 일반적으로 컨볼루션은 O(N²)이지만, FFT를 사용하면 **O(N log N)**으로 계산 가능
/// - Parameters:
///   - a: 복소수 배열 (입력 + 결과가 이 안에서 처리됨)
///   - invert: `false`는 정방향 FFT, true는 역방향 FFT(iFFT)
/// - ✅ 핵심 개념 요약
///   | 단계     | 설명                                   |
///   | ------ | ------------------------------------ |
///   | 분할     | 짝수/홀수 인덱스로 나눔                        |
///   | 정복     | 나눈 배열을 재귀적으로 다시 FFT 적용               |
///   | 병합     | 결과를 복소수 곱과 합으로 합침 (`u + v`, `u - v`) |
///   | 회전 인자  | 각 단계에서 복소수 원에 따라 회전하는 `w`와 `wn`      |
///   | 역변환 보정 | `invert == true`일 경우 결과를 2로 나눠서 복원   |

func fft(_ a: inout [Complex], invert: Bool) {
  let n = a.count
  if n == 1 { return }
  
  var a0 = [Complex]()
  var a1 = [Complex]()
  a0.reserveCapacity(n / 2)
  a1.reserveCapacity(n / 2)
  
  // 짝수 인덱스와 홀수 인덱스로 나눔
  // Cooley-Tukey FFT Algorithm
  for i in 0..<n {
    if i % 2 == 0 {
      a0.append(a[i])
    } else {
      a1.append(a[i])
    }
  }
  
  // 나눈 배열을 각각 FFT 재귀 처리 (Divide and Conquer)
  fft(&a0, invert: invert)
  fft(&a1, invert: invert)
  
  // 나눠진 결과 합치기
  // 회전 인자 계산
  let ang = 2.0 * Double.pi / Double(n) * (invert ? -1 : 1)
  var w = Complex(1, 0)
  // wn: 현재 단계에서 복소수 원을 따라 곱해줄 기본 단위
  let wn = Complex(cos(ang), sin(ang))
  
  for i in 0..<n/2 {
    let u = a0[i]
    let v = a1[i] * w
    a[i] = u + v
    a[i + n/2] = u - v
    w *= wn // 복소수 원상의 회전을 적용(즉, 주파수 각도 증가)
  }
  
  // 역변환일 경우 스케일 조정
  if invert {
    for i in 0..<n {
      a[i] /= 2.0
    }
  }
}

/**
 컨볼루션: 두 배열의 곱셈 합을 통해 새로운 배열을 만드는 연산, 이 함수는 2의 거듭제곱으로 패딩, 실수 오차에 대비한 round() 처리까지 함
 ---

 ## ✅ 직관적 정의

 두 배열 `A`와 `B`가 있을 때, 컨볼루션 `C`는 다음과 같이 정의됩니다:

 $$
 C[k] = \sum_{i=0}^{k} A[i] \cdot B[k - i]
 $$

 즉, 인덱스가 `k`인 지점에서 `A`의 앞부분과 `B`의 뒷부분을 곱하고 더한 것입니다.
 이 연산은 각 `k`에 대해 **모든 가능한 쌍의 곱**을 계산합니다.

 ---

 ## 🔧 예시로 이해하기

 ```swift
 let A = [1, 2, 3]
 let B = [4, 5, 6]
 ```

 컨볼루션 결과 C는 길이가 `A.count + B.count - 1 = 5`인 배열이 됩니다.

 각 항을 계산하면:

 * `C[0] = A[0]*B[0] = 1*4 = 4`
 * `C[1] = A[0]*B[1] + A[1]*B[0] = 1*5 + 2*4 = 5 + 8 = 13`
 * `C[2] = A[0]*B[2] + A[1]*B[1] + A[2]*B[0] = 1*6 + 2*5 + 3*4 = 6 + 10 + 12 = 28`
 * `C[3] = A[1]*B[2] + A[2]*B[1] = 2*6 + 3*5 = 12 + 15 = 27`
 * `C[4] = A[2]*B[2] = 3*6 = 18`

 결과:

 ```swift
 C = [4, 13, 28, 27, 18]
 ```

 ---

 ## 🧠 왜 중요한가?

 컨볼루션은:

 * **두 수의 합으로 만들 수 있는 경우의 수 계산**
 * **이미지 필터링 (블러, 엣지 감지 등)**
 * **디지털 신호 처리**
 * **음향 합성, 리버브 처리**

 등 수많은 분야에서 핵심입니다.

 ---

 ## 🚀 알고리즘에서의 컨볼루션

 * 일반적인 컨볼루션은 `O(N²)`이지만,
 * \*\*FFT (고속 푸리에 변환)\*\*를 이용하면 `O(N log N)`으로 빠르게 계산할 수 있습니다.
 * 문제 풀이 사이트에서 **"두 수의 합으로 가능한 거리 계산"** 등에 자주 활용됩니다.
 
 ---
 ## 요약

 | 단계 | 설명                        |
 | -- | ------------------------- |
 | 1. | 입력 배열을 2의 거듭제곱 길이로 확장     |
 | 2. | 복소수 배열로 변환                |
 | 3. | FFT를 이용해 주파수 변환           |
 | 4. | 주파수 영역에서 곱셈 수행 (컨볼루션의 핵심) |
 | 5. | 역 FFT로 결과 복원              |
 | 6. | 실수부만 추출해 정수 배열로 반환        |

 ---
 - Parameters:
   - a: 정수 배열 1
   - b: 정수 배열 2

 */
func convolution(_ a: [Int], _ b: [Int]) -> [Int] {
  // 배열 크기 설정 (다음 2의 거듭제곱으로 확장)
  var n = 1
  while n < a.count + b.count {
    // n을 1번 비트 왼쪽으로 시프트 후 복합 대입
    n <<= 1
  }
  /*
   FT는 배열 길이가 2의 거듭제곱이어야 빠르게 계산할 수 있기 때문에
   예: a.count + b.count = 6이면, n = 8로 설정
   나중에 사용할 Complex 배열들의 길이를 이 n으로 맞춥니다.
   */
  
  // 복소수 배열 준비 (FFT 연산은 실수 및 허수까지 계산)
  var fa = [Complex](repeating: Complex(0, 0), count: n)
  var fb = [Complex](repeating: Complex(0, 0), count: n)
  
  // 복소수 배열로 변환
  for i in 0..<a.count {
    fa[i] = Complex(Double(a[i]), 0)
  }
  for i in 0..<b.count {
    fb[i] = Complex(Double(b[i]), 0)
  }
  
  // 정방향 FFT 실행
  fft(&fa, invert: false)
  logger(fa, title: "정방향 FFT: fa")
  fft(&fb, invert: false)
  logger(fb, title: "정방향 FFT: fb")
  /*
   시간 영역(Time domain)의 데이터를 **주파수 영역(Frequency domain)**으로 변환
   FFT는 곱셈이 빠르다는 특징을 활용하기 위함
   */
  
  // 주파수 영역에서 요소별 곱
  for i in 0..<n {
    fa[i] *= fb[i]
  }
  /*
   - 각각의 주파수 성분을 원소별로 곱합니다
   - 이 과정이 컨볼루션의 핵심 연산에 해당합니다.
   - 시간 영역에서의 컨볼루션은 주파수 영역에서의 곱셈과 동일합니다 (컨볼루션 정리)
   */
  logger(fa, title: "주파수 영역에서 요소별 곱")
  
  // 역 FFT 실행 (주파수 → 시간)
  fft(&fa, invert: true)
  /*
   - 다시 주파수 영역을 시간 영역으로 변환
   - 결과 배열 fa에 컨볼루션 결과가 들어 있음
   */
  logger(fa, title: "역 FFT 실행 (주파수 → 시간)")
  
  // 결과 복원 (반올림하여 정수 배열로)
  var result = [Int](repeating: 0, count: n)
  for i in 0..<n {
    result[i] = Int(round(fa[i].re)) // 복소수 실수부 .re만 사용 (허수부는 0에 수렴)
  }
  return result
}

let a = [1, 2, 3, 4, 5]
let b = [6, 7, 8, 9, 10]
let c = convolution(a, b)
print(c)
