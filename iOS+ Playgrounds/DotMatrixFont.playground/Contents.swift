import UIKit
import FoundationModels
import PlaygroundSupport

extension Character {
  var isWhitespace: Bool {
    unicodeScalars.allSatisfy {
      CharacterSet.whitespacesAndNewlines.contains($0)
    }
  }
}


var char = """
.###.
#...#
.###.
.###.
#...#
#...#
.###.
"""

// MARK: - 압축
// 181n64618636rn

func compressRN(rawText: String) -> String {
  let charWithoutLB = rawText.split(separator: "").filter{ $0 != "\n" }
  let chunked = stride(from: 0, to: charWithoutLB.count, by: 5).map { i in
    Array(charWithoutLB[i..<min(i + 5, charWithoutLB.count)])
  }
  
  var output: [String] = []
  for (i, chunk) in chunked.enumerated() {
    var currentChar = "_"
    var currentCount = 0
    
    if i > 0 {
      if chunk == chunked[i - 1] {
        output.append("r")
        continue
      }
      
      if chunk.map({ $0 == "." ? "#" : "."}) == chunked[i - 1] {
        output.append("n")
        
        continue
      }
    }
    
    for (i, c) in chunk.enumerated() {
      if i == 0 {
        currentChar = String(c)
        currentCount = 1
        continue
      }
      
      if c != currentChar {
        let countText = currentChar == "." ? currentCount : (currentCount + 5) % 10
        output.append(countText.description)
        currentChar = String(c)
        currentCount = 1
      } else {
        currentCount += 1
      }
      
      if i == (chunk.count - 1) {
        let countText = currentChar == "." ? currentCount : (currentCount + 5) % 10
        output.append(countText.description)
        break
      }
    }
  }
  
  return output.joined()
}

func extractRN2(compressedText: String) -> [[Bool]] {
  let N_CODE = 110
  let R_CODE = 114
  
  var tempPrev: [Bool] = []
  var finalOutput: [[Bool]] = []
  
  for u in compressedText.utf8 {
    if u == N_CODE {
      tempPrev = tempPrev.map { !$0 }
      finalOutput.append(tempPrev)
      continue
    } else if u == R_CODE {
      finalOutput.append(tempPrev)
      continue
    }
    
    if tempPrev.count == 5 {
      tempPrev = []
    }
    
    let number = Int(u - 48)
    if number != 0 && number <= 5 {
      tempPrev += Array(repeating: false, count: number)
    } else {
      tempPrev += Array(repeating: true, count: number == 0 ? 5 : (number - 5))
    }
    
    if tempPrev.count == 5 {
      finalOutput.append(tempPrev)
    }
  }
  
  return finalOutput
}

func extractRN(compressedText: String) -> String {
  var tempPrev = ""
  var finalOutput = ""
  for c in compressedText {
    if c == "n" {
      tempPrev = tempPrev.map { $0 == "." ? "#" : "." }.joined()
      finalOutput += tempPrev + "\n"
      continue
    } else if c == "r" {
      finalOutput += tempPrev + "\n"
      continue
    }
    
    if tempPrev.count == 5 {
      tempPrev = ""
    }
    
    let number = Int(String(c))!
    if number != 0 && number <= 5 {
      tempPrev += String(repeating: ".", count: number)
    } else {
      tempPrev += String(repeating: "#", count: number == 0 ? 5 : (number - 5))
    }
    
    if tempPrev.count == 5 {
      finalOutput += tempPrev + "\n"
    }
  }
  
  finalOutput.popLast() // 마지막 \n 제거
  return finalOutput
}

let compressedText = compressRN(rawText: char)
let extractedText = extractRN(compressedText: compressedText)
print(compressedText)
print(extractedText)
print("eci")

print("asddf")
var splitted = char.split(separator: "\n")

