//
//  PaintView.h
//  PaintingSample
//
//  Created by Peter Kämpf on 04.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import <UIKit/UIKit.h>
#import "PaintSplines.h"
#import "PaintViewData.h"
#import "PaintViewLine.h"

@interface PaintView : UIView

@property (strong, nonatomic) NSMutableDictionary *linesDict;
@property (strong, nonatomic) PaintViewData *pvData;
@property (strong, nonatomic) PaintSplines *splinefunc;
@property (assign, nonatomic) CGRect clipRect;
@property (assign, nonatomic) CGAffineTransform flipTransform, scaleTransform;

- (instancetype) initWithFrame:(CGRect)frame andData:(PaintViewData *)data;
- (void) clearScreen;
- (UIColor *)lineColorFor:(PaintViewLine *)line;
- (void) addPath:(CGPathRef)path with:(PaintViewLine *)line;
- (void) drawGreenRect:(CGRect)enclosingRect andRedRect:(CGRect)palmRect;
@end
