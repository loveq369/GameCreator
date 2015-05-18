//
//	KGCScaleAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCScaleAnimation.h"
#import "KGCSpriteLayer.h"
#import "CALayer+Animation.h"

@implementation KGCScaleAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Scale",
				@"Duration" :		@(0.0),
				@"Scale" :			@(1.0)
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Scale Animation", nil);
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
	
	KGCSceneLayer *sceneLayer = (KGCSceneLayer *)layer;
	CGFloat scale = [self scale];
	CGRect scaledBounds = [sceneLayer realBounds];
	scaledBounds.size.width *= scale;
	scaledBounds.size.height *= scale;
	
	[sceneLayer addAnimationForBounds:scaledBounds withKey:[self animationIdentifier]];
	
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

- (CGFloat)scale
{
	return [self doubleForKey:@"Scale"];
}

- (void)setScale:(CGFloat)scale
{
	[self setDouble:scale forKey:@"Scale"];
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