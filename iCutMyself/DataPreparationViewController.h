//
//  DataPreparationViewController.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-14.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DataPreparationViewController;

@protocol DataPreparationViewControllerDelegate <NSObject>

- (void)dataPreparationViewController:(DataPreparationViewController *)controller wantsToSendString:(NSString *)string;

@end

@interface DataPreparationViewController : NSViewController

@property (nonatomic, weak) id <DataPreparationViewControllerDelegate> delegate;


@end
