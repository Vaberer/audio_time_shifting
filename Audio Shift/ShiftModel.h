//
//  ShiftModel.h
//  Audio Shift
//
//  Created by Patrik Vaberer on 5/27/15.
//  Copyright (c) 2015 Patrik Vaberer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_CLASS_AVAILABLE_IOS(8_0) @interface ShiftModel : NSObject

/**
 Process the cross-corelation to determine time shift between two audio files.
 Sample rate and file format must be equal.
 @param audioURL1 First audio file
 @param audioURL2 Second audio file
 @return Time shift in seconds. If the vaule is DBL_MIN, it could not find out the time shift.
 */
+ (double)getTimeShiftFirstAudioURL:(NSURL *)audioURL1 secondAudio:(NSURL *)audioURL2;

@end
