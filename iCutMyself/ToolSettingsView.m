//
//  ToolSettingsView.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-25.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "ToolSettingsView.h"

@interface ToolSettingsView ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *baudRateSelectionButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *feedRateSelectionButton;

@end

@implementation ToolSettingsView

- (NSNumber *)numberFromStringSelection:(NSString *)stringSelection {
    return [[NSNumberFormatter new] numberFromString:stringSelection];
}

- (NSNumber *)baudRate {
    return [self numberFromStringSelection:self.baudRateSelectionButton.selectedItem.title];
}

- (NSNumber *)feedRate {
    return [self numberFromStringSelection:self.baudRateSelectionButton.selectedItem.title];
}

@end
