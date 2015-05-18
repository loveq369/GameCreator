//
//	KGCPropertiesAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCPropertiesAction.h"
#import "KGCSettingsViewManager.h"

@implementation KGCPropertiesAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Properties", @"Properties" : [[NSMutableDictionary alloc] init]};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Change Properties Action", nil);
}

#pragma mark - Property Methods

- (NSMutableDictionary *)properties
{
	return [self objectForKey:@"Properties"];
}

@end