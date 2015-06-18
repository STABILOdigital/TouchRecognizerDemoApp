//
//  SID_TouchInstance.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 17.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 28, 2015
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SID_Touch : NSObject

@property (assign, nonatomic) NSTimeInterval timestamp;    // When was the touch recorded?
@property (assign, nonatomic) CGPoint        point;        // Where was the touch recorded?
@property (assign, nonatomic) CGFloat        distance;     // distance to previous touch in pixels.
@property (assign, nonatomic) CGFloat        speed;        // speed from previous touch in pix/s.

@end
