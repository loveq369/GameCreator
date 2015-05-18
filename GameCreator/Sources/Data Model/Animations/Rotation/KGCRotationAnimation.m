//
//	KGCRotationAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCRotationAnimation.h"
#import "KGCSpriteLayer.h"
#import "CALayer+Animation.h"

CGFloat RadiusFromDegrees(CGFloat degrees);

@implementation KGCRotationAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Rotate",
				@"Duration" :		@(0.25),
				@"Angle" :			@(10.0)
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Rotate Animation", nil);
}

#pragma mark - Main Methods

- (void)startAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:[self duration]];
	[CATransaction setCompletionBlock:^
	{
		if (completion)
		{
			completion();
		}
	}];
	[layer addAnimationForRotationAngle:RadiusFromDegrees([self angle]) withKey:[self animationIdentifier]];
	[CATransaction commit];
}

- (void)startBackAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:[self duration]];
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

- (CGFloat)angle
{
	return [self doubleForKey:@"Angle"];
}

- (void)setAngle:(CGFloat)angle
{
	[self setDouble:angle forKey:@"Angle"];
}

- (CGFloat)duration
{
	return [self doubleForKey:@"Duration"];
}

- (void)setDuration:(CGFloat)duration
{
	[self setDouble:duration forKey:@"Duration"];
}

@end

CGFloat RadiusFromDegrees(CGFloat degrees)
{
	return ((2.0 * M_PI) / 360.0) * degrees;
}