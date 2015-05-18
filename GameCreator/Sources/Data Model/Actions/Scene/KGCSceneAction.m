//
//	KGCSceneAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSceneAction.h"
#import "KGCSettingsViewManager.h"

@implementation KGCSceneAction

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

- (KGCSceneActionTransitionDirection)direction
{
	return [self integerForKey:@"TransitionDirection"];
}

- (void)setDirection:(KGCSceneActionTransitionDirection)direction
{
	[self setInteger:direction forKey:@"TransitionDirection"];
}

- (KGCSceneActionTransition)transition
{
	return [self integerForKey:@"Transition"];
}

- (void)setTransition:(KGCSceneActionTransition)transition
{
	[self setInteger:transition forKey:@"Transition"];
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