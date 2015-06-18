//
//  SIDDetailViewController.m
//  Fingerpaint
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import <stdio.h>
#import "DetailViewController.h"
#import "PaintView.h"
#import "PaintSplines.h"
#import "SID_PulsedTouchRecognizer/SID_Touch.h"

@interface DetailViewController () {
    PaintView     *paint;
    double        lastTime;
    NSMutableSet  *setOfKeys;
    CGFloat       frameRate;
    CGFloat       speed;
    NSUInteger    frameRateCounter;
    PaintViewLine *lastLine;
    CGFloat       oldZoomFactor;
    CGPoint       oldOffset;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSMutableArray *fileData;
@property (strong, nonatomic) NSMutableDictionary *layersDict;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (assign, nonatomic) CGFloat scale;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) CGFloat xOffset;
@property (assign, nonatomic) CGFloat yOffset;

- (void)configureView;
@end

#define DAMPING 0.75

NSString *const SID_PenModeNotification          = @"SID_PenModeNotification";
NSString *const SID_LineEndedNotification        = @"SID_LineEndedNotification";
NSString *const SID_RectNotification             = @"SID_RectNotification";
NSString *const SID_ParameterChangedNotification = @"SID_ParameterChangedNotification";

@implementation DetailViewController

#pragma mark - Managing the UI

- (void) configureView {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pvData      = [[PaintViewData alloc] init];
    self.linePresets = [[PaintViewLine alloc] init];
    paint            = [[PaintView alloc] initWithFrame:self.view.bounds andData:(PaintViewData *)self.pvData];
    [self.view addSubview:paint];
    self.tRec        = [[SID_PulsedTouchRecognizer alloc] initInView:self.view];
    self.fileData    = [[NSMutableArray alloc] init];
    _recording       =  NO;
    _scale           = 1.0;
    _xOffset         = 0.0;
    _yOffset         = 0.0;

    self.layersDict  = [[NSMutableDictionary alloc] init];
    setOfKeys        = [[NSMutableSet alloc] init];
    lastTime         = [[NSDate date] timeIntervalSince1970];
    frameRate        =  0.0;
    frameRateCounter =  0;
    lastLine         = [[PaintViewLine alloc] init];
    oldZoomFactor    =  1.0;
    oldOffset        = CGPointZero;

// Transfer settings to the TouchRecognizer:
    [self setParameters:self.pvData.usageMode];

// Set priority for the pulsedTouchRecognizer
    [self.panGestureRecognizer   requireGestureRecognizerToFail:self.tRec];
    [self.pinchGestureRecognizer requireGestureRecognizerToFail:self.tRec];
    [self.tRec canPreventGestureRecognizer:self.panGestureRecognizer];
    [self.tRec canPreventGestureRecognizer:self.pinchGestureRecognizer];

// Assign the viewControler as the delegate of the touchRecognizers.
    self.panGestureRecognizer.delegate   = self;
    self.pinchGestureRecognizer.delegate = self;
    
// One observer for setting the penMode:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyPenMode:)
                                                 name:SID_PenModeNotification
                                               object:nil];

// one for the line ended message:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endLine:)
                                                 name:SID_LineEndedNotification
                                               object:nil];

// and one observer for processed rects:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processedRects:)
                                                 name:SID_RectNotification
                                               object:nil];

// One observer for new parameter settings:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadNewParameters:)
                                                 name:SID_ParameterChangedNotification
                                               object:nil];
}

// Set Parameters for best results depending on use case

- (void) setParameters:(NSUInteger)useCase {

    switch (useCase) {

// Writing and crosshatching
        case 0:
            [self.tRec setSpeedLimitFactor:5.0];
            [self.tRec setMaxOffTimeFactor:4];
            [self.tRec setMinTrustedScore:3];
            [self.tRec setMinimumSpeed:100.0];
            [self.tRec setPenModeErrorLimit:0.20];
            [self.tRec setTimeBetweenSameLines:0.40];
            break;

// Loops and curls
        case 1:
            [self.tRec setSpeedLimitFactor:8];
            [self.tRec setMaxOffTimeFactor:12];
            [self.tRec setMinTrustedScore:5];
            [self.tRec setMinimumSpeed:180.0];
            [self.tRec setPenModeErrorLimit:0.18];
            [self.tRec setTimeBetweenSameLines:0.40];
            break;

// Swipes and fast lines
        default:
            [self.tRec setSpeedLimitFactor:20.0];
            [self.tRec setMaxOffTimeFactor:12];
            [self.tRec setMinTrustedScore:3];
            [self.tRec setMinimumSpeed:300.0];
            [self.tRec setPenModeErrorLimit:0.15];
            [self.tRec setTimeBetweenSameLines:0.40];
            break;
    }
// We also need to know the use case directly:
    [self.tRec setUseCase:useCase];
}

