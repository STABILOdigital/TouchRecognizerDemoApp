//
//  SIDDetailViewController.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import <UIKit/UIKit.h>
#import "PaintViewData.h"
#import "PaintViewLine.h"
#import "SID_PulsedTouchRecognizer/SID_PulsedTouchRecognizer.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) PaintViewData *pvData;
@property (strong, nonatomic) PaintViewLine *linePresets;
@property (strong, nonatomic) SID_PulsedTouchRecognizer *tRec;
@property (assign, nonatomic) BOOL recording;

- (CGFloat) calculateFrameRate;
- (void) startRecording;
- (void) eraseButton;
- (void) setParameters:(NSUInteger)useCase;

@end

NSString *const SID_PenModeNotification;
NSString *const SID_LineEndedNotification;
NSString *const SID_RectNotification;
NSString *const SID_ParameterChangedNotification;
