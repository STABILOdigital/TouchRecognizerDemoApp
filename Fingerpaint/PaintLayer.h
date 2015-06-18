//
//  PaintLayer.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 03.12.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class PaintLayer;
@protocol PaintLayerDelegate <NSObject>
- (void) PaintLayerDelegateMethod: (PaintLayer *) sender;
@end

@interface PaintLayer : CALayer{
}
@property (atomic, weak) id <PaintLayerDelegate> delegate;

- (void)drawInContext:(CGContextRef)context;

@end
