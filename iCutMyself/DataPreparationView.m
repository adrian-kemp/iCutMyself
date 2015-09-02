//
//  DataPreparationView.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-28.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "DataPreparationView.h"
#import "GCodeCommand.h"

@interface DataPreparationView () <NSTextViewDelegate>

@property (nonatomic, strong) NSMutableArray *gCodeCommands;
@property (nonatomic, assign) BOOL inputHasChanged;
@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *historyTextView;
@property (unsafe_unretained) IBOutlet NSButton *commitInputButton;

@end

@implementation DataPreparationView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.inputTextView.delegate = self;
}

- (void)setMode:(DataPreparationViewMode)mode {
    switch (mode) {
        case DataPreparationViewModeEdit:
            [self.inputTextView setEditable:YES];
            [self.commitInputButton setEnabled:YES];
            [self.commitInputButton setTitle:@"Analyze"];
            break;
            case DataPreparationViewModeConfirm:
            [self.inputTextView setEditable:YES];
            [self.commitInputButton setEnabled:YES];
            [self.commitInputButton setTitle:@"Send To Device"];
            break;
        case DataPreparationViewModeAnalyzing:
        default:
            [self.inputTextView setEditable:NO];
            [self.commitInputButton setEnabled:NO];
            [self.commitInputButton setTitle:@"Busy"];
            break;
    }
    _mode = mode;
}

- (IBAction)commitInputButtonDidRecieveClick:(NSButton *)commitInputButton {
    switch (self.mode) {
        case DataPreparationViewModeEdit:
            [self.delegate editingDidFinishWithGCodeString:self.inputTextView.string];
            break;
        case DataPreparationViewModeConfirm:
            self.historyTextView.string = [NSString stringWithFormat:@"%@%@",self.historyTextView.string, self.inputTextView.string];
            [self.historyTextView scrollToEndOfDocument:self];
            [self.inputTextView setString:@""];
            [self.delegate commitPreviouslyAnalyzedGCode];
        case DataPreparationViewModeAnalyzing:
        default:
            break;
    }
}

#pragma mark - NSTextFieldDelegate selectors
- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    if (self.mode == DataPreparationViewModeConfirm) {
        self.mode = DataPreparationViewModeEdit;
    }

    return YES;
}

@end
