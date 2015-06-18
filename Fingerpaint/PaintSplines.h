//
//  Splines.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 11.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import "PaintViewData.h"
#import "PaintViewLine.h"

@interface PaintSplines : NSObject

- (instancetype) initWithData:(PaintViewData *)data;
- (CGFloat) distanceBetween:(CGPoint)p1 and:(CGPoint)p2;
- (NSMutableArray *) splineIncrement:(NSArray *)lineIncr
                             forLine:(PaintViewLine *)newLine;
- (void) addLastPointToPath:(CGMutablePathRef)path
                 fromPoints:(NSArray *)points
          withExtrapolation:(BOOL)extra;
- (CGPoint) getPointAtIndex:(NSUInteger)index ofLine:(NSArray *)line;
- (NSTimeInterval) getTimeAtIndex:(NSUInteger)index ofLine:(NSArray *)line;
- (NSTimeInterval) getFirstTimeOfLine:(NSArray *)line;
- (NSTimeInterval) getLastTimeOfLine:(NSArray *)line;

@end
