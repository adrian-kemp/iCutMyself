//
//  GCodeCommand.m
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-27.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import "GCodeCommand.h"

typedef enum {
    GCodeComponentMoveX,
    GCodeComponentMoveY,
    GCodeComponentMoveZ,
    GCodeComponentFeedRate,
    GCodeComponentCount,
} GCodeComponent;

@interface GCodeCommand ()

@property (nonatomic, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, readonly) NSArray *regularExpressionsByComponent;

@end

@implementation GCodeCommand
@synthesize numberFormatter=_numberFormatter;
@synthesize regularExpressionsByComponent=_regularExpressionsByComponent;

+ (instancetype)zeroCommand {
    static GCodeCommand *zeroCommand;
    if (!zeroCommand) {
        zeroCommand = [[self alloc] initWithString:@"G1 X0 Y0 Z0 F100"];
    }
    return zeroCommand;
}

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [NSNumberFormatter new];
    }
    return _numberFormatter;
}

- (NSArray *)regularExpressionsByComponent {
    if (!_regularExpressionsByComponent) {
        NSError *error;
        NSMutableArray *regularExpressionsByComponent = [NSMutableArray new];
        [regularExpressionsByComponent addObject:[NSRegularExpression regularExpressionWithPattern:@"X(\\d*)" options:0 error:&error]];
        [regularExpressionsByComponent addObject:[NSRegularExpression regularExpressionWithPattern:@"Y(\\d*)" options:0 error:&error]];
        [regularExpressionsByComponent addObject:[NSRegularExpression regularExpressionWithPattern:@"Z(\\d*)" options:0 error:&error]];
        [regularExpressionsByComponent addObject:[NSRegularExpression regularExpressionWithPattern:@"F(\\d*)" options:0 error:&error]];
        _regularExpressionsByComponent = [regularExpressionsByComponent copy];
    }
    return _regularExpressionsByComponent;
}

- (NSNumber *)numberForGCodeComponent:(GCodeComponent)component inString:(NSString *)gcodeString  {
    NSRange stringRange = NSMakeRange(0, gcodeString.length);
    NSTextCheckingResult *match = [self.regularExpressionsByComponent[component] firstMatchInString:gcodeString options:0 range:stringRange];
    if (match.numberOfRanges != 2) {
        return nil;
    }
    return [self.numberFormatter numberFromString:[gcodeString substringWithRange:[match rangeAtIndex:1]]];
}

- (instancetype)initWithString:(NSString *)gcodeString {
    self = [super init];

    self.commandString = gcodeString;
    self.positionX = [self numberForGCodeComponent:GCodeComponentMoveX inString:gcodeString];
    self.positionY = [self numberForGCodeComponent:GCodeComponentMoveY inString:gcodeString];
    self.positionZ = [self numberForGCodeComponent:GCodeComponentMoveZ inString:gcodeString];
    self.feedRate = [self numberForGCodeComponent:GCodeComponentFeedRate inString:gcodeString];
    if (!self.feedRate) {
        self.feedRate = @(100);
    }
    
    return self;
}

- (NSNumber *)millisecondsToTransitFromCommand:(GCodeCommand *)command {
    if (!command) {
        command = [GCodeCommand zeroCommand];
    }
    float deltaX = self.positionX.floatValue - command.positionX.floatValue;
    float deltaY = self.positionY.floatValue - command.positionY.floatValue;
    float deltaZ = self.positionZ.floatValue - command.positionZ.floatValue;
    float millisecondsForTransit = (sqrt(deltaX*deltaX + deltaY*deltaY + deltaZ*deltaZ) / (self.feedRate.floatValue / 60)) * 1000;
    
    return @(millisecondsForTransit);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@, %@, %@) @ %@mm/min", self.positionX, self.positionY, self.positionZ, self.feedRate];
}

@end
