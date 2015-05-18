//
//	KGCNotificationActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 17-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCNotificationActionView.h"
#import "KGCNotificationAction.h"

@interface KGCNotificationActionView ()

@property (nonatomic, weak) IBOutlet NSTextField *notificationNameField;

@end

@implementation KGCNotificationActionView
{
	KGCNotificationAction *_action;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_action = object;
	[[self notificationNameField] setStringValue:[_action notificationName]];
}

- (IBAction)changeNotificationName:(id)sender
{
	[_action setNotificationName:[sender stringValue]];
}

@end