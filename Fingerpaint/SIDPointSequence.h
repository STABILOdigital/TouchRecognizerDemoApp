//
//  SIDPointSequence.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 24.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIDPointSequence : NSArray
@property (assign, nonatomic) CGPoint point0;
@property (assign, nonatomic) CGPoint point1;
@property (assign, nonatomic) CGPoint point2;
@property (assign, nonatomic) CGPoint point3;
@property (assign, nonatomic) CGPoint point4;
@property (assign, nonatomic) NSUInteger numberOfPoints;
@end
