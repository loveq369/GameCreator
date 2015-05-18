//
//	CALayer+Animation.h
//	Animation Categories
//
//	Created by Maarten Foukhar on 17-11-14.
//	Copyright (c) 2014 Kiwi Fruitware. All rights reserved.
//

#if TARGET_OS_IPHONE
#define NSRect CGRect
#define NSPoint CGPoint
#define NSSize CGSize
#endif

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Animation)

- (void)addAnimationForBounds:(NSRect)bounds withKey:(NSString *)key;
- (void)addAnimationForPosition:(NSPoint)position withKey:(NSString *)key;
- (void)addAnimationForOpacity:(CGFloat)opacity withKey:(NSString *)key;
- (void)addAnimationForRotationAngle:(CGFloat)angle withKey:(NSString *)key;
- (void)addAnimationForScale:(CGFloat)scale withKey:(NSString *)key;
- (void)addAnimationForScaleX:(CGFloat)scaleX withKey:(NSString *)key;
- (void)addAnimationForScaleY:(CGFloat)scaleY withKey:(NSString *)key;
- (void)addAnimationForShadowRadius:(CGFloat)shadowRadius withKey:(NSString *)key;
- (void)addAnimationForShadowOffset:(NSSize)shadowOffset withKey:(NSString *)key;
- (void)addAnimationForShadowOpacity:(CGFloat)shadowOpacity withKey:(NSString *)key;

- (void)addRestoreAnimationForKey:(NSString *)key;

@end