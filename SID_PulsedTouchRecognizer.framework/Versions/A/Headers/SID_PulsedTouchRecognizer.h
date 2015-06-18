//
//  SID_PulsedTouchRecognizer.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 04.09.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 28, 2015
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SID_PulsedTouchRecognizer : UIGestureRecognizer

// Variable properties for adaption to usage type
// (set in setParameters: in ViewController)

// Lower limit of the pen speed to be considered for averaging
@property (assign, nonatomic) double        minimumSpeed;

// Factor between the averaged speed and the upper speed limit
@property (assign, nonatomic) double        speedLimitFactor;

// Maximum error limit to make a final decision on pen mode
@property (assign, nonatomic) double        penModeErrorLimit;

// Minimum score before a sequence is declared a pen line
@property (assign, nonatomic) unsigned long minTrustedScore;

@property (assign, nonatomic) unsigned long maxOffTimeFactor;
@property (assign, nonatomic) NSInteger     useCase;
@property (assign, nonatomic) double        xMarginForHitTesting;
@property (assign, nonatomic) double        yMarginForHitTesting;

// Speed of previous or ongoing line
@property (assign, nonatomic) CGFloat        lineSpeed;

// Limit time between lines of the same penMode
@property (assign, nonatomic) NSTimeInterval timeBetweenSameLines;

// Added for display in the demo app; gets removed for the SDK
@property (assign, nonatomic) NSInteger score;
@property (assign, nonatomic) BOOL      radiusCheckAvailable;

- (instancetype)   initInView:(UIView *)view;
- (void)           reset;
- (void)           SID_touchesBegan:(NSSet *)touches;
- (void)           SID_touchesMoved:(NSSet *)touches;
- (void)           SID_touchesCancelled:(NSSet *)touches;
- (NSDictionary *) SID_touchesEnded:(NSSet *)touches;
- (void)           SID_changeView:(UIView *)view;
- (BOOL)           canPreventGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (BOOL)           canBePreventedByGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)           SID_cleanUp;
@end

extern NSString *const SID_PenModeNotification;
extern NSString *const SID_LineEndedNotification;
extern NSString *const SID_RectNotification;