// Get the screen refresh rate from the PaintView:

- (CGFloat)calculateFrameRate {
    
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSince1970] - lastTime;
    lastTime              += elapsed;
    CGFloat newRate        = frameRateCounter / elapsed;
    frameRateCounter       = 0;

// Apply some simple damping:
    if (frameRate > 0.1) {
        frameRate = DAMPING * newRate + (1.0 - DAMPING) * frameRate;
    } else {
        frameRate = newRate;
    }

    return frameRate;
}

// What to do when the orientation changes.

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.tRec SID_cleanUp];
}

// What to do when the Erase button was pressed.

- (void) eraseButton {

    for (CAShapeLayer *layer in [self.layersDict allValues]) {
        [layer removeFromSuperlayer];
    }
    [self.layersDict removeAllObjects];

    [self.tRec SID_cleanUp];
    [paint clearScreen];
    frameRate = 0.0;
    speed     = 0.0;

    [self.tRec setScore:0];
    self.tRec.score      = 0;
    self.scale           = 1.0;
    self.xOffset         = 0.0;
    self.yOffset         = 0.0;
    paint.scaleTransform = CGAffineTransformIdentity;
}

#pragma mark - Touch handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
// Regular multitouch handling.
    [self.tRec SID_touchesBegan:touches];
    
// Process the events properly for file output:
    if (self.recording) [self writeLine:touches withString:[NSString stringWithFormat:@"touchesBegan called at %f", event.timestamp]];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
// Regular multitouch handling.
    [self.tRec SID_touchesMoved:touches];
    
// Process the events properly for file and screen output:
    if (self.recording) [self writeLine:touches withString:[NSString stringWithFormat:@"touchesMoved called at %f", event.timestamp]];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
// Get the dictionary with new line increments for looping over:
    NSDictionary *newIncrements = [self.tRec SID_touchesEnded:touches];

// Loop over the NSDictionary entries
    for (NSNumber *key in newIncrements) {
        NSArray *lineIncr = [newIncrements objectForKey:key];

// If the key is not yet in the set, initialize a new array and add the key to the key set.
// No plotting so far:
        if (![setOfKeys containsObject:key]) {
            [setOfKeys addObject:key];
            [self openNewPathWithIncrement:lineIncr forKey:key];

// If we get consecutive points, we start plotting them:
        } else {
            [self paintIncrement:lineIncr forKey:key];
        }
    }

// If we pan or pinch, set the new values for offset or zoom:
    if (self.pvData.pinchAndPan) {
        oldOffset.x   = self.xOffset;
        oldOffset.y   = self.yOffset;
        oldZoomFactor = self.scale;
    }
    
// Process the events properly for file and screen output:
    if (self.recording) [self writeLine:touches withString:[NSString stringWithFormat:@"touchesEnded called at %f", event.timestamp]];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [self.tRec SID_touchesCancelled:touches];
    
    if (self.recording) [self writeLine:touches withString:[NSString stringWithFormat:@"touchesCancelled called at %f", event.timestamp]];
}

// Actions to perform when a UI gesture has been recognized. This is only here to show that
// regular Touch gestures will not work once the user wants to put his hand on the screen.

- (IBAction)pinchGestureRecognized:(UIPinchGestureRecognizer *)sender {

    self.scale = sender.scale;
    [self updateTransformWithTranslation:CGPointZero];
}

- (IBAction)panGestureRecognized:(UIPanGestureRecognizer *)sender {

    CGPoint translation = [sender translationInView:paint];
    [self updateTransformWithTranslation: translation];
}

- (void) updateTransformWithTranslation:(CGPoint) translation {

// Create a blended transform representing translation and scaling
    self.xOffset         = translation.x * self.scale * oldZoomFactor + oldOffset.x;
    self.yOffset         = translation.y * self.scale * oldZoomFactor + oldOffset.y;
    paint.scaleTransform = CGAffineTransformMakeTranslation(self.xOffset, self.yOffset);
    paint.scaleTransform = CGAffineTransformScale(paint.scaleTransform, self.scale, self.scale);
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

// Return self.pvData.pinchAndPan
    if ([gestureRecognizer isEqual:self.pinchGestureRecognizer]
     || [gestureRecognizer isEqual:self.panGestureRecognizer]) {
        return self.pvData.pinchAndPan;
    }
    return YES;
}