var chars1 = """
.###..####...###..####..#####...
#...#.#...#.#...#.#...#.#.......
#...#.#...#.#.....#...#.#.......1
#####.####..#.....#...#.####....
#...#.#...#.#.....#...#.#.......
#...#.#...#.#...#.#...#.#.......
#...#.####...###..####..#####...
................................
#####..###..#...#..###...####...
#.....#...#.#...#...#.......#...
#.....#.....#...#...#.......#...
####..#.###.#####...#.......#...
#.....#...#.#...#...#.......#...
#.....#...#.#...#...#...#...#...
#......###..#...#..###...###....
................................
#...#.#.....#...#.#...#..###....
#...#.#.....##.##.#...#.#...#...
#..#..#.....#.#.#.##..#.#...#...
###...#.....#...#.#.#.#.#...#...
#..#..#.....#...#.#..##.#...#...
#...#.#.....#...#.#...#.#...#...
#...#.#####.#...#.#...#..###....
................................
####...###..####...###..#####...
#...#.#...#.#...#.#...#...#.....
#...#.#...#.#...#.#.......#.....
####..#...#.####...###....#.....
#.....#.#.#.#...#.....#...#.....
#.....#..##.#...#.#...#...#.....
#......####.#...#..###....#.....
................................
#...#.#...#.#...#.#...#.#...#...
#...#.#...#.#...#.#...#.#...#...
#...#.#...#.#...#..#.#...#.#....
#...#.#...#.#...#...#.....#.....
#...#.#...#.#.#.#..#.#....#.....
#...#..#.#..##.##.#...#...#.....
.###....#...#...#.#...#...#.....
................................
#####.......#####...............
....#.......#####...............
...#........#####...#...........
..#.........#####........###....
.#..........#####...#...........
#...........#####...............
#####.......#####...............
................................
........#....###...###.....#....
.......##...#...#.#...#...##....
........#.......#.....#..#.#....
........#......#....##..#..#....
........#.....#.......#.#####...
........#....#....#...#....#....
#####..###..#####..###.....#....
................................
#####..###..#####..###...###....
#.....#...#.....#.#...#.#...#...
#.....#........#..#...#.#...#...
####..####....#....###...####...
....#.#...#...#...#...#.....#...
....#.#...#...#...#...#.#...#...
####...###....#....###...###....
................................
.###..........#....###..........
#...#.........#...#...#.........
##..#.........#.......#.........
#.#.#.........#......#..........
#..##.........#.....#...........
#...#.....................#.....
.###....#.....#.....#....#......
................................
.........#...#.....#.....#.#....
........#.....#....#.....#.#....
........#.....#...#.....#.#.....
........#.....#.................
..#.....#.....#.................
..#.....#.....#.................
.#.......#...#..................
................................
................................
..#.........#...#...#...........
..#..........#.#........#####...
#####.#####...#...#####.........
..#..........#.#........#####...
..#.........#...#...#...........
................................
................................
....#.#.....##........#.#.......
...#...#....##..#....#...#......
..#.....#......#.....#...#......
.#.......#....#.....#.....#.....
..#.....#....#.....#.......#....
...#...#....#..##..#.......#....
....#.#........##.#.........#...
................................
................................
..............#.....#.....#.....
.#.#...#.#.....#...#.....###....
............#####.#####.#.#.#...
#...#..###.....#...#......#.....
.###..#...#...#.....#.....#.....
................................
................................
................................
..#....####.....#.####..#.......
..#......##.#..#..##.....#..#...
#.#.#...#.#.#.#...#.#.....#.#...
.###...#..#.##....#..#.....##...
..#...#.....####......#..####...
................................
................................
..#.............................
.#.#............................
#...#...........................
................................
................................
................................
................................
"""

let lines = chars1.split(separator: "\n")
var blockChars: [String] = []

for i in stride(from: 0, to: lines.count, by: 8) {
  var chars: [String] = .init(repeating: "", count: 5)
  for j in 0..<7 {
    // print(lines[i + j])
    let lineText = lines[i + j]
    for k in stride(from: 0, through: 24, by: 6) {
      let start = lineText.index(lineText.startIndex, offsetBy: k + 0)
      let end = lineText.index(lineText.startIndex, offsetBy: k + 5)
      let result = String(lineText[start..<end])
      // print(k)
      chars[k/6] += "\(result)\n"
    }
  }
  blockChars.append(contentsOf: chars)
  chars = .init(repeating: "", count: 5)
}

// for block in blockChars {
//   let compressed = compressRN(rawText: block)
//   print("\"\": \"\(compressed)\",")
// }

