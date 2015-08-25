//
//  ToolSettingsViewController.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-25.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "ToolSettingsViewController.h"

@implementation ToolSettingsViewController
@dynamic view;

- (IBAction)baudRateDidChange:(id)sender {
    [self.delegate baudRateDidChange:self.view.baudRate];
}

@end
