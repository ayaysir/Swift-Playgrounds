//
//  PrintAudioDescription.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/5/25.
//

import AudioToolbox

func printAudioDescription(_ format: AudioStreamBasicDescription, label: String) {
    print("\n=== \(label) ===")
    print("Sample Rate: \(format.mSampleRate)")
    print("Channels: \(format.mChannelsPerFrame)")
    print("Bits Per Channel: \(format.mBitsPerChannel)")
    print("Bytes Per Packet: \(format.mBytesPerPacket)")
    print("Frames Per Packet: \(format.mFramesPerPacket)")
    print("Bytes Per Frame: \(format.mBytesPerFrame)")
    print("Format ID: \(format.mFormatID)")
    print("Format Flags: \(format.mFormatFlags)")
    print("===============\n")
}
