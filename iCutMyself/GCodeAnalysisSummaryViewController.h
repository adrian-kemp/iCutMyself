//
//  GCodeAnalysisSummaryViewController.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-30.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCodeAnalysisSummaryView.h"

@protocol GCodeAnalysisSummaryViewControllerDataSource <NSObject>

@property time_t estimatedCompletionTimeInMilliseconds;
@property unsigned long commandCount;

@end

@interface GCodeAnalysisSummaryViewController : NSViewController

@property GCodeAnalysisSummaryView *view;
@property (nonatomic, weak) id <GCodeAnalysisSummaryViewControllerDataSource> dataSource;

@end
