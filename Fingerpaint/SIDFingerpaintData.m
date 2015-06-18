//
//  SIDFingerpaintData.m
//  Fingerpaint
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "SIDFingerpaintData.h"

@interface SIDFingerpaintData ()
@end

NSString *const SIDPictureRedrawnNotification  = @"SIDPictureRedrawnNotification";
NSString *const SIDLineDataChangedNotification = @"SIDLineDataChangedNotification";
NSString *const SIDRecordButtonNotification    = @"SIDRecordButtonNotification";
NSString *const SIDEraseButtonNotification     = @"SIDEraseButtonNotification";

@implementation SIDFingerpaintData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineWidth    =   2.0;
        _alphaValue   =   1.0;
        _lineBright   = 100.0;
        _color        =   0;
        _lineStyle    =   0;
        _lineSpline   =   1;
        _maxPause     =   6;
        _maxPoints    =   3;
        _rectDisplay  =  NO;
        _minLineWidth =   0.5;
        _maxLineWidth =   2.0;
    }
    return self;
}

@end

