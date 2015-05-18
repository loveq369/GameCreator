//
//	KGCConfirmAnswerTemplateAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCConfirmAnswerTemplateAction.h"

@implementation KGCConfirmAnswerTemplateAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"ConfirmAnswer"};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Confirm Answer Action", nil);
}

@end