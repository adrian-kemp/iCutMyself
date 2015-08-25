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

@end

@implementation DataPreparationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)sendData:(id)sender {
    [self.delegate dataPreparationViewController:self wantsToSendString:self.textView.string];
    self.textView.string = @"";
}

@end