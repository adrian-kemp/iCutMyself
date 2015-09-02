//
//  DataPreparationViewController.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-14.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataPreparationView.h"

@class DataPreparationViewController;

@protocol DataPreparationViewControllerDelegate <NSObject>

- (void)sendDeviceGCodeCommands:(NSArray *)gCodeCommands withEstimatedCompletionTimeInMilliseconds:(time_t)estimatedCompletionTimeInMilliseconds;

@end

@interface DataPreparationViewController : NSViewController <DataPreparationViewDelegate>
@property DataPreparationView *view;
@property (nonatomic, weak) id <DataPreparationViewControllerDelegate> delegate;


@end
