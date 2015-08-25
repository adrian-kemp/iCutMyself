//
//  DeviceConnectionViewController.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-07.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#define BUFFER_SIZE 1024

#import "SerialCommunication.h"
#import "DeviceConnectionViewController.h"
#import "ToolSettingsViewController.h"

@interface DeviceConnectionViewController () <DeviceConnectionViewDelegate, ToolSettingsViewControllerDelegate>

@property (nonatomic, strong) NSArray *devicePaths;
@property (nonatomic, assign) int fileDescriptor;
@property (nonatomic, assign) uint8_t *readBuffer;
@property (nonatomic, strong) NSTimer *readTimer;
@property (nonatomic, strong) NSMutableArray *commandBuffer;
@property (nonatomic, strong) NSTimer *writeTimer;
@property (nonatomic, assign) NSUInteger commandsPendingConfirmation;

@end

@implementation DeviceConnectionViewController
@dynamic view;

- (NSArray *)devicePaths {
    if (!_devicePaths) {
        _devicePaths = (__bridge NSArray *)getSerialModemList();
    }
    return _devicePaths;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.delegate = self;
    self.fileDescriptor = 0;
    self.readBuffer = malloc(sizeof(uint8_t) * BUFFER_SIZE);
    self.readTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(readFromDevice) userInfo:nil repeats:YES];
    self.commandBuffer = [NSMutableArray new];
    self.writeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(writeToDevice) userInfo:nil repeats:YES];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    
    self.view.devicePaths = self.devicePaths;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"popoverToolSettingsViewController"]) {
        ((ToolSettingsViewController *)segue.destinationController).delegate = self;
    }
}

- (void)DeviceConnectionView:(DeviceConnectionView *)view didSelectDeviceAtIndex:(NSUInteger)index {
    NSString *devicePath = self.devicePaths[index];
    NSLog(@"selected device: %@", self.devicePaths[index]);
    
    //open the serial communication channel
    self.fileDescriptor = OpenSerialConnectionToDeviceAtPath([devicePath cStringUsingEncoding:NSASCIIStringEncoding]);
}

- (void)writeString:(NSString *)string {
    //break the string by new line
    NSArray *commands = [string componentsSeparatedByString:@"\n"];
    
    //add commands to buffer
    [self.commandBuffer addObjectsFromArray:commands];
    
    self.view.bufferedCommandCount = self.commandBuffer.count;
}

- (void)writeToDevice {
    if (self.fileDescriptor == 0 || self.commandsPendingConfirmation >= 10 || self.commandBuffer.count == 0) {
        return;
    }
    
    NSString *commandToSend = [NSString stringWithFormat:@"%@\n", self.commandBuffer.firstObject];
    self.commandsPendingConfirmation++;
    if (!WriteDataToSerialModem([commandToSend cStringUsingEncoding:NSASCIIStringEncoding], commandToSend.length, self.fileDescriptor)) {
        NSLog(@"ERROR: Unsuccessful write!");
        self.commandsPendingConfirmation--;
    } else {
        [self.commandBuffer removeObjectAtIndex:0];
        self.view.bufferedCommandCount = self.commandBuffer.count;
        self.view.sentCommandCount++;
    }
}

- (void)readFromDevice {
    if (self.fileDescriptor == 0) {
        return;
    }
    if (ReadDataFromSerialModem(self.readBuffer, BUFFER_SIZE, self.fileDescriptor)) {
        NSString *readData = [NSString stringWithCString:self.readBuffer encoding:NSASCIIStringEncoding];
        NSArray *responses = [readData componentsSeparatedByString:@"\n"];
        for (NSString *response in responses) {
            NSLog(@"[response]: %@", response);
            if ([response isEqualToString:@"ok"]) {
                self.commandsPendingConfirmation--;
                self.view.receivedCommandCount++;
            }
        }
    }
}

#pragma mark - ToolSettingsViewControllerDelegate

- (void)feedRateDidChange:(NSNumber *)feedRate {
    
}

- (void)baudRateDidChange:(NSNumber *)baudRate {
    NSLog(@"baud rate changed to: %@", baudRate);
}

@end
