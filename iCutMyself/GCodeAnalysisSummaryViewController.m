//
//  GCodeAnalysisSummaryViewController.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-30.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "GCodeAnalysisSummaryViewController.h"

@interface GCodeAnalysisSummaryViewController ()

@end

@implementation GCodeAnalysisSummaryViewController
@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.view.estimatedCompletionTimeInMilliseconds = self.dataSource.estimatedCompletionTimeInMilliseconds;
    self.view.commandCount = self.dataSource.commandCount;
}

@end
