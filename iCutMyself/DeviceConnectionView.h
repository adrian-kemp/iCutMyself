//
//  DeviceConnectionView.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-07.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DeviceConnectionView;

@protocol DeviceConnectionViewDelegate <NSObject>

- (void)DeviceConnectionView:(DeviceConnectionView *)view didSelectDeviceAtIndex:(NSUInteger)index;

@end

@interface DeviceConnectionView : NSView

@property (nonatomic, weak) id <DeviceConnectionViewDelegate> delegate;
@property (nonatomic, strong) NSArray *devicePaths;
@property (nonatomic, assign) NSUInteger sentCommandCount;
@property (nonatomic, assign) NSUInteger receivedCommandCount;
@property (nonatomic, assign) NSUInteger bufferedCommandCount;
@property (nonatomic, assign) float estimatedCompletionTime;

@end
