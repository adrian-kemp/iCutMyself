//
//  DataPreparationViewController.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-14.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "DataPreparationViewController.h"

@interface DataPreparationViewController ()

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (unsafe_unretained) IBOutlet NSTextView *historyView;

@end

@implementation DataPreparationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)sendData:(id)sender {
    [self.delegate dataPreparationViewController:self wantsToSendString:self.textView.string];
    NSMutableString *historyString = [self.historyView.string mutableCopy];
    [historyString appendString:self.textView.string];
    [historyString appendString:@"\n"];
    self.historyView.string = [historyString copy];
    [self.historyView scrollToEndOfDocument:nil];
    self.textView.string = @"";
}

@end
