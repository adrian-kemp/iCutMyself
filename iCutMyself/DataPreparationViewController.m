//
//  DataPreparationViewController.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-14.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "DataPreparationViewController.h"
#import "GCodeAnalysisSummaryViewController.h"
#import "GCodeCommand.h"

@interface DataPreparationViewController () <GCodeAnalysisSummaryViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray *gCodeCommands;

@end

@implementation DataPreparationViewController
@dynamic view;
@synthesize estimatedCompletionTimeInMilliseconds=_estimatedCompletionTimeInMilliseconds;
@synthesize commandCount=_commandCount;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.gCodeCommands = [NSMutableArray new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.delegate = self;
    // Do view setup here.
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"popoverGCodeAnalysisSummaryViewController"]) {
        ((GCodeAnalysisSummaryViewController *)segue.destinationController).dataSource = self;
    }
}

#pragma mark - DataPreparationViewDelegate selectors
- (void)editingDidFinishWithGCodeString:(NSString *)gCodeString {
    [self.view setMode:DataPreparationViewModeAnalyzing];
    self.estimatedCompletionTimeInMilliseconds = 0;
    self.commandCount = 0;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        time_t estimatedCompletionTimeInMilliseconds = 0;
        unsigned long commandCount = 0;
        NSArray *commandStrings = [gCodeString componentsSeparatedByString:@"\n"];
        GCodeCommand *lastCommand = weakSelf.gCodeCommands.lastObject;
        for (NSString *commandString in commandStrings) {
            GCodeCommand *command = [[GCodeCommand alloc] initWithString:commandString];
            [weakSelf.gCodeCommands addObject:command];
            time_t timeForCommand = [command millisecondsToTransitFromCommand:lastCommand];
            estimatedCompletionTimeInMilliseconds += timeForCommand;
            commandCount++;
            lastCommand = command;
        }
        weakSelf.estimatedCompletionTimeInMilliseconds = estimatedCompletionTimeInMilliseconds;
        weakSelf.commandCount = commandCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view setMode:DataPreparationViewModeConfirm];
            [weakSelf performSegueWithIdentifier:@"popoverGCodeAnalysisSummaryViewController" sender:self];
        });
    });
}

- (void)commitPreviouslyAnalyzedGCode {
    NSLog(@"sending %lu commands to device", self.gCodeCommands.count);
    [self.delegate sendDeviceGCodeCommands:[self.gCodeCommands copy] withEstimatedCompletionTimeInMilliseconds:self.estimatedCompletionTimeInMilliseconds];

}

@end
