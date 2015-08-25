//
//  CommunicationViewController.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-14.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "CommunicationViewController.h"
#import "DataPreparationViewController.h"
#import "DeviceConnectionViewController.h"

@interface CommunicationViewController () <DataPreparationViewControllerDelegate>

@property (nonatomic, weak) DataPreparationViewController *dataPreparationViewController;
@property (nonatomic, weak) DeviceConnectionViewController *deviceConnectionViewController;

@end

@implementation CommunicationViewController

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedDataPreparationViewController"]) {
        self.dataPreparationViewController = segue.destinationController;
        self.dataPreparationViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"embedDeviceConnectionViewController"]) {
        self.deviceConnectionViewController = segue.destinationController;
    }
}

- (void)dataPreparationViewController:(DataPreparationViewController *)controller wantsToSendString:(NSString *)string {
    [self.deviceConnectionViewController writeString:string];
}

@end
