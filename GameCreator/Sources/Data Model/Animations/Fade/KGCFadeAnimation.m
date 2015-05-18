//
//	KGCFadeAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCFadeAnimation.h"
#import "KGCSpriteLayer.h"
#import "CALayer+Animation.h"

@implementation KGCFadeAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Fade",
				@"Duration" :		@(0.0),
				@"Alpha" :			@(1.0)
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Fade Animation", nil);
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
	[layer addAnimationForOpacity:[self alpha] withKey:[self animationIdentifier]];
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

- (CGFloat)alpha
{
	return [self doubleForKey:@"Alpha"];
}

- (void)setAlpha:(CGFloat)alpha
{
	[self setDouble:alpha forKey:@"Alpha"];
}

@end