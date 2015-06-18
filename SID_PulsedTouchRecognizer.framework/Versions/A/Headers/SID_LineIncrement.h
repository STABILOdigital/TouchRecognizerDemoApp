//
//  SID_LineIncrement.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 25.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "SID_privateTouch.h"
#import "SID_Stroke.h"

@interface SID_LineIncrement : NSObject

@property (strong, nonatomic) NSArray * touches;      // Newly added constituents of the line.
@property (assign, nonatomic) NSTimeInterval lastTimestamp;

- (instancetype) initWithStroke:(SID_Stroke *)stroke;
- (NSTimeInterval) getFirstTime;
- (NSTimeInterval) getOnTime;

@end