let dotChars: [Character : String] = [
  "A": "181nr0636rr",
  "B": "91636r91636r91",
  "C": "181n64rr636n",
  "D": "91636rrrr91",
  "E": "064r9164r0",
  "F": "064r9164rr",
  "G": "181n64618636rn",
  "H": "636rr0636rr",
  "I": "181262rrrr181",
  "J": "1946rrr636n",
  "K": "636r6261826261636r",
  "L": "64rrrrr0",
  "M": "63671761616636rrr",
  "N": "636r72661616627636r",
  "O": "181nrrrrn",
  "P": "91636r9164rr",
  "Q": "181nrr6161662719",
  "R": "91636r91636rr",
  "S": "181n6418146636n",
  "T": "0262rrrrr",
  "U": "636rrrrrn",
  "V": "636rrrr16161262",
  "W": "636rrr61616717636",
  "X": "636r1616126216161636r",
  "Y": "636r16161262rrr",
  "Z": "046361262163640",
  " ": "5rrrrrr", // space
  "\u{5}": "0rrrrrr", // filledSquare
  ":": "5r26252625r",
  "-": "5rr1815rr",
  "_": "5rrrrrn",
  "1": "262172262rrr181",
  "2": "181n463612621630",
  "3": "181n4627146636n",
  "4": "3612711616162610361r",
  "5": "064r91nrn",
  "6": "181n6491636rn",
  "7": "046361262rrr",
  "8": "181nrnnrn",
  "9": "181nr1946636n",
  "0": "181n72661616627636n",
  ".": "5rrrrr262",
  "!": "262rrrr5262",
  "?": "181n463612625262",
  ",": "5rrrr262163",
  ";": "5rrr262r163", // ? 뭔지 모르겠음 , 가 한칸 위로 길어짐
  "(": "361262rrrr361",
  ")": "163262rrrr163",
  "'": "163r645rrr",
  "\"": "16161r61625rrr",
  "+": "5262r0262r5",
  "\u{10}": "5rrnnrr", // minus
  "*": "563616161262161616365",
  "@": "52625nn2625", // divider
  "=": "5rnnnnr",
  "<": "4636126216326236146",
  ">": "6416326236126216364",
  "%": "7372636126216362737",
  "/": "46361r262163r64",
  "\\": "64163r262361r46",
  "$": "5r161615636n5", // smile
  "&": "5r161615181n5", // negative-smile
  "\u{11}": "526236103612625", // ->
  "\u{12}": "526216301632625", // <-
  "\u{13}": "526218161616262r5", // upper-arrow
  "\u{14}": "5262r616161812625", // lower-arrow
  "\u{15}": "5193726161626645", // ↗
  "\u{16}": "5466261616273915", // ↙
  "\u{17}": "5917361626261465", // ↖
  "\u{18}": "5641626261637195", // ↘
  "^": "262161616365rrr",
]

