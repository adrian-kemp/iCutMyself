//
//  GCodeAnalysisSummaryView.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-30.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "GCodeAnalysisSummaryView.h"

@interface GCodeAnalysisSummaryView ()

@property (weak) IBOutlet NSTextField *estimatedCompletionTimeLabel;
@property (weak) IBOutlet NSTextField *commandCountLabel;

@end

@implementation GCodeAnalysisSummaryView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setEstimatedCompletionTimeInMilliseconds:(time_t)estimatedCompletionTimeInMilliseconds {
    _estimatedCompletionTimeInMilliseconds = estimatedCompletionTimeInMilliseconds;
    self.estimatedCompletionTimeLabel.stringValue = [NSString stringWithFormat:@"%.2fs", (estimatedCompletionTimeInMilliseconds / 1000.0f)];
}

- (void)setCommandCount:(unsigned long)commandCount {
    _commandCount = commandCount;
    self.commandCountLabel.stringValue = [NSString stringWithFormat:@"%lu", commandCount];
}

@end
