//
//  ToolSettingsView.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-25.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ToolSettingsView : NSView

@property (nonatomic, strong, readonly) NSNumber *baudRate;
@property (nonatomic, strong, readonly) NSNumber *feedRate;

@end