#pragma mark - Touch Processing

// When a notification is received, we set new parameters

- (void)loadNewParameters:(NSNotification *)notification {

// Transfer the parameters from the message dictionary to their properties:
    self.tRec.speedLimitFactor     = [notification.userInfo[@"speedLimitFactor"] doubleValue];
    self.tRec.maxOffTimeFactor     = [notification.userInfo[@"maxOffTimeFactor"] longValue];
    self.tRec.minTrustedScore      = [notification.userInfo[@"minTrustedScore"]  longValue];
    self.tRec.minimumSpeed         = [notification.userInfo[@"minimumSpeed"]     doubleValue];
    self.tRec.xMarginForHitTesting = [notification.userInfo[@"xMarginForHitTesting"] doubleValue];
    self.tRec.yMarginForHitTesting = [notification.userInfo[@"yMarginForHitTesting"] doubleValue];
    self.tRec.penModeErrorLimit    = [notification.userInfo[@"penModeErrorLimit"]    doubleValue];
    self.tRec.timeBetweenSameLines = [notification.userInfo[@"timeBetweenSameLines"] doubleValue];
}

// Open a new layer if a new line start is detected:

- (void) openNewPathWithIncrement:(NSArray *)lineIncr forKey:(NSNumber *)key {

    PaintViewLine *newLine = [[PaintViewLine alloc] initWithIncrement:lineIncr andLine:lastLine];

// Define the layer for drawing the new line:
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    if (pathLayer) {
        [paint.layer addSublayer:pathLayer];
        pathLayer.delegate = self;
        [pathLayer setValue:key     forKey:@"Key"];
        [pathLayer setValue:newLine forKey:@"Line"];

        [pathLayer setOpaque:NO];
        [pathLayer setFrame:self.view.frame];
        [pathLayer setPath:CGPathCreateMutable()];
        [pathLayer setStrokeColor:[paint lineColorFor:newLine].CGColor];
        [pathLayer setFillColor:paint.layer.backgroundColor];
        [pathLayer setLineWidth:0.5 * newLine.width];
        [pathLayer setLineJoin:kCALineJoinRound];
        if (lastLine.penMode == 3) {
            [pathLayer setLineCap:kCALineCapButt];
        } else {
            [pathLayer setLineCap:kCALineCapRound];
        }
        [self.layersDict setObject:pathLayer forKey:key];
    }

    CGPathRelease(pathLayer.path);
}

// Add the last Increment to the line on an existing layer:

- (void) paintIncrement:(NSArray *)lineIncr forKey:(NSNumber *)key {

    CAShapeLayer *layer = self.layersDict[key];
    PaintViewLine *line = [layer valueForKey:@"Line"];
    [line.touches addObjectsFromArray:lineIncr];
    [line setLength:line.length + [lineIncr count]];

    if (line.penMode >= 0) {
// Update the parameters, just in case they have changed:
        [layer setStrokeColor:[paint lineColorFor:line].CGColor];
        [layer setLineWidth:0.5 * line.width];

        NSMutableArray *points = [paint.splinefunc splineIncrement:lineIncr forLine:line];

// Open newPath to draw the new increment into:
        CGMutablePathRef newPath = CGPathCreateMutable();
        if ([points count]) {
            CGPoint startPoint = [points[0] CGPointValue];
            CGPathMoveToPoint(newPath, nil, startPoint.x, startPoint.y);

            for (NSUInteger n = 1; n < [points count]; n++) {
                CGPoint nextPoint = [points[n] CGPointValue];
                CGPathAddLineToPoint(newPath, nil, nextPoint.x, nextPoint.y);
            }
        }

// Get the oldPath from the layer and add the newPath at the end:
        if (layer) {
            CGMutablePathRef oldPath = CGPathCreateMutableCopy(layer.path);
            CGPathAddPath(oldPath, nil, newPath);
            layer.path = oldPath;
            CGPathRelease(oldPath);
        }

// Update the display where something new happened:
        CGRect dirtyRect = CGRectInset(CGPathGetBoundingBox(newPath), -line.width, -line.width);
        paint.clipRect   = CGRectUnion(paint.clipRect, dirtyRect);
        CGPathRelease(newPath);

    } else {
// Pen mode is -1: We need to delete the line! Get the oldPath from the layer:
        if (layer) {
            CGMutablePathRef oldPath = CGPathCreateMutableCopy(layer.path);
            CGRect dirtyRect = CGRectInset(CGPathGetBoundingBox(oldPath), -line.width, -line.width);
            paint.clipRect   = CGRectUnion(paint.clipRect, dirtyRect);
            
// In any case: Delete the layer of this path:
            [layer removeFromSuperlayer];
            [self.layersDict removeObjectForKey:key];
            [setOfKeys removeObject:key];
        }
    }

// Draw inside the clipping rect:
    [layer setNeedsDisplayInRect:paint.clipRect];
    
// Count the number of screen redraws.
    frameRateCounter++;
}

