//
//  Splines.m
//  Fingerpaint
//
//  Created by Peter Kämpf on 11.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import "PaintSplines.h"
#import "SID_PulsedTouchRecognizer/SID_Touch.h"

@interface PaintSplines ()
@property (strong, nonatomic) PaintViewData *pvData;
@end

@implementation PaintSplines

#pragma mark - Initialization and helper methods

- (instancetype) initWithData:(PaintViewData *)data {
    self        = [super init];
    self.pvData = data;

    return self;
}

// Calculate the distance between two points.

- (CGFloat) distanceBetween:(CGPoint)p1 and:(CGPoint)p2 {

//    CGFloat dx = p1.x - p2.x;
//    CGFloat dy = p1.y - p2.y;
//    return sqrt(dx*dx + dy*dy);
    return fabs(p1.x - p2.x) + fabs(p1.y - p2.y);
}

#pragma mark - Spline drawing

- (NSMutableArray *) splineIncrement:(NSArray *)lineIncr
                             forLine:(PaintViewLine *)newLine {

// Get the points from the newLine and the lineIncr:
    NSUInteger incrLength  = [lineIncr count];
    NSUInteger startIndex  = newLine.length - incrLength;
    NSUInteger maxData     = incrLength * self.pvData.maxSplinePoints;
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:maxData];

    if (newLine.length == 0) {
        return nil;
        
// The first point must serve as a starting point.
    } else if (newLine.length < 3) {
        if (startIndex == 0) {
            CGPoint pt1 = [self getFirstPointOfLine:newLine.touches];
            [points addObject:[NSValue valueWithCGPoint:pt1]];
        }
        return nil;
        
// Only with four points or more we can really plot a B-spline.
    } else {
        CGPoint pt0, pt1, pt2, pt3, pi3, pi4;
        
        if (startIndex < 3) {
// Step one with extrapolated starting point, so that the first segment can be splined:
            pt1 = [self getFirstPointOfLine:newLine.touches];
            pt2 = [self getPointAtIndex:1 ofLine:newLine.touches];
            pt3 = [self getPointAtIndex:2 ofLine:newLine.touches];
            pt0 = CGPointMake(1.5*pt1.x - 0.75*pt2.x + 0.25*pt3.x,
                              1.5*pt1.y - 0.75*pt2.y + 0.25*pt3.y);

        } else {
            pt0 = [self getPointAtIndex:startIndex-3 ofLine:newLine.touches];
            pt1 = [self getPointAtIndex:startIndex-2 ofLine:newLine.touches];
            pt2 = [self getPointAtIndex:startIndex-1 ofLine:newLine.touches];
            pt3 = [self getPointAtIndex:startIndex ofLine:newLine.touches];
        }

        double divisions    = [self distanceBetween:pt1 and:pt2];
        NSUInteger interpol = (NSUInteger)divisions;
        if (interpol > self.pvData.maxSplinePoints) {
            divisions = divisions * self.pvData.maxSplinePoints / interpol;
            interpol  = self.pvData.maxSplinePoints;
        }
        
// Now prepare the splining part of the segment:
        CGFloat pi0x = (-pt0.x + 3 * pt1.x - 3 * pt2.x + pt3.x) / 6.0;
        CGFloat pi1x = ( pt0.x - 2 * pt1.x +     pt2.x        ) / 2.0;
        CGFloat pi2x = (-pt0.x             +     pt2.x        ) / 2.0;
        CGFloat pi3x = ( pt0.x + 4 * pt1.x +     pt2.x        ) / 6.0;
        CGFloat pi0y = (-pt0.y + 3 * pt1.y - 3 * pt2.y + pt3.y) / 6.0;
        CGFloat pi1y = ( pt0.y - 2 * pt1.y +     pt2.y        ) / 2.0;
        CGFloat pi2y = (-pt0.y             +     pt2.y        ) / 2.0;
        CGFloat pi3y = ( pt0.y + 4 * pt1.y +     pt2.y        ) / 6.0;
        
// Add the first point to the array. It should be the point which was last in the previous loop
// and is roughly pt1, i.e. the point with the index line.length - incrLength - 2
        pi3  = CGPointMake(pi3x, pi3y);
        [points addObject:[NSValue valueWithCGPoint:pi3]];
        for (NSUInteger i = 1; i < interpol; i++) {
            double t = (double)i / divisions;
            pi4.x    = (pi2x + t*(pi1x + t*pi0x))*t + pi3x;
            pi4.y    = (pi2y + t*(pi1y + t*pi0y))*t + pi3y;
            [points addObject:[NSValue valueWithCGPoint:pi4]];
        }
        divisions    = [self distanceBetween:pt2 and:pt3];

// Now loop over the known points. No guessing needed here!
        for (NSUInteger n = startIndex+1; n < newLine.length; n++) {

// prepare for next run of the loop
            pt0           = pt1;
            pt1           = pt2;
            pt2           = pt3;
            SID_Touch *tp = newLine.touches[n];
            pt3           = tp.point;
            interpol      = (NSUInteger)divisions;
            if (interpol > self.pvData.maxSplinePoints) {
                divisions = divisions * self.pvData.maxSplinePoints / interpol;
                interpol  = self.pvData.maxSplinePoints;
            }

            pi0x = (-pt0.x + 3 * pt1.x - 3 * pt2.x + pt3.x) / 6.0;
            pi1x = ( pt0.x - 2 * pt1.x +     pt2.x        ) / 2.0;
            pi2x = (-pt0.x             +     pt2.x        ) / 2.0;
            pi3x = ( pt0.x + 4 * pt1.x +     pt2.x        ) / 6.0;
            pi0y = (-pt0.y + 3 * pt1.y - 3 * pt2.y + pt3.y) / 6.0;
            pi1y = ( pt0.y - 2 * pt1.y +     pt2.y        ) / 2.0;
            pi2y = (-pt0.y             +     pt2.y        ) / 2.0;
            pi3y = ( pt0.y + 4 * pt1.y +     pt2.y        ) / 6.0;
            pi3  = CGPointMake(pi3x, pi3y);

            [points addObject:[NSValue valueWithCGPoint:pi3]];
            for (NSUInteger i = 1; i < interpol; i++) {
                double t = (double)i / divisions;
                pi4.x    = (pi2x + t*(pi1x + t*pi0x))*t + pi3x;
                pi4.y    = (pi2y + t*(pi1y + t*pi0y))*t + pi3y;
                [points addObject:[NSValue valueWithCGPoint:pi4]];
            }
            divisions = tp.distance;
        }

// The last point must be close to pt2, so we can continue at the same point next time:
        pi3x = ( pt1.x + 4 * pt2.x + pt3.x) / 6.0;
        pi3y = ( pt1.y + 4 * pt2.y + pt3.y) / 6.0;
        pi3  = CGPointMake(pi3x, pi3y);
        [points addObject:[NSValue valueWithCGPoint:pi3]];
    }
    return points;
}

