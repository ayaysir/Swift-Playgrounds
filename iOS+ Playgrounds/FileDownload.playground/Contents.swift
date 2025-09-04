import AppKit
import PlaygroundSupport
import SwiftUI

// PlaygroundPage.current.needsIndefiniteExecution = true

let fm = FileManager.default
let downloadDirURL = fm.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")

let urlString = "https://filesamples.com/samples/image/png/sample_1280%C3%97853.png"

// MARK: - 방법 1: URLSession.shared.download 이용 - 진행률 표시 불가
func downloadFile(from urlString: String) async {
  guard let url = URL(string: urlString) else { return }
  let fileName = url.lastPathComponent
  
  print("다운로드 시작: \(fileName)")
  
  do {
    let (tempURL, response) = try await URLSession.shared.download(from: url)
    if let response = response as? HTTPURLResponse {
      print(response.statusCode, response.allHeaderFields)
    }
    let destinationURL = downloadDirURL.appendingPathComponent(fileName)
    do {
      if FileManager.default.fileExists(atPath: destinationURL.path) {
        try FileManager.default.removeItem(at: destinationURL)
      }
      
      try FileManager.default.moveItem(at: tempURL, to: destinationURL)
      print("다운로드 완료: \(destinationURL.path)")
    } catch {
      print("파일 저장 실패: \(error)")
    }
  } catch {
    print("다운로드 실패: \(error)")
  }
}

// MARK: - 방법 2: URLSessionDownloadDelegate 이용 (진행률 표시)
final class Downloader: NSObject, URLSessionDownloadDelegate {
  let url: URL
  let destinationURL: URL
  
  init(url: URL, destinationURL: URL) {
    self.url = url
    self.destinationURL = destinationURL
  }
  
  func start() {
    print("다운로드 시작: \(url.lastPathComponent)")
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    let task = session.downloadTask(with: url)
    task.resume()
  }
  
  // 진행률 콜백
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {
    guard totalBytesExpectedToWrite > 0 else {
      print(".", terminator: "")
      fflush(stdout)
      return
    }
    
    let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100
    // Swift에서는 print 시 terminator: "" 옵션과 캐리지 리턴(\r)을 활용하면 한 줄에서 숫자만 바뀌는 출력이 가능합니다.
    print(String(format: "진행률: %.1f%%\r", progress), terminator: "")
    fflush(stdout)
  }
  
  // 완료 콜백
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL
  ) {
    do {
      if FileManager.default.fileExists(atPath: destinationURL.path) {
        try FileManager.default.removeItem(at: destinationURL)
      }
      try FileManager.default.moveItem(at: location, to: destinationURL)
      print("\n다운로드 완료: \(destinationURL.path)")
    } catch {
      print("\n파일 저장 실패: \(error)")
    }
  }
}

// MARK: - 방법 3
func downloadFileAdv(from urlString: String) async {
  guard let url = URL(string: urlString) else { return }
  let fileName = url.lastPathComponent
  let destinationURL = downloadDirURL.appendingPathComponent(fileName)
  
  print("다운로드 시작: \(fileName)")

  do {
    // 요청 보내기
    let (bytes, response) = try await URLSession.shared.bytes(from: url)
    
    var downloadedData = Data()
    // AsyncSequence 형태로 바이트 스트리밍
    for try await chunk in bytes {
      downloadedData.append(chunk)
      
      if let expectedLength = response.expectedContentLength > 0 ? response.expectedContentLength : nil {
        let progress = Double(downloadedData.count) / Double(expectedLength) * 100
        print(String(format: "진행률: %.1f%%\r", progress), terminator: "")
        fflush(stdout)
      } else if downloadedData.count % 10240 == 0 {
        print(".", terminator: "")
        fflush(stdout)
      }
    }
    
    // 저장
    if FileManager.default.fileExists(atPath: destinationURL.path) {
      try FileManager.default.removeItem(at: destinationURL)
    }
    try downloadedData.write(to: destinationURL)
    
    print("\n다운로드 완료: \(destinationURL.path)")
    
  } catch {
    print("다운로드 실패: \(error)")
  }
}

let methodNumber = 3

switch methodNumber {
case 1:
  Task {
    await downloadFile(from: urlString)
  }
case 2:
  if let url = URL(string: urlString) {
    let fileName = url.lastPathComponent
    let destURL = downloadDirURL.appendingPathComponent(fileName)
    let downloader = Downloader(url: url, destinationURL: destURL)
    
    downloader.start()
  }
case 3:
  Task {
    await downloadFileAdv(from: urlString)
  }
default:
  break
}
