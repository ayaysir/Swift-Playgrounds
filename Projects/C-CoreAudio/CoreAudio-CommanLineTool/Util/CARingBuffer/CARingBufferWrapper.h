//
//  CARingBufferWrapper.h
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/10/25.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface CARingBufferWrapper : NSObject

- (instancetype)initWithChannels:(int)nChannels bytesPerFrame:(UInt32)bytesPerFrame capacityFrames:(UInt32)capacityFrames;
- (void)deallocateBuffer;

- (BOOL)storeAudioBufferList:(const AudioBufferList *)abl
                    nFrames:(UInt32)nFrames
                frameNumber:(SInt64)frameNumber;

- (BOOL)fetchAudioBufferList:(AudioBufferList *)abl
                     nFrames:(UInt32)nFrames
                 frameNumber:(SInt64)frameNumber;

- (BOOL)getTimeBoundsStartTime:(SInt64 *)startTime
                      endTime:(SInt64 *)endTime;

@end

NS_ASSUME_NONNULL_END
