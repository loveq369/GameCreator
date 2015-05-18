//
//	CAShapeLayer+Animation.h
//	Animation Categories
//
//	Created by Maarten Foukhar on 17-11-14.
//	Copyright (c) 2014 Kiwi Fruitware. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define KWBezierPath UIBezierPath
#define KWColor UIColor
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#define KWBezierPath NSBezierPath
#define KWColor NSColor
#endif

@interface CAShapeLayer (Animation)

- (void)addAnimationForPath:(KWBezierPath *)path withKey:(NSString *)key;
- (void)addAnimationForLineWidth:(CGFloat)lineWidth withKey:(NSString *)key;
- (void)addAnimationForLineCap:(NSString *)lineCap withKey:(NSString *)key;
- (void)addAnimationForStrokeColor:(KWColor *)strokeColor withKey:(NSString *)key;
- (void)addAnimationForFillColor:(KWColor *)fillColor withKey:(NSString *)key;

@end