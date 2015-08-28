//
//  DeviceConnectionView.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-07.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "DeviceConnectionView.h"

@interface DeviceConnectionView ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *deviceSelectionButton;
@property (weak) IBOutlet NSTextField *commandStatusTextField;
@property (weak) IBOutlet NSTextField *estimatedCompletionTimeTextField;
@property (weak) IBOutlet NSProgressIndicator *processingProgressIndicator;

@end

@implementation DeviceConnectionView

- (void)setDevicePaths:(NSArray *)devicePaths {
    [self.deviceSelectionButton addItemsWithTitles:devicePaths];
}


- (IBAction)popupButtonDidChangeValue:(NSPopUpButton *)sender {
    NSUInteger selectedIndex = [sender.itemArray indexOfObject:sender.selectedItem] - 1;
    [self.delegate DeviceConnectionView:self didSelectDeviceAtIndex:selectedIndex];
}

- (void)setSentCommandCount:(NSUInteger)sentCommandCount {
    _sentCommandCount = sentCommandCount;
    [self updateCommandStatus];
}

- (void)setReceivedCommandCount:(NSUInteger)receivedCommandCount {
    _receivedCommandCount = receivedCommandCount;
    [self updateCommandStatus];
}

- (void)setBufferedCommandCount:(NSUInteger)bufferedCommandCount {
    _bufferedCommandCount = bufferedCommandCount;
    [self updateCommandStatus];
}

- (void)updateCommandStatus {
    self.commandStatusTextField.stringValue = [NSString stringWithFormat:@"TX/RX [%lu/%lu] Buffered [%lu]", self.sentCommandCount, self.receivedCommandCount, self.bufferedCommandCount];
    self.processingProgressIndicator.doubleValue = ((float)self.receivedCommandCount)  /(((float)self.bufferedCommandCount) + ((float)self.sentCommandCount));
}

- (void)setEstimatedCompletionTime:(float)estimatedCompletionTime {
    _estimatedCompletionTime = estimatedCompletionTime;
    self.estimatedCompletionTimeTextField.stringValue = [NSString stringWithFormat:@"ECT: %.2fs", estimatedCompletionTime/1000];
}

@end
