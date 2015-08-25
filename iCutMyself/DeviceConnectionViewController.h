//
//  DeviceConnectionViewController.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-07.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DeviceConnectionView.h"

@interface DeviceConnectionViewController : NSViewController

@property (atomic, strong) DeviceConnectionView *view;

- (void)writeString:(NSString *)string;

@end