var dotCharsUInt8: [UInt8 : String] = [
  5: "0rrrrrr", // filledSquare (Enquiry)
  16: "5rrnnrr", // minus (Data Link Escape)
  17: "526236103612625", // → (DC1)
  18: "526216301632625", // ← (DC2)
  19: "526218161616262r5", // ↑ (DC3)
  20: "5262r616161812625", // ↓ (DC4)
  21: "5193726161626645", // ↗ (Negative Acknowledge)
  22: "5466261616273915", // ↙ (Synchronous Idle)
  23: "5917361626261465", // ↖ (End of Transmission Block)
  24: "5641626261637195", // ↘ (Cancel)
  32: "5rrrrrr", // Space
  33: "262rrrr5262", // !
  34: "16161r61625rrr", // "
  36: "5r161615636n5", // Smile ($)
  37: "7372636126216362737", // %
  38: "5r161615181n5", // Negative-Smile (&)
  39: "163r645rrr", // '
  40: "361262rrrr361", // (
  41: "163262rrrr163", // )
  42: "563616161262161616365", // *
  43: "5262r0262r5", // +
  44: "5rrrr262163", // ,
  45: "5rr1815rr", // -
  46: "5rrrrr262", // .
  47: "46361r262163r64", // /
  48: "181n72661616627636n", // 0
  49: "262172262rrr181", // 1
  50: "181n463612621630", // 2
  51: "181n4627146636n", // 3
  52: "3612711616162610361r", // 4
  53: "064r91nrn", // 5
  54: "181n6491636rn", // 6
  55: "046361262rrr", // 7
  56: "181nrnnrn", // 8
  57: "181nr1946636n", // 9
  58: "5r26252625r", // :
  59: "5rrr262r163", // ;
  60: "4636126216326236146", // <
  61: "5rnnnnr", // =
  62: "6416326236126216364", // >
  63: "181n463612625262", // ?
  64: "52625nn2625", // Divider (@)
  65: "181nr0636rr", // A
  66: "91636r91636r91", // B
  67: "181n64rr636n", // C
  68: "91636rrrr91", // D
  69: "064r9164r0", // E
  70: "064r9164rr", // F
  71: "181n64618636rn", // G
  72: "636rr0636rr", // H
  73: "181262rrrr181", // I
  74: "1946rrr636n", // J
  75: "636r6261826261636r", // K
  76: "64rrrrr0", // L
  77: "63671761616636rrr", // M
  78: "636r72661616627636r", // N
  79: "181nrrrrn", // O
  80: "91636r9164rr", // P
  81: "181nrr6161662719", // Q
  82: "91636r91636rr", // R
  83: "181n6418146636n", // S
  84: "0262rrrrr", // T
  85: "636rrrrrn", // U
  86: "636rrrr16161262", // V
  87: "636rrr61616717636", // W
  88: "636r1616126216161636r", // X
  89: "636r16161262rrr", // Y
  90: "046361262163640", // Z
  92: "64163r262361r46", // \
  94: "262161616365rrr", // ^
  95: "5rrrrrn", // _
]
// dotChars.reduce(into: uint8Dict) { partialResult, element in
//   let (key, value) = element
//   guard let ascii = key.asciiValue else {
//     return
//   }
//   uint8Dict[ascii] = value
// }

// uint8Dict.keys.sorted().forEach {
//   print("\($0): \"\(uint8Dict[$0, default: ""])\", // \(UnicodeScalar($0))")
// }

// "181nr0636rr".utf8.forEach {
//     print($0 - 48)
// }

// for (key, value) in dotChars {
//   let extracted = extractRN(compressedText: value)
//   print(key, value)
//   print(extracted)
//   print("====================")
// }


// assetsUnavailable(FoundationModels.LanguageModelSession.GenerationError.Context(debugDescription: "Model is unavailable", underlyingErrors: []))

func nextMultiple(of value: Int, for number: Int) -> Int {
  ((number + value - 1) / value) * value
}

let utf8s = "$& AIEfjdskf saiFHife...,dk \u{5}\u{11}".uppercased()
var outputTextArr: [[String]] = .init(repeating: [String](), count: 7)
utf8s.forEach { c in
  if let dotCharComp = dotChars[c] {
    let dotCharArr = extractRN(compressedText: dotCharComp).split(separator: "\n")
    for i in 0..<7 {
      outputTextArr[i].append(String(dotCharArr[i]))
    }
  } else {
    let dotCharArr = extractRN(compressedText: "0rrrrrr").split(separator: "\n")
    for i in 0..<7 {
      outputTextArr[i].append(String(dotCharArr[i]))
    }
  }
}

@MainActor func generateTextMatrix(_ text: String) -> [UInt8] {
  let DOT_CODE: UInt8 = 46
  var rowSeparatedArr: [[UInt8]] = .init(repeating: [UInt8](), count: 7)
  var matrix: [UInt8] = []
  
  for u in text.utf8 {
    // 소문자로 입력받은 경우 대문자로 변환
    let ascii = if 97...122 ~= u {
      u - 32
    } else {
      u
    }
    
    let dotChar = if let dotCharCompressed = dotCharsUInt8[ascii] {
      extractRN(compressedText: dotCharCompressed)
    } else {
      extractRN(compressedText: "0rrrrrr")
    }
    
    var row = 0

    for v in dotChar.utf8 {
      if v == 10 {
        rowSeparatedArr[row] += [DOT_CODE] // 문자 간 스페이스
        row += 1
        continue
      }
      rowSeparatedArr[row] += [v]
    }
    
    rowSeparatedArr[row] += [DOT_CODE]
  }
  
  assert(rowSeparatedArr.count == 7)
  
  for rowArr in rowSeparatedArr {
    var rowArr = rowArr + [UInt8](repeating: DOT_CODE, count: nextMultiple(of: 32, for: rowArr.count) - rowArr.count)
    for i in stride(from: 0, to: rowArr.count, by: 8) {
      var eightElements = Array(rowArr[i..<min(i + 8, rowArr.count)])
      var n: UInt8 = 0
      for j in 0..<8 {
        // print(eight.count, j, eight)
        n <<= 1
        if (eightElements.count - 1) < j {
          n += 0
        } else {
          n += (eightElements[j] == DOT_CODE) ? 0 : 1
        }
      }
      
      matrix.append(n)
      n = 0
    }
  }
  
  return matrix + Array(repeating: 0, count: matrix.count / 7)
}

