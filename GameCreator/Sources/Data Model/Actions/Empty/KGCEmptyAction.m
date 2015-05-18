//
//	KGCEmptyAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 16-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCEmptyAction.h"

@implementation KGCEmptyAction

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Empty"};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Empty Action", nil);
}

@end