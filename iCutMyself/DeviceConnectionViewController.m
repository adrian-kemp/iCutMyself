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
#import "GCodeCommand.h"

@interface DeviceConnectionViewController () <DeviceConnectionViewDelegate, ToolSettingsViewControllerDelegate>

@property (nonatomic, strong) NSArray *devicePaths;
@property (nonatomic, assign) int fileDescriptor;
@property (nonatomic, assign) uint8_t *readBuffer;
@property (nonatomic, strong) NSTimer *readTimer;
@property (nonatomic, strong) NSMutableArray *commandsPendingConfirmation;
@property (nonatomic, strong) NSTimer *writeTimer;
@property (nonatomic, assign) unsigned long connectionSpeed;
@property (nonatomic, strong) NSMutableArray *commandBuffer;

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
    self.view.estimatedCompletionTime = 0;
    self.view.delegate = self;
    self.fileDescriptor = 0;
    self.readBuffer = malloc(sizeof(uint8_t) * BUFFER_SIZE);
    self.readTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(readFromDevice) userInfo:nil repeats:YES];
    self.commandBuffer = [NSMutableArray new];
    self.commandsPendingConfirmation = [NSMutableArray new];
    self.writeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(writeToDevice) userInfo:nil repeats:YES];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    
    self.view.devicePaths = self.devicePaths;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"popoverToolSettingsViewController"]) {
        [self.view finishBuildCameraRecording];
        ((ToolSettingsViewController *)segue.destinationController).delegate = self;
    }
}

- (void)beginNewBuildWithGCodeCommands:(NSArray *)gCodeCommands estimatedCompletionTimeInMilliseconds:(time_t)estimatedCompletionTimeInMilliseconds {
    [self.commandBuffer addObjectsFromArray:gCodeCommands];
    self.view.estimatedCompletionTime += estimatedCompletionTimeInMilliseconds;
    //start build camera
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *filePathString = [NSString stringWithFormat:@"%@/Build - %@.mov", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], [dateFormatter stringFromDate:[NSDate date]]];
    NSLog(@"beginning record to location: %@", [NSURL fileURLWithPath:filePathString]);
    [self.view startBuildCameraRecordingWithFilePath:[NSURL fileURLWithPath:filePathString]];
    
}

- (void)DeviceConnectionView:(DeviceConnectionView *)view didSelectDeviceAtIndex:(NSUInteger)index {
    NSString *devicePath = self.devicePaths[index];
    NSLog(@"selected device: %@", self.devicePaths[index]);
    
    //open the serial communication channel
    if (!self.connectionSpeed) {self.connectionSpeed = 9600;}
    self.fileDescriptor = OpenSerialConnectionToDeviceAtPath([devicePath cStringUsingEncoding:NSASCIIStringEncoding], self.connectionSpeed);
}

- (void)writeToDevice {
    if (self.fileDescriptor == 0 || self.commandsPendingConfirmation.count >= 10 || self.commandBuffer.count == 0) {
        return;
    }
    
    GCodeCommand *commandToSend = self.commandBuffer.firstObject;
    NSString *stringToSend = [NSString stringWithFormat:@"%@\n", commandToSend.commandString];
    if (!WriteDataToSerialModem((uint8_t *)[stringToSend cStringUsingEncoding:NSASCIIStringEncoding], stringToSend.length, self.fileDescriptor)) {
        NSLog(@"ERROR: Unsuccessful write!");
    } else {
        [self.commandsPendingConfirmation addObject:commandToSend];
        [self.commandBuffer removeObjectAtIndex:0];
        self.view.estimatedCompletionTime -= [commandToSend millisecondsToTransitFromCommand:self.commandBuffer.firstObject];
        self.view.bufferedCommandCount = self.commandBuffer.count;
        self.view.sentCommandCount++;
    }
}

- (void)readFromDevice {
    if (self.fileDescriptor == 0) {
        return;
    }
    if (ReadDataFromSerialModem(self.readBuffer, BUFFER_SIZE, self.fileDescriptor)) {
        NSString *readData = [NSString stringWithCString:(const char *)self.readBuffer encoding:NSASCIIStringEncoding];
        NSArray *responses = [readData componentsSeparatedByString:@"\n"];
        for (NSString *response in responses) {
            if ([response isEqualToString:@"ok"]) {
                [self.commandsPendingConfirmation removeObjectAtIndex:0];
                self.view.receivedCommandCount++;
            } else {
                NSLog(@"WARN: Response was not 'OK'");
            }
        }
    }
}

#pragma mark - ToolSettingsViewControllerDelegate

- (void)feedRateDidChange:(NSNumber *)feedRate {
    
}

- (void)baudRateDidChange:(NSNumber *)baudRate {
    self.connectionSpeed = baudRate.longValue;
}

@end
