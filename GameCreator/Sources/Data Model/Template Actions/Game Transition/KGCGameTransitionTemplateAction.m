//
//	KGCGameTransitionTemplateAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 19-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCGameTransitionTemplateAction.h"

@implementation KGCGameTransitionTemplateAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Scene"};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Game Transition Action", nil);
}

#pragma mark - Property Methods

- (NSString *)sceneName
{
	return [self objectForKey:@"SceneName"];
}

- (void)setSceneName:(NSString *)sceneName
{
	[self setObject:sceneName forKey:@"SceneName"];
}

- (NSString *)gameIdentifier
{
	return [self objectForKey:@"GameIdentifier"];
}

- (void)setGameIdentifier:(NSString *)gameIdentifier
{
	[self setObject:gameIdentifier forKey:@"GameIdentifier"];
}

@end