- (void) applyPenMode:(NSNotification *)notification {

// Transfer the parameters from the message dictionary to their properties:
    for (NSNumber *key in notification.userInfo) {
        CAShapeLayer *layer = self.layersDict[key];
        PaintViewLine *line = [layer valueForKey:@"Line"];

// Extract the information from the dictionary item:
        line.penMode = [notification.userInfo[key] longValue];

        if (line.penMode >= 10) {
            [self setLine:line inLayer:layer toMode:line.penMode];

// Realistically, there can only be one good line. Save its pointer,
// so the line can serve as a template for future lines.
            lastLine = line;

// A negative penMode means we should erase the line and remove it from memory:
        } else if (line.penMode < 0) {
            CAShapeLayer *layer = self.layersDict[key];
            [layer removeFromSuperlayer];
            [self.layersDict removeObjectForKey:key];
            [setOfKeys removeObject:key];
        }
    }

// Now clean the setOfKeys and apply the newly found penMode retrospectively:
    if (lastLine.penMode >= 10 && [setOfKeys count] > 1) {

        for (NSNumber *key in [setOfKeys copy]) {
            CAShapeLayer *layer = self.layersDict[key];
            if (layer) {
            	PaintViewLine *line = [layer valueForKey:@"Line"];
            	[self setLine:line inLayer:layer toMode:lastLine.penMode];

// Paint this path to the bitmap:
            	if (line.closed) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                		[paint addPath:layer.path with:line];
                    });
	                [layer removeFromSuperlayer];
	                [self.layersDict removeObjectForKey:key];
	                [setOfKeys removeObject:key];
	            }
	        }
        }

// Paint into bitmap, now using the full screen to erase unwanted lines!
        dispatch_async(dispatch_get_main_queue(), ^{
        	[paint setNeedsDisplay];
        });
    }
}

// Apply all changes to a line when the mode changes:

- (void) setLine:(PaintViewLine *)line inLayer:(CAShapeLayer *)layer toMode:(NSInteger)penMode {

    switch (penMode) {
        case 1:
        case 10:
            line.color      = 1;
            line.width      = self.linePresets.width;
            line.bright     = self.linePresets.bright;
            line.alphaValue = self.linePresets.alphaValue;
            break;

        case 2:
        case 20:
            line.color      = 2;
            line.width      = self.linePresets.width;
            line.bright     = self.linePresets.bright;
            line.alphaValue = self.linePresets.alphaValue;
            break;

        case 3:
        case 30:
            line.color      = 3;
            line.width      = 50.0;
            line.bright     =  1.0;
            line.alphaValue =  0.33;
            [layer setLineCap:kCALineCapButt];
            break;

        default:
            line.color      = 4;
            line.width      = 20.0;
            line.bright     = self.linePresets.bright;
            line.alphaValue = self.linePresets.alphaValue;
            break;
    }
}

// Merge good lines into the bitmap. Finish or erase the identified paths and finish drawing the lines:

- (void) endLine:(NSNotification *)notification {

    for (NSNumber *key in notification.userInfo) {

// Dump and recreate the pathLayer:
        CAShapeLayer *layer = self.layersDict[key];
        PaintViewLine *line = [layer valueForKey:@"Line"];

        if (line) {
            line.penMode    = [notification.userInfo[key] longValue];

// … but only when we are sure about the line!
            if (line.penMode > 0) {

// If the pen mode is not obvious, keep the line around:
                if (line.penMode < 10) {
                    line.closed = YES;
                } else {

// If we paint loops, we don't like extrapolations at broken lines:
                    CGMutablePathRef path = CGPathCreateMutableCopy(layer.path);
                    if (self.pvData.usageMode == 1){
                        [paint.splinefunc addLastPointToPath:path fromPoints:line.touches withExtrapolation:NO];
                    } else {
                        [paint.splinefunc addLastPointToPath:path fromPoints:line.touches withExtrapolation:YES];
                    }

// Paint this path to the bitmap, and do it in the main queue:
                    dispatch_async(dispatch_get_main_queue(), ^{
                    	[paint addPath:path with:line];
                        CGPathRelease(path);
                    });

                    [layer removeFromSuperlayer];
                    [self.layersDict removeObjectForKey:key];
                    [setOfKeys removeObject:key];
                }
            } else {

// Finger smudge: Delete the layer of this path:
	            [layer removeFromSuperlayer];
	            [self.layersDict removeObjectForKey:key];
	            [setOfKeys removeObject:key];
	        }
	    }
    }

// Paint into bitmap, now using the full screen to erase unwanted lines!
    dispatch_async(dispatch_get_main_queue(), ^{
    	[paint setNeedsDisplay];
    });
}

// Start the rect drawing:

- (void) processedRects:(NSNotification *)notification {
    
// Transfer the parameters from the message dictionary to their properties:
    CGRect enclosingRect = [notification.userInfo[@"greenRect"] CGRectValue];
    CGRect palmRect      = [notification.userInfo[@"redRect"] CGRectValue];

    if (self.pvData.rectDisplay) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [paint drawGreenRect:enclosingRect andRedRect:palmRect];
        });
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Steuerung", @"Steuerung");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
// Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - File methods

// Open or close a file when button is tapped
- (void) startRecording {
    
// Toggle the switch:
    self.recording = !self.recording;
    
// Depending on state, open or close the file:
    if (self.recording) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (paths.count > 0) {
            NSString *filename = [NSString stringWithFormat:@"Touch protocol.txt"];
            self.filePath      = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        }
    } else {
        [self.fileData writeToFile:self.filePath atomically:NO];
    }
}

- (void) writeLine:(NSSet *)touches withString:(NSString *)string {
    
    [self.fileData addObject:string];
    
// Put the content of the NSSet in a text file.
    NSUInteger numberOfLines = 0;
    for (UITouch *touch in touches) {
        switch (touch.phase) {
            case UITouchPhaseBegan:
            {
                [self.fileData addObject:[NSString stringWithFormat:@"Line %2li  starts   at %15.6f an %5.1f %5.1f with key %li", (unsigned long)numberOfLines, touch.timestamp, [touch locationInView:self.view].x, [touch locationInView:self.view].y, (long)touch]];
                break;
            }
                
            case UITouchPhaseMoved:
            {
                [self.fileData addObject:[NSString stringWithFormat:@"Line %2li continues at %15.6f an %5.1f %5.1f with key %li", (unsigned long)numberOfLines, touch.timestamp, [touch locationInView:self.view].x, [touch locationInView:self.view].y, (long)touch]];
                break;
            }
                
            case UITouchPhaseEnded:
            {
                [self.fileData addObject:[NSString stringWithFormat:@"Line %2li   ends    at %15.6f an %5.1f %5.1f with key %li", (unsigned long)numberOfLines, touch.timestamp, [touch locationInView:self.view].x, [touch locationInView:self.view].y, (long)touch]];
                break;
            }
                
            case UITouchPhaseStationary:
            {
                [self.fileData addObject:[NSString stringWithFormat:@"Line %2li is stuck  at %15.6f an %5.1f %5.1f with key %li", (unsigned long)numberOfLines, touch.timestamp, [touch locationInView:self.view].x, [touch locationInView:self.view].y, (long)touch]];
                break;
            }
                
            case UITouchPhaseCancelled:
            {
                [self.fileData addObject:[NSString stringWithFormat:@"Line %2li cancelled at %15.6f an %5.1f %5.1f with key %li", (unsigned long)numberOfLines, touch.timestamp, [touch locationInView:self.view].x, [touch locationInView:self.view].y, (long)touch]];
                break;
            }
                
            default:
            {
                [self.fileData addObject:[NSString stringWithFormat:@"Line %2li in phase %d at %15.6f an %5.1f %5.1f with key %li", (unsigned long)numberOfLines, (int)touch.phase, touch.timestamp, [touch locationInView:self.view].x, [touch locationInView:self.view].y, (long)touch]];
            }
        }
        numberOfLines++;
    }
}

#pragma mark - Default ViewController stuff

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
    [self.fileData removeAllObjects];
    [setOfKeys removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SID_ParameterChangedNotification
                                                  object:nil];
}

@end
