//
//	KGCRemoveSpriteAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCRemoveSpriteAction.h"

@implementation KGCRemoveSpriteAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"RemoveSprite"};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Remove Sprite Action", nil);
}

@end