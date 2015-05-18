//
//	KGCPositionAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCPositionAnimation.h"
#import "KGCSpriteLayer.h"
#import "CALayer+Animation.h"

@implementation KGCPositionAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Position",
				@"Duration" :		@(0.25),
				@"EndPosition" :	@{@"x" : @(0.0), @"y" : @(0.0)}
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Position Animation", nil);
}

#pragma mark - Main Methods

- (void)startAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:animated ? [self duration] : 0.0];
	[CATransaction setCompletionBlock:^
	{
		if (completion)
		{
			completion();
		}
	}];
	[layer addAnimationForPosition:[self endPosition] withKey:[self animationIdentifier]];
	[CATransaction commit];
}

- (void)startBackAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:animated ? [self duration] : 0.0];
	[CATransaction setCompletionBlock:^
	{
		if (completion)
		{
			completion();
		}
	}];
	[layer addRestoreAnimationForKey:[self animationIdentifier]];
	[CATransaction commit];
}

- (BOOL)hasPreview
{
	return YES;
}

#pragma mark - Property Methods

- (CGFloat)duration
{
	return [self doubleForKey:@"Duration"];
}

- (void)setDuration:(CGFloat)duration
{
	[self setDouble:duration forKey:@"Duration"];
}

- (CGPoint)endPosition
{
	return [self pointForKey:@"EndPosition"];
}

- (void)setEndPosition:(CGPoint)endPosition
{
	[self setPoint:endPosition forKey:@"EndPosition"];
}

@end