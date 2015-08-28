//
//  GCodeCommand.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-27.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCodeCommand : NSObject

@property (nonatomic, strong) NSNumber *positionX;
@property (nonatomic, strong) NSNumber *positionY;
@property (nonatomic, strong) NSNumber *positionZ;
@property (nonatomic, strong) NSNumber *feedRate;
@property (nonatomic, strong) NSString *commandString;

- (instancetype)initWithString:(NSString *)gcodeString;
- (NSNumber *)millisecondsToTransitFromCommand:(GCodeCommand *)command;

@end
