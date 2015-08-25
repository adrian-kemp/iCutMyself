//
//  ToolSettingsViewController.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-25.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolSettingsView.h"

@protocol ToolSettingsViewControllerDelegate <NSObject>

- (void)feedRateDidChange:(NSNumber *)feedRate;
- (void)baudRateDidChange:(NSNumber *)baudRate;

@end

@interface ToolSettingsViewController : NSViewController

@property (atomic, strong) ToolSettingsView *view;
@property (nonatomic, weak) id <ToolSettingsViewControllerDelegate> delegate;

@end
