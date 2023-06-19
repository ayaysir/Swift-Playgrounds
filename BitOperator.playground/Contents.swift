import UIKit

/*
 2진법 표기
 - 앞에 0b 접두사 붙임
 - 숫자 중간에 _를 붙여 자리 구분 (아무렇게나 넣어도 됨)
 */

// 2에 대한 이진법 표기 (1) -> Int
0b0000_0010

// 2에 대한 이진법 표기 (2) -> Int
0b0_000_1_0_

// Signed Integer: -2 (1111 1110B) 입력
// 직접 0b1111_1110를 입력하려고 하면 254로 인식해서 overflow됨
// https://stackoverflow.com/questions/58617839

Int8(-2).binaryDescription // " 1111 1110"
let minus2 = Int8(bitPattern: 0b1111_1110)

// 70(1000110B)과 54(110110B)의 AND 연산
70 & 54
// 결과: 6

// 204(11001100B)의 각 자릿수가 1인지 확인하기
for i in 0..<8 {
    let digit = (8 - 1) - i
    let powed = NSDecimalNumber(decimal: pow(2, digit))
    let isNumberOne = (Int(truncating: powed) & 204) != 0
    print(digit, isNumberOne)
}

// 70(1000110B)과 54(110110B)의 OR 연산
70 | 54
// 결과: 118

// XOR
70 ^ 54
// 결과: 112

// NOT
/*
 70(0100 0110B)
 
 1의 보수: 비트 반전
 1011 1001
 
 2의 보수: 1의 보수 결과에 1을 더한다.
 1011 1001 + 1 = 1011 1010
 
 >> 2의 보수에서 음수 알아내기
 1. 1을 빼고
 2. 비트 반전한 뒤
 3. 해당 비트에서 나온 양수값에 -(마이너스)를 붙임
 
 예) 1110 0111 (2의 보수 방식의 음수)
 1. 1을 뺀다 => 1110 0110
 2. 비트 반전 => 0001 1001
 3. 0001 1001 => 십진법 25 => (-) 붙여서 -25
 */

UInt8(70).binaryDescription // "0100 0110"
Int8(-70).binaryDescription // "1011 1010"

/*
 - 70(0100 0110B)에 ~를 붙이면 비트를 반전시킨다.
 - 반전된 비트 1011 1001은 2의 보수 방식의 음수이다.
 - 앞의 방식으로 변환하면 1011 1000 -> 0100 0111 -> -71
 */
~70
// 결과 : -71

// Left shift operator
70 << 2
// 결과: 280

// Right shift operator
70 >> 2
// 결과: 17

// 0000 0001
print("=============================")
var bitFlag = 1
let checkNumber = 0b11001010

for _ in 1...8 {
    print(bitFlag, (bitFlag & checkNumber) != 0)
    // bitFlag = bitFlag << 1
    bitFlag <<= 1
}
