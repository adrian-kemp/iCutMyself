//
//  DataPreparationView.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-28.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <AppKit/AppKit.h>

typedef enum {
    DataPreparationViewModeEdit,
    DataPreparationViewModeConfirm,
    DataPreparationViewModeAnalyzing,
} DataPreparationViewMode;

@protocol DataPreparationViewDelegate <NSObject>

- (void)editingDidFinishWithGCodeString:(NSString *)gCodeString;
- (void)commitPreviouslyAnalyzedGCode;

@end

@interface DataPreparationView : NSView

@property (nonatomic, weak) id <DataPreparationViewDelegate>delegate;
@property (nonatomic, assign) DataPreparationViewMode mode;

@end
