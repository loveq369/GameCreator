//
//	CALayer+Animation.m
//	Animation Categories
//
//	Created by Maarten Foukhar on 17-11-14.
//	Copyright (c) 2014 Kiwi Fruitware. All rights reserved.
//

#import "CALayer+Animation.h"

@implementation CALayer (Animation)

- (void)addAnimationForBounds:(CGRect)bounds withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
	[basicAnimation setFromValue:[self valueWithRect:[self bounds]]];
	[basicAnimation setToValue:[self valueWithRect:bounds]];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setBounds:bounds];
}

- (void)addAnimationForPosition:(CGPoint)position withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	[basicAnimation setFromValue:[self valueWithPoint:[self position]]];
	[basicAnimation setToValue:[self valueWithPoint:position]];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setPosition:position];
}

- (void)addAnimationForOpacity:(CGFloat)opacity withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[basicAnimation setFromValue:@([self opacity])];
	[basicAnimation setToValue:@(opacity)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setOpacity:opacity];
}

- (void)addAnimationForRotationAngle:(CGFloat)angle withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	[basicAnimation setFromValue:@(0.0)];
	[basicAnimation setToValue:@(angle)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setValue:[basicAnimation toValue] forKeyPath:@"transform.rotation"];
}

- (void)addAnimationForScale:(CGFloat)scale withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	[basicAnimation setFromValue:[self valueForKeyPath:@"transform.scale"]];
	[basicAnimation setToValue:@(scale)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setTransform:CATransform3DMakeScale(scale, scale, scale)];
}

- (void)addAnimationForScaleX:(CGFloat)scaleX withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
	[basicAnimation setFromValue:[self valueForKeyPath:@"transform.scale.x"]];
	[basicAnimation setToValue:@(scaleX)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setTransform:CATransform3DMakeScale(scaleX, [[self valueForKeyPath:@"transform.scale.y"] doubleValue], [[self valueForKeyPath:@"transform.scale.z"] doubleValue])];
}

- (void)addAnimationForScaleY:(CGFloat)scaleY withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
	[basicAnimation setFromValue:[self valueForKeyPath:@"transform.scale.y"]];
	[basicAnimation setToValue:@(scaleY)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setTransform:CATransform3DMakeScale([[self valueForKeyPath:@"transform.scale.x"] doubleValue], scaleY, [[self valueForKeyPath:@"transform.scale.z"] doubleValue])];
}

- (void)addAnimationForShadowRadius:(CGFloat)shadowRadius withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
	[basicAnimation setFromValue:@([self shadowRadius])];
	[basicAnimation setToValue:@(shadowRadius)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setShadowRadius:shadowRadius];
}

- (void)addAnimationForShadowOffset:(CGSize)shadowOffset withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
	[basicAnimation setFromValue:[self valueWithSize:[self shadowOffset]]];
	[basicAnimation setToValue:[self valueWithSize:shadowOffset]];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setShadowOffset:shadowOffset];
}

- (void)addAnimationForShadowOpacity:(CGFloat)shadowOpacity withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
	[basicAnimation setFromValue:@([self shadowOpacity])];
	[basicAnimation setToValue:@(shadowOpacity)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setShadowOpacity:shadowOpacity];
}

- (void)addRestoreAnimationForKey:(NSString *)key
{
	CAAnimation *animation = [self animationForKey:key];
	
	if ([animation isKindOfClass:[CABasicAnimation class]])
	{
		CABasicAnimation *basicAnimation = (CABasicAnimation *)animation;
		NSString *keyPath = [basicAnimation keyPath];
		id fromValue = [basicAnimation toValue];
		id toValue = [basicAnimation fromValue];
		
		CABasicAnimation *newAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
		[newAnimation setFromValue:fromValue];
		[newAnimation setToValue:toValue];
		
		[self addAnimation:newAnimation forKey:[NSString stringWithFormat:@"%@-return", key]];
		[self setValue:toValue forKeyPath:keyPath];
	}
}

#pragma mark - Convenient Methods

- (NSValue *)valueWithRect:(CGRect)rect
{
	#if TARGET_OS_IPHONE
	return [NSValue valueWithCGRect:rect];
	#else
	return [NSValue valueWithRect:rect];
	#endif
}

- (NSValue *)valueWithPoint:(CGPoint)point
{
	#if TARGET_OS_IPHONE
	return [NSValue valueWithCGPoint:rect];
	#else
	return [NSValue valueWithPoint:point];
	#endif
}

- (NSValue *)valueWithSize:(CGSize)size
{
	#if TARGET_OS_IPHONE
	return [NSValue valueWithCGSize:rect];
	#else
	return [NSValue valueWithSize:size];
	#endif
}

@end