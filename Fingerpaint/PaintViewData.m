//
//  lineData.m
//  Fingerpaint
//
//  Created by Peter Kämpf on 21.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import "PaintViewData.h"

// Data object to ease communication between viewControllers and between them and their view.

@implementation PaintViewData

- (instancetype) init {
    self = [super init];
    if (self) {
        _minLineWidth    =  0.5;
        _maxLineWidth    =  2.0;
        _maxSplinePoints =  5;
        _usageMode       =  0;
        _pinchAndPan     = NO;
        _touchRadius     = YES;
        _rectDisplay     = YES;
    }
    return self;
}

@end