//
//	KGCGameTransitionAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCGameTransitionAction.h"
#import "KGCSettingsViewManager.h"

@implementation KGCGameTransitionAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"ActionType" : @"Scene",
				@"SceneName" : @"None",
				@"TransitionDirection" : @"Left",
				@"Transition" : @"Push"
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Scene Action", nil);
}

#pragma mark - Property Methods

- (KGCGameTransitionActionTransitionDirection)direction
{
	return [self integerForKey:@"TransitionDirection"];
}

- (void)setDirection:(KGCGameTransitionActionTransitionDirection)direction
{
	[self setInteger:direction forKey:@"TransitionDirection"];
}

- (KGCGameTransitionActionTransition)transition
{
	return [self integerForKey:@"Transition"];
}

- (void)setTransition:(KGCGameTransitionActionTransition)transition
{
	[self setInteger:transition forKey:@"Transition"];
}

- (NSString *)gameIdentifier
{
	return [self objectForKey:@"GameIdentifier"];
}

- (void)setGameIdentifier:(NSString *)gameIdentifier
{
	[self setObject:gameIdentifier forKey:@"GameIdentifier"];
}

- (NSString *)sceneName
{
	return [self objectForKey:@"SceneName"];
}

- (void)setSceneName:(NSString *)sceneName
{
	[self setObject:sceneName forKey:@"SceneName"];
}

@end