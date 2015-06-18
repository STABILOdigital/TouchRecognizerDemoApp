//
//  PaintLayer.m
//  Fingerpaint
//
//  Created by Peter Kämpf on 03.12.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "PaintLayer.h"
#import "PaintViewLine.h"
#import "PaintView.h"

@implementation PaintLayer
@synthesize delegate;

- (void) drawInContext:(CGContextRef)context {

    PaintViewLine *line = self.linesDict[key];
    UIBezierPath *path  = self.pathsDict[key];
    [line.touchPoints addObjectsFromArray:lineIncr.touchPoints];
    [line setLength:line.length + [lineIncr.touchPoints count]];

// Set the context for painting:
    UIGraphicsPushContext(context);
    UIColor *color = [self lineColorForNumber:self.pvData.lineColor];

    NSMutableArray *points = [self.splinefunc splineIncrement:lineIncr forLine:line];
    if ([points count]) {
        [path moveToPoint:[points[0] CGPointValue]];
        for (NSUInteger n = 1; n < [points count]; n++) {
            [path addLineToPoint:[points[n] CGPointValue]];
        }
    }

// Now paint the path into the current context:
    path.lineWidth    = 0.5 * self.pvData.lineWidth;
    path.lineCapStyle = kCGLineCapRound;
    [color setStroke];
    [path stroke];
    CGRect dirtyRect  = CGRectInset(path.bounds, -self.pvData.lineWidth, -self.pvData.lineWidth);
    UIGraphicsPopContext();
    clipRect = CGRectUnion(clipRect, dirtyRect);

// Expand the clipping rect:
    long extra = self.pvData.lineWidth + 8;
    clipRect   = CGRectInset(clipRect, -extra, -extra);

}

@end
