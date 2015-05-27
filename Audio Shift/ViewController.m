//
//  ViewController.m
//  Audio Shift
//
//  Created by Patrik Vaberer on 5/27/15.
//  Copyright (c) 2015 Patrik Vaberer. All rights reserved.
//

#import "ViewController.h"
#import "ShiftModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *audioURL1 = [[NSBundle mainBundle] URLForResource:@"audio2" withExtension:@"m4a"];
    NSURL *audioURL2 = [[NSBundle mainBundle] URLForResource:@"audio1" withExtension:@"m4a"];;

    
    [ShiftModel getTimeShiftFirstAudioURL:audioURL1 secondAudio:audioURL2];
    
    
}



@end
