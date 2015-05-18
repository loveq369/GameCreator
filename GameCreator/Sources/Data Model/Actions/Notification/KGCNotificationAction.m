//
//	KGCNotificationAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 17-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCNotificationAction.h"

@implementation KGCNotificationAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Notification", @"NotificationName" : @""};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Notification Action", nil);
}

#pragma mark - Property Methods

- (void)setNotificationName:(NSString *)notificationName
{
	[self setObject:notificationName forKey:@"NotificationName"];
}

- (NSString *)notificationName
{
	return [self objectForKey:@"NotificationName"];
}

@end