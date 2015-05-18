//
//	KGCStopAnimationAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCStopAnimationAction.h"

@implementation KGCStopAnimationAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Stop",
				@"Duration" :		@(0.25),
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Stop Animation", nil);
}

#pragma mark - Main Methods

- (BOOL)hasPreview
{
	return NO;
}

#pragma mark - Property Methods

- (void)setStopAnimationType:(KGCStopAnimationActionType)stopAnimationType
{
	[self setInteger:stopAnimationType forKey:@"StopAnimationType"];
}

- (KGCStopAnimationActionType)stopAnimationType
{
	return [self integerForKey:@"StopAnimationType"];
}

- (void)setAnimationIdentifier:(NSString *)animationIdentifier
{
	[self setObject:animationIdentifier forKey:@"AnimationIdentifier"];
}

- (NSString *)animationIdentifier
{
	return [self objectForKey:@"AnimationIdentifier"];
}

@end