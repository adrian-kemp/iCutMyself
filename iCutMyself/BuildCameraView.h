//
//  BuildCameraView.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-30.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BuildCameraView : NSView

- (void)beginRecordingToFileAtPath:(NSURL *)filePath;
- (void)finishRecording;

@end
