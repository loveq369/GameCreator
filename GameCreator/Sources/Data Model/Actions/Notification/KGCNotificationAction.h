//
//	KGCNotificationAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 17-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCAction.h"

/** An action that sends a notification */
@interface KGCNotificationAction : KGCAction

/** The notification name */
@property (nonatomic, weak) NSString *notificationName;

@end