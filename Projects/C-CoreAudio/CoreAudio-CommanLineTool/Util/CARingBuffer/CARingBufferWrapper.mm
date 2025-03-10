//
//  Untitled.h
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/10/25.
//

#import "CARingBufferWrapper.h"
#import "CARingBuffer.h"

@interface CARingBufferWrapper () {
  CARingBuffer *ringBuffer;
}

@end

@implementation CARingBufferWrapper

- (instancetype)initWithChannels:(int)nChannels bytesPerFrame:(UInt32)bytesPerFrame capacityFrames:(UInt32)capacityFrames {
  self = [super init];
  if (self) {
    ringBuffer = new CARingBuffer();
    ringBuffer->Allocate(nChannels, bytesPerFrame, capacityFrames);
  }
  return self;
}

- (void)deallocateBuffer {
  if (ringBuffer) {
    ringBuffer->Deallocate();
    delete ringBuffer;
    ringBuffer = nullptr;
  }
}

- (BOOL)storeAudioBufferList:(const AudioBufferList *)abl
                    nFrames:(UInt32)nFrames
                frameNumber:(SInt64)frameNumber {
  if (!ringBuffer) return NO;
  return ringBuffer->Store(abl, nFrames, frameNumber) == kCARingBufferError_OK;
}

- (BOOL)fetchAudioBufferList:(AudioBufferList *)abl
                     nFrames:(UInt32)nFrames
                 frameNumber:(SInt64)frameNumber {
  if (!ringBuffer) return NO;
  return ringBuffer->Fetch(abl, nFrames, frameNumber) == kCARingBufferError_OK;
}

- (BOOL)getTimeBoundsStartTime:(SInt64 *)startTime
                      endTime:(SInt64 *)endTime {
  if (!ringBuffer || !startTime || !endTime) return NO;
  return ringBuffer->GetTimeBounds(*startTime, *endTime) == kCARingBufferError_OK;
}

- (void)dealloc {
  [self deallocateBuffer];
  // [super dealloc];
}

@end
