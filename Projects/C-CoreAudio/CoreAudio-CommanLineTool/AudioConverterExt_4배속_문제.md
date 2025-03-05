## AudioConverterExt 4배속 문제

```plain
 위의 convert 함수와 아래 로그를 보고 왜 변환된 파일의 재생속도가 4배 빨리지는지 원인 및 해결책 알려줘

 outputBufferSize: 32768
 sizePerPacket: 4
 packetsPerBuffer: 8192
 outputBuffeMemSize: 32768
 outputBuffer allocated with capacity: 32768
 outputFilePacketPosition initialized: 0
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 8192
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 16384
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 24576
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 32768
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 40960
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 49152
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 57344
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 65536
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 73728
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 81920
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 90112
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 98304
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 106496
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 114688
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 122880
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 131072
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 139264
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 147456
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 155648
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 163840
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 172032
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 180224
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 188416
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 196608
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 204800
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 212992
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 221184
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 229376
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 237568
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 245760
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 253952
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 262144
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 270336
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 278528
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 286720
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 294912
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 303104
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 311296
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 8192
 outputFilePacketPosition updated: 319488
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 4096
 outputFilePacketPosition updated: 323584
 convertedData initialized with mNumberBuffers: 1, mDataByteSize: 32768
 frameCount before read: 8192
 frameCount after read: 0
 Done reading from file.
 Finished:
```

### **원인 분석: 변환된 파일의 재생 속도가 4배 빠르게 되는 이유**

재생 속도가 원래보다 **4배 빠르게** 되는 것은 변환된 오디오 파일이 **실제보다 1/4 길이의 데이터로 해석**되기 때문입니다. 로그와 코드를 분석해보면, 이는 다음과 같은 이유 때문일 가능성이 큽니다.

1. **출력 포맷의 `mBytesPerPacket` 값이 잘못 설정됨**
   - 로그에서 `sizePerPacket = 4`로 설정되어 있는데, 이는 `mBytesPerPacket` 값입니다.
   - 원본 `inputFormat`의 `mBytesPerPacket`이 `0`인 것으로 보아, 가변 비트레이트(VBR) 형식이거나 잘못된 설정일 가능성이 있습니다.
   - `mBytesPerPacket`이 4로 설정되었지만, 실제 PCM 데이터는 16비트(2바이트) * 2채널 = **4바이트/프레임**이므로 `mFramesPerPacket = 1`이라면 정상입니다.
   - 하지만 `mFramesPerPacket`이 다르게 설정되었을 경우, 샘플 수가 잘못 계산될 수 있습니다.

2. **패킷 크기(`packetsPerBuffer`) 계산 문제**
   - `packetsPerBuffer = outputBufferSize / sizePerPacket = 32768 / 4 = 8192`로 계산되었습니다.
   - 하지만 `sizePerPacket`이 잘못 설정되었거나, `mFramesPerPacket`이 1이 아닌 값으로 설정된 경우, 실제보다 4배 많은 샘플을 기록하게 됩니다.

3. **오디오 프레임 단위 계산 오류**
   - `AudioFileWritePackets()` 호출 시 `inStartingPacket` 값을 `outputFilePacketPosition / settings.outputFormat.mBytesPerPacket`로 설정했지만, 이 값이 올바르게 계산되지 않았을 가능성이 있습니다.
   - 일반적으로 PCM 오디오에서는 `inStartingPacket`을 `outputFilePacketPosition / (mBytesPerFrame * mFramesPerPacket)`로 계산해야 합니다.

---

### **해결 방법**
1. **출력 포맷(`outputFormat`)의 `mBytesPerPacket`과 `mFramesPerPacket` 설정 확인**
   - PCM의 경우 `mBytesPerPacket = mBytesPerFrame`, `mFramesPerPacket = 1`이어야 합니다.
   - 즉, `outputFormat.mBytesPerPacket = outputFormat.mBytesPerFrame = 4`로 설정되었는지 확인해야 합니다.
   - `outputFormat.mFramesPerPacket = 1`로 설정되어 있는지도 체크해야 합니다.

2. **패킷 크기 계산 수정**
   - `packetsPerBuffer` 계산 시 `sizePerPacket`이 아니라 `mBytesPerFrame`을 기준으로 해야 할 가능성이 있습니다.
   - 현재는 `packetsPerBuffer = outputBufferSize / sizePerPacket`로 계산했지만, `packetsPerBuffer = outputBufferSize / settings.outputFormat.mBytesPerFrame`로 바꾸어야 할 수 있습니다.

3. **`AudioFileWritePackets()` 호출 시 `inStartingPacket` 계산 수정**
   - `inStartingPacket = outputFilePacketPosition / settings.outputFormat.mBytesPerPacket` 대신,
   - `inStartingPacket = outputFilePacketPosition / (settings.outputFormat.mBytesPerFrame * settings.outputFormat.mFramesPerPacket)`로 설정하면 문제가 해결될 가능성이 큽니다.

---

### **수정 코드 예시**
다음과 같이 변경해 보시기 바랍니다.

```swift
fileprivate func convert(settings: inout AudioConverterSettings) {
  let outputBufferSize: UInt32 = 32 * 1024
  let sizePerPacket: UInt32 = settings.outputFormat.mBytesPerPacket
  let framesPerPacket: UInt32 = settings.outputFormat.mFramesPerPacket
  let bytesPerFrame: UInt32 = settings.outputFormat.mBytesPerFrame

  // 변경된 패킷 계산
  let packetsPerBuffer: UInt32 = outputBufferSize / bytesPerFrame
  print("Corrected packetsPerBuffer: \(packetsPerBuffer)")

  let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(outputBufferSize))
  var outputFilePacketPosition: UInt32 = 0

  while true {
    var convertedData = AudioBufferList(
      mNumberBuffers: 1,
      mBuffers: AudioBuffer(
        mNumberChannels: settings.outputFormat.mChannelsPerFrame,
        mDataByteSize: outputBufferSize,
        mData: outputBuffer
      )
    )

    var frameCount: UInt32 = packetsPerBuffer
    checkError("Couldn't read from input file") {
      ExtAudioFileRead(
        settings.inputFileRef!,
        &frameCount,
        &convertedData
      )
    }

    if frameCount == 0 {
      print("Done reading from file.")
      return
    }

    // 올바른 패킷 위치 계산
    let inStartingPacket = Int64(outputFilePacketPosition / bytesPerFrame)
    print("Writing packets at position: \(inStartingPacket), frameCount: \(frameCount)")

    checkError("Couldn't write packets to file") {
      AudioFileWritePackets(
        settings.outputFileID!,
        false,
        frameCount * bytesPerFrame,
        nil,
        inStartingPacket,
        &frameCount,
        convertedData.mBuffers.mData!
      )
    }

    outputFilePacketPosition += frameCount * bytesPerFrame
  }
}
```

이렇게 변경하면 `mBytesPerFrame`을 올바르게 반영하여 프레임 계산이 정확해지므로, 오디오 속도가 4배 빨라지는 문제가 해결될 가능성이 큽니다. 실행 후 로그를 확인하시고 다시 알려주시면 추가로 조정해 드리겠습니다.
