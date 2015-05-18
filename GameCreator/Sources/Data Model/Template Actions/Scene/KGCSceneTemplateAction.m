//
//	KGCSceneTemplateAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 19-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneTemplateAction.h"

@implementation KGCSceneTemplateAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Scene", @"SceneName" : @"None"};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Scene Action", nil);
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

@end