// Add one extrapolated point. This really helps (sometimes)!

- (void) addLastPointToPath:(CGMutablePathRef)path fromPoints:(NSArray *)points withExtrapolation:(BOOL)extra {

    NSUInteger length = [points count];
    if (length < 2) {
        return;

// If the line never had more than two points, it needs to be painted completely.
    } else if (length < 3) {
        CGPoint pt1 = [self getPointAtIndex:length-2 ofLine:points];
        CGPathMoveToPoint(path, NULL, pt1.x, pt1.y);
        CGPoint pt2 = [self getPointAtIndex:length-1 ofLine:points];
        CGPathAddLineToPoint(path, NULL, pt2.x, pt2.y);
        CGPoint pt3 = CGPointMake(2*pt2.x - pt1.x, 2*pt2.y - pt1.y);
        CGPathAddLineToPoint(path, NULL, pt3.x, pt3.y);

// Set up the splining for the last gap, and then some more.
    } else {
        CGPoint pt0 = [self getPointAtIndex:length-3 ofLine:points];
        CGPoint pt1 = [self getPointAtIndex:length-2 ofLine:points];
        CGPoint pt2 = [self getPointAtIndex:length-1 ofLine:points];
        CGPoint pt3 = CGPointMake(1.5*pt2.x - 0.75*pt1.x + 0.25*pt0.x,
                                  1.5*pt2.y - 0.75*pt1.y + 0.25*pt0.y);

        double divisions    = [self distanceBetween:pt1 and:pt2];
        NSUInteger interpol = (NSUInteger)divisions;
        if (interpol > self.pvData.maxSplinePoints) {
            divisions = divisions * self.pvData.maxSplinePoints / interpol;
            interpol  = self.pvData.maxSplinePoints;
        }

        CGFloat pi0x = (-pt0.x + 3 * pt1.x - 3 * pt2.x + pt3.x) / 6.0;
        CGFloat pi1x = ( pt0.x - 2 * pt1.x +     pt2.x        ) / 2.0;
        CGFloat pi2x = (-pt0.x             +     pt2.x        ) / 2.0;
        CGFloat pi3x = ( pt0.x + 4 * pt1.x +     pt2.x        ) / 6.0;
        CGFloat pi0y = (-pt0.y + 3 * pt1.y - 3 * pt2.y + pt3.y) / 6.0;
        CGFloat pi1y = ( pt0.y - 2 * pt1.y +     pt2.y        ) / 2.0;
        CGFloat pi2y = (-pt0.y             +     pt2.y        ) / 2.0;
        CGFloat pi3y = ( pt0.y + 4 * pt1.y +     pt2.y        ) / 6.0;
        CGPathMoveToPoint(path, NULL, pi3x, pi3y);

        CGPoint pi4;
        if (extra) {
            for (NSUInteger i = 1; i < interpol; i++) {
                double t = (double)i / divisions;
                pi4.x    = (pi2x + t*(pi1x + t*pi0x))*t + pi3x;
                pi4.y    = (pi2y + t*(pi1y + t*pi0y))*t + pi3y;
                CGPathAddLineToPoint(path, NULL, pi4.x, pi4.y);
            }
        }
        pi4 = CGPointMake(( pt1.x + 4 * pt2.x + pt3.x) / 6.0,
                          ( pt1.y + 4 * pt2.y + pt3.y) / 6.0);
        CGPathAddLineToPoint(path, NULL, pi4.x, pi4.y);
    }
}

#pragma mark - Getter methods

- (CGPoint) getFirstPointOfLine:(NSArray *)line {
    SID_Touch *tp = [line firstObject];
    return tp.point;
}

- (CGPoint) getLastPointOfLine:(NSArray *)line {
    SID_Touch *tp = [line lastObject];
    return tp.point;
}

- (CGPoint) getPointAtIndex:(NSUInteger)index ofLine:(NSArray *)line {
    SID_Touch *tp = line[index];
    return tp.point;
}

- (NSTimeInterval) getFirstTimeOfLine:(NSArray *)line {
    SID_Touch *tp = [line firstObject];
    return tp.timestamp;
}

- (NSTimeInterval) getLastTimeOfLine:(NSArray *)line {
    SID_Touch *tp = [line lastObject];
    return tp.timestamp;
}

- (NSTimeInterval) getTimeAtIndex:(NSUInteger)index ofLine:(NSArray *)line {
    SID_Touch *tp = line[index];
    return tp.timestamp;
}

@end
