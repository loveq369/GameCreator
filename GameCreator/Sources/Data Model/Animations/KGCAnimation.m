//
//	KGCAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"
#import "KGCSettingsView.h"
#import "KGCSettingsViewManager.h"
#import "KGCSceneLayer.h"

#import "KGCImageAnimation.h"
#import "KGCPositionAnimation.h"
#import "KGCRotationAnimation.h"
#import "KGCFadeAnimation.h"
#import "KGCScaleAnimation.h"
#import "KGCSequenceAnimation.h"
#import "KGCCombinedAnimation.h"
#import "KGCPathAnimation.h"
#import "KGCMoveBackAnimation.h"
#import "KGCShadowAnimation.h"
#import "KGCWobbleAnimation.h"
#import "KGCRandomPositionAnimation.h"

@implementation KGCAnimation
{
	BOOL _cancelAnimations;
}

#pragma mark - Main Methods

+ (Class)animationClassForType:(KGCAnimationType)type
{
	Class classes[13] = {[KGCAnimation class],
						[KGCImageAnimation class], [KGCPositionAnimation class], 
						[KGCRotationAnimation class], [KGCFadeAnimation class], 
						[KGCScaleAnimation class], [KGCSequenceAnimation class], 
						[KGCCombinedAnimation class], [KGCPathAnimation class], 
						[KGCMoveBackAnimation class], [KGCShadowAnimation class],
						[KGCWobbleAnimation class], [KGCRandomPositionAnimation class]};
						
	return classes[type];
}

+ (id)newAnimationWithType:(KGCAnimationType)type document:(KGCDocument *)document
{
	Class class = [self animationClassForType:type];

	NSMutableDictionary *animationDictionary = [[class createDictionary] mutableCopy];
	animationDictionary[@"RepeatMode"] = @(0);
	animationDictionary[@"RepeatCount"] = @(0);
	
 	KGCAnimation *animation = [[class alloc] initWithDictionary:animationDictionary document:document];
	[animation setIdentifier:[[NSUUID UUID] UUIDString]];
	[animation setName:[class defaultName]];
	[animation setAnimationType:type];
	
	return animation;
}

// Implement in subclasses
+ (NSDictionary *)createDictionary {return @{};}
+ (NSString *)defaultName {return @"";};

- (NSString *)animationTypeDisplayName
{
	NSArray *animationTypeDisplayNames = @[NSLocalizedString(@"None", nil), NSLocalizedString(@"Sprite Frame", nil), NSLocalizedString(@"Position", nil), NSLocalizedString(@"Rotate", nil), NSLocalizedString(@"Fade", nil), NSLocalizedString(@"Scale", nil), NSLocalizedString(@"Sequence", nil), NSLocalizedString(@"Combine", nil), NSLocalizedString(@"Path", nil), NSLocalizedString(@"Move Back", nil), NSLocalizedString(@"Shadow Animation", nil), NSLocalizedString(@"Wobble Animation", nil), NSLocalizedString(@"Random Position Animation", nil)];
	return animationTypeDisplayNames[[self animationType]];
}

- (void)startAnimationOnLayer:(CALayer *)layer completion:(void (^)(void))completion
{
	_cancelAnimations = NO;

	KGCAnimationRepeatMode repeatMode = [self repeatMode];
	if (repeatMode == KGCAnimationRepeatModeAll || repeatMode == KGCAnimationForwardAndBack)
	{
		[self startRepeatForeverAnimation:repeatMode == KGCAnimationForwardAndBack layer:layer forward:YES count:0 currentCount:0 completion:completion];
	}
	else if (repeatMode == KGCAnimationRepeatModeCustom || repeatMode == KGCAnimationForwardAndBackCustom)
	{
		[self startRepeatForeverAnimation:repeatMode == KGCAnimationForwardAndBackCustom layer:layer forward:YES count:([self repeatCount] * 2) - 1 currentCount:0 completion:completion];
	}
	else if (repeatMode == KGCAnimationRepeatModeNone)
	{
		[self startAnimationOnLayer:layer animated:YES completion:completion];
	}
}

- (void)startRepeatForeverAnimation:(BOOL)forwardBackwardMode layer:(CALayer *)layer forward:(BOOL)forward count:(NSUInteger)count currentCount:(NSUInteger)currentCount completion:(void (^)(void))completion
{
	if (_cancelAnimations)
	{
		return;
	}

	if ((count != 0 && currentCount == count))
	{
		if (completion)
		{
			completion();
		}
		
		return;
	}
	
	if (forward)
	{
		[self startAnimationOnLayer:layer animated:YES completion:^{
			[self startRepeatForeverAnimation:forwardBackwardMode layer:layer forward:!forward count:count currentCount:currentCount + 1 completion:completion];
		}];
	}
	else
	{
		[self startBackAnimationOnLayer:layer animated:YES completion:^{
			[self startRepeatForeverAnimation:forwardBackwardMode layer:layer forward:!forward count:count currentCount:currentCount + 1 completion:completion];
		}];
	}
}

- (void)abortAnimationOnLayer:(CALayer *)layer completion:(void (^)(void))completion
{
	_cancelAnimations = YES;
	[self startBackAnimationOnLayer:layer animated:YES completion:completion];
	[layer removeAnimationForKey:[self animationIdentifier]];
}

- (KGCSettingsView *)infoViewForSceneLayer:(KGCSceneLayer *)sceneLayer
{
	KGCSettingsView *view = (KGCSettingsView *)[[KGCSettingsViewManager sharedManager] viewForBundleName:NSStringFromClass([self class])];
	[view setupWithSceneLayer:sceneLayer withSettingsObject:self];
	
	return view;
}

- (void)resetAnimationOnLayer:(CALayer *)layer completion:(void (^)(void))completion
{
	[self startBackAnimationOnLayer:layer animated:YES completion:completion];
}

- (void)startAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion {}
- (void)startBackAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion {}

- (CABasicAnimation *)animationAnimated:(BOOL)animated
{
	return nil;
}

- (CABasicAnimation *)backAnimationAnimated:(BOOL)animated
{
	return nil;
}

- (BOOL)hasPreview
{
	return NO;
}

- (NSString *)animationIdentifier
{
	return [NSString stringWithFormat:@"%@-%@", [self identifier], NSStringFromClass([self class])];
}

#pragma mark - Property Methods

- (void)setAnimationType:(KGCAnimationType)animationType
{
	[self setInteger:animationType forKey:@"AnimationType"];
}

- (KGCAnimationType)animationType
{
	return [self integerForKey:@"AnimationType"];
}

- (KGCAnimationRepeatMode)repeatMode
{
	return [self integerForKey:@"RepeatMode"];
}

- (void)setRepeatMode:(KGCAnimationRepeatMode)repeatMode
{
	[self setInteger:repeatMode forKey:@"RepeatMode"];
}

- (NSUInteger)repeatCount
{
	return [self unsignedIntegerForKey:@"RepeatCount"];
}

- (void)setRepeatCount:(NSUInteger)repeatCount
{
	[self setUnsignedInteger:repeatCount forKey:@"RepeatCount"];
}

@end