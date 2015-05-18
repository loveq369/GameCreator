//
//  KGCTPlayHintemplateAction.m
//  GameCreator
//
//  Created by Maarten Foukhar on 08-04-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCTPlayHintemplateAction.h"

@implementation KGCTPlayHintemplateAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Sound", @"AudioName" : @"None", @"Loop" : @(NO)};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Sound Action", nil);
}

@end