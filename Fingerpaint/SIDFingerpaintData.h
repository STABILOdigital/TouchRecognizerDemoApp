
#import <Foundation/Foundation.h>

@interface SIDFingerpaintData : NSObject

@property (assign, nonatomic) CGFloat    lineWidth;
@property (assign, nonatomic) CGFloat    alphaValue;
@property (assign, nonatomic) CGFloat    lineBright;
@property (assign, nonatomic) NSInteger  lineStyle;
@property (assign, nonatomic) NSInteger  lineSpline;
@property (assign, nonatomic) NSInteger  maxPause;
@property (assign, nonatomic) NSInteger  maxPoints;
@property (assign, nonatomic) NSUInteger color;
@property (assign, nonatomic) BOOL       rectDisplay;
@property (assign, nonatomic) CGFloat    minLineWidth;
@property (assign, nonatomic) CGFloat    maxLineWidth;
@end

extern NSString *const SIDPictureRedrawnNotification;
extern NSString *const SIDLineDataChangedNotification;
extern NSString *const SIDRecordButtonNotification;
extern NSString *const SIDEraseButtonNotification;