print(generateTextMatrix("\"\u{11}\u{12}\u{13}\u{14}The quick brown fox jumps over the lazy dog\" is an English-language pangram"))
print("============")
// print(outputTextArr.map{$0.joined()}.joined(separator: "\n"))


@MainActor func generateTextMatrix2(_ text: String) -> [UInt8] {
  // let DOT_CODE: UInt8 = 46
  var rowSeparatedArr: [[Bool]] = .init(repeating: [Bool](), count: 7)
  var matrix: [UInt8] = []
  
  for u in text.utf8 {
    // 소문자로 입력받은 경우 대문자로 변환
    let ascii = if 97...122 ~= u {
      u - 32
    } else {
      u
    }
    
    let dotChar = if let dotCharCompressed = dotCharsUInt8[ascii] {
      extractRN2(compressedText: dotCharCompressed)
    } else {
      extractRN2(compressedText: "0rrrrrr")
    }
    
    var row = 0

    for row in dotChar.indices {
      rowSeparatedArr[row] += (dotChar[row] + [false])
    }
  }
  
  assert(rowSeparatedArr.count == 7)
  
  for rowArr in rowSeparatedArr {
    var rowArr = rowArr + [Bool](repeating: false, count: nextMultiple(of: 32, for: rowArr.count) - rowArr.count)
    for i in stride(from: 0, to: rowArr.count, by: 8) {
      var eightElements = Array(rowArr[i..<min(i + 8, rowArr.count)])
      var n: UInt8 = 0
      for j in 0..<8 {
        // print(eight.count, j, eight)
        n <<= 1
        if (eightElements.count - 1) < j {
          n += 0
        } else {
          n += (eightElements[j] == false) ? 0 : 1
        }
      }
      
      matrix.append(n)
      n = 0
    }
  }
  
  return matrix + Array(repeating: 0, count: matrix.count / 7)
}
let ra = generateTextMatrix("\"\u{11}\u{12}\u{13}\u{14}The quick brown fox jumps over the lazy dog\" is an English-language pangram")
let rb = generateTextMatrix2("\"\u{11}\u{12}\u{13}\u{14}The quick brown fox jumps over the lazy dog\" is an English-language pangram")
print(ra == rb)
print("============")

var matrix1: [UInt8] = []
for o in outputTextArr {
  var jSpl = Array(o.joined(separator: ".").split(separator: ""))
  // 96: 32의 배수중 가장 가까운 곳
  jSpl += Array(repeating: ".", count: nextMultiple(of: 32, for: jSpl.count) - jSpl.count)
  // print("jsplCount:", jSpl.count)
  for i in stride(from: 0, to: jSpl.count, by: 8) {
    var eight = Array(jSpl[i..<min(i + 8, jSpl.count)])
    // print("eightCount:", eight.count, i)
    
    var n: UInt8 = 0
    for j in stride(from: 0, through: 7, by: 1) {
      // print(eight.count, j, eight)
      n <<= 1
      if (eight.count - 1) < j {
        n += 0
      } else {
        n += (eight[j] == ".") ? 0 : 1
      }
      
    }
    matrix1.append(n)
    // print("\(matrix1.count) \(String(n, radix: 2))\n-----")
    n = 0
  }
}

// 세로 행이 8개여야 하는데 dotChar 는 각각 세로 7 길이임 => 맨 밑줄에 공백 추가해서 맞추기
matrix1 += Array(repeating: 0, count: matrix1.count / 7)
print(matrix1.count, matrix1)
