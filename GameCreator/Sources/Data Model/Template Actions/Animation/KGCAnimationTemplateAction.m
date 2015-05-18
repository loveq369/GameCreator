//
//	KGCAnimationTemplateAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCAnimationTemplateAction.h"

@implementation KGCAnimationTemplateAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Animation", @"AnimationKey" : @"None", @"Ordered" : @(NO)};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Animation Action", nil);
}

#pragma mark - Property Methods

- (NSString *)animationKey
{
	return [self objectForKey:@"AnimationKey"];
}

- (void)setAnimationKey:(NSString *)animationKey
{
	[self setObject:animationKey forKey:@"AnimationKey"];
}

- (BOOL)isOrdered
{
	return [self boolForKey:@"Ordered"];
}

- (void)setOrdered:(BOOL)ordered
{
	[self setBool:ordered forKey:@"Ordered"];
}

@end