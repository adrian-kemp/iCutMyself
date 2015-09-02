//
//  GCodeAnalysisSummaryView.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-30.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GCodeAnalysisSummaryView : NSView

@property (nonatomic, assign) time_t estimatedCompletionTimeInMilliseconds;
@property (nonatomic, assign) unsigned long commandCount;

@end
