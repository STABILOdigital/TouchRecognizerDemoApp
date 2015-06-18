//
//  SID_Line.m
//  Fingerpaint
//
//  Created by Peter Kämpf on 17.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import "PaintViewLine.h"

@implementation PaintViewLine

- (instancetype) init {

    self = [super init];
    if (self) {
        self.touches = nil;
        _length      = 0;
        _penMode     = 1;
        _width       = 5;
        _alphaValue  = 1.0;
        _bright      = 0.8;
        _color       = 1;
        _closed      = NO;
    }
    return self;
}

- (instancetype) initWithIncrement:(NSArray *)increment andLine:(PaintViewLine *)line {

    self = [super init];
    if (self) {
        self.touches = [[NSMutableArray alloc] initWithArray:increment];
        _length      = [increment count];
        _width       = line.width;
        _alphaValue  = line.alphaValue;
        _bright      = line.bright;
        _color       = line.color;
    }
    return self;
}

- (void) addIncrement:(NSArray *)increment {

    [self.touches addObjectsFromArray:increment];
    self.length += [increment count];
}

@end
