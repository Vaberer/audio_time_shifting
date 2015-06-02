//
//  ShiftModel.m
//  Audio Shift
//
//  Created by Patrik Vaberer on 5/27/15.
//  Copyright (c) 2015 Patrik Vaberer. All rights reserved.
//

#import "ShiftModel.h"
#import <AVFoundation/AVFoundation.h>
#include <Accelerate/Accelerate.h>


@implementation ShiftModel



static ShiftModel *shiftModel;
+ (id) s {
    if (shiftModel == nil)
        shiftModel = [[self alloc] init];
    return shiftModel;
    
}



+ (double)getTimeShiftFirstAudioURL:(NSURL *)audioURL1 secondAudio:(NSURL *)audioURL2 {
    
    if (audioURL1 == nil || audioURL2 == nil) {
        
        NSLog(@"%@", @"One of the audio files is nil");
        return DBL_MIN;

    }
    
    //    Record *longerRecord = myRecord.rDuration.floatValue > newRecord.rDuration.floatValue ? myRecord : newRecord;
    //
    //    //[self changeSampleRate:[H getURLFromString:longerRecord.rFileName]];
    //
    //    Record *shorterRecord = myRecord.rDuration.floatValue <= newRecord.rDuration.floatValue ? myRecord : newRecord;
    //
    
    //load first audio
    NSError *er = nil;
    AVAudioFile *myAudioFile1 = [[AVAudioFile alloc] initForReading:audioURL1 error:&er];
    if (er) {
        NSLog(@"%@", er.localizedDescription);
        return DBL_MIN;
    }
    
    
    
    
    
    //load second audio
    er = nil;
    AVAudioFile *myAudioFile2 = [[AVAudioFile alloc] initForReading:audioURL2 error:&er];
    if (er) {
        NSLog(@"%@", er.localizedDescription);
        return DBL_MIN;
    }
    
    
    
    //we compare longer audio against the shorter audio
    if (myAudioFile2.length / myAudioFile2.processingFormat.sampleRate > myAudioFile1.length / myAudioFile1.processingFormat.sampleRate) {
        
        AVAudioFile *t = myAudioFile1;
        myAudioFile1 = myAudioFile2;
        myAudioFile2 = t;
        
    }
    
    
    AVAudioFormat *myAudioFormat1 = myAudioFile1.processingFormat;
    UInt32 myAudioFrameCount1 = (UInt32)myAudioFile1.length - 1;
    
    AVAudioPCMBuffer *myAudioBuffer1 = [[AVAudioPCMBuffer alloc] initWithPCMFormat:myAudioFormat1 frameCapacity:myAudioFrameCount1];

    
    
    AVAudioFormat *myAudioFormat2 = myAudioFile2.processingFormat;
    UInt32 myAudioFrameCount2 = (UInt32)myAudioFile2.length - 1;
    AVAudioPCMBuffer *myAudioBuffer2 = [[AVAudioPCMBuffer alloc] initWithPCMFormat:myAudioFormat2 frameCapacity:myAudioFrameCount2];
    
    
    
    
    
    if (myAudioFormat1.sampleRate != myAudioFormat2.sampleRate) {
        
        NSLog(@"%@", @"Sample rate needs to be equal");
        return DBL_MIN;
    }
    int workingFrequency = myAudioFormat1.sampleRate;
    
    
    
    er = nil;
    [myAudioFile1 readIntoBuffer:myAudioBuffer1 error:&er];
    if (er) {
        NSLog(@"%@", er.localizedDescription);
        return DBL_MIN;
    }
    float *audioSample1 = myAudioBuffer1.floatChannelData[0];
    int bufferSize1 = myAudioBuffer1.frameLength;
    
    
    
    
    
    er = nil;
    [myAudioFile2 readIntoBuffer:myAudioBuffer2 error:&er];
    if (er) {
        NSLog(@"%@", er.localizedDescription);
        return DBL_MIN;
    }
    
    float *audioSample2 = myAudioBuffer2.floatChannelData[0];
    int bufferSize2 = myAudioBuffer2.frameLength;
    
    
    #define CUT_DOWN 50
    
    int buffer1PaddingCount = 0;
    while (audioSample1[buffer1PaddingCount] == 0 && ++buffer1PaddingCount < bufferSize1);
    
    int bufferSize1WithoutPadding = (bufferSize1 - buffer1PaddingCount) / CUT_DOWN;
    
    
    int buffer2PaddingCount = 0;
    while (audioSample1[buffer2PaddingCount] == 0 && ++buffer2PaddingCount < bufferSize2);
    
    int bufferSize2WithoutPadding = (bufferSize2 - buffer2PaddingCount) / CUT_DOWN;
    
    
    int32_t newBufferSize1 = (bufferSize1WithoutPadding + bufferSize2WithoutPadding * 2)  * sizeof(float);
    float *newBuffer1 = (float *)malloc( newBufferSize1  );
    memset(newBuffer1, 0, bufferSize2WithoutPadding * sizeof(float));
    
    
    float *shiftedBuffer1 = newBuffer1 + bufferSize2WithoutPadding;
    
    
    int tCounter = 0;
    for (int i = buffer1PaddingCount * 2; i < bufferSize1; i+= 1 * CUT_DOWN) {
        *shiftedBuffer1++ = audioSample1[i];
        tCounter++;
    }
    memset(shiftedBuffer1 , 0, bufferSize2WithoutPadding * sizeof(float));
    myAudioBuffer1 = nil;
    
    
    float *newBuffer2 = (float *)malloc(bufferSize2WithoutPadding * sizeof(float));
    
    
    
    int indexBuffer2 = 0;
    for (int i = buffer2PaddingCount * 2; i < bufferSize2; i+= 1 * CUT_DOWN ) {
        
        newBuffer2[indexBuffer2] = audioSample2[i];
        indexBuffer2++;
    }
    myAudioBuffer2 = nil;
    
    float *audio2Input, *audio1Input;
    float *resultInput;
    
    int32_t audio1Stride, audio2Stride, resultStride;
    uint32_t audio2Length, audio1Length, resultLength;
    
    audio1Length = bufferSize1WithoutPadding;
    audio1Stride = 1;
    audio1Input = newBuffer1;
    
    audio2Length = indexBuffer2;
    audio2Stride = 1;
    audio2Input = newBuffer2;
    
    resultInput = (float *)malloc(((audio1Length + audio2Length) / audio1Stride) * sizeof(float));
    resultLength = (int32_t)(audio1Length + (int32_t)audio2Length) / audio1Stride;
    resultStride = 1;
    
    
    vDSP_conv(audio1Input, audio1Stride, audio2Input, audio2Stride, resultInput, resultStride, resultLength, audio2Length);
    free(audio1Input);
    free(audio2Input);
    
    float max = FLT_MIN;
    int maxIndex = 0;
    for (int i = 0; i < resultLength; i++) {
        
        if (fabs(resultInput[i]) > max) {
            max = resultInput[i];
            maxIndex = i;
        }
    }
    free(resultInput);
    
    double timeShift = (float)(maxIndex - bufferSize2WithoutPadding + buffer2PaddingCount / CUT_DOWN) / (workingFrequency / CUT_DOWN);
    
    NSLog(@"The biggest match is %@ at the position: %@", @(max),@(maxIndex) );
    NSLog(@"Time shift is: %@ seconds", @(timeShift));
    
    return timeShift;
    
    
}

@end
