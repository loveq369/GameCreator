//
//	KGCAnimationAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 16-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimationAction.h"
#import "KGCSettingsViewManager.h"
#import "KGCAnimation.h"
#import "KGCAnimationActionView.h"

@implementation KGCAnimationAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Animate", @"AnimationKey" : @"None"};
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

@end