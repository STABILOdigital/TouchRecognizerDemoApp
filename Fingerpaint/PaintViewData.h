//
//  lineData.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 21.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import <Foundation/Foundation.h>

@interface PaintViewData : NSMutableData

// These variables can be set with the control subview,
@property (assign, nonatomic) NSUInteger usageMode;
@property (assign, nonatomic) BOOL       pinchAndPan;
@property (assign, nonatomic) BOOL       touchRadius;
@property (assign, nonatomic) BOOL       rectDisplay;

// and these stay as they are:
@property (assign, nonatomic) CGFloat    minLineWidth;
@property (assign, nonatomic) CGFloat    maxLineWidth;
@property (assign, nonatomic) NSUInteger maxSplinePoints;

- (instancetype) init;

@end
