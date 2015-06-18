//
//  SID_Line.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 17.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import <Foundation/Foundation.h>

@interface PaintViewLine : NSObject

@property (assign, nonatomic) NSInteger  penMode;            // Which pattern has been detected?
@property (assign, nonatomic) NSUInteger length;             // How many points are there so far?
@property (strong, nonatomic) NSMutableArray *touches;       // Constituents of the line.
@property (assign, nonatomic) BOOL closed;                   // are still points being added?

// These variables can be set with the control subview,
@property (assign, nonatomic) CGFloat    width;
@property (assign, nonatomic) CGFloat    alphaValue;
@property (assign, nonatomic) CGFloat    bright;
@property (assign, nonatomic) NSUInteger color;

- (instancetype) init;
- (instancetype) initWithIncrement:(NSArray *)increment andLine:(PaintViewLine *)line;
- (void) addIncrement:(NSArray *)increment;

@end
