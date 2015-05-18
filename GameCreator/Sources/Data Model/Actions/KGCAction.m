//
//	KGCAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 16-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"
#import "KGCSettingsViewManager.h"
#import "KGCSettingsView.h"

// Actions
#import "KGCEmptyAction.h"
#import "KGCNotificationAction.h"
#import "KGCAnimationAction.h"
#import "KGCAudioEffectAction.h"
#import "KGCSceneAction.h"
#import "KGCBackgroundMusicAction.h"
#import "KGCRemoveSpriteAction.h"
#import "KGCPropertiesAction.h"
#import "KGCCombinedAction.h"
#import "KGCSequenceAction.h"
#import "KGCStopAnimationAction.h"
#import "KGCGameTransitionAction.h"

@implementation KGCAction

#pragma mark - Main Methods

+ (Class)actionClassForType:(KGCActionType)type
{
	Class classes[13] = {
							[KGCAction class], [KGCEmptyAction class], [KGCNotificationAction class],
							[KGCAnimationAction class], [KGCAudioEffectAction class], 
							[KGCSceneAction class], [KGCBackgroundMusicAction class], 
							[KGCRemoveSpriteAction class], [KGCPropertiesAction class], 
							[KGCCombinedAction class], [KGCSequenceAction class],
							[KGCStopAnimationAction class], [KGCGameTransitionAction class]
						};
						
	return classes[type];
}

+ (id)newActionWithType:(KGCActionType)type document:(KGCDocument *)document
{
	Class class = [self actionClassForType:type];
	
	NSMutableDictionary *animationDictionary = [[class createDictionary] mutableCopy];
 	KGCAction *action = [[class alloc] initWithDictionary:animationDictionary document:document];
	[action setName:[class defaultName]];
	[action setIdentifier:[[NSUUID UUID] UUIDString]];
	[action setActionTrigger:KGCActionTriggerNone];
	[action setActionType:type];
	
	return action;
}

- (KGCSettingsView *)infoViewForSceneLayer:(KGCSceneLayer *)sceneLayer
{
	KGCSettingsView *view = (KGCSettingsView *)[[KGCSettingsViewManager sharedManager] viewForBundleName:NSStringFromClass([self class])];
	[view setupWithSceneLayer:sceneLayer withSettingsObject:self];
	
	return view;
}

- (NSString *)actionTypeDisplayName
{
	NSArray *actionTypeDisplayNames = @[NSLocalizedString(@"None", nil), NSLocalizedString(@"Empty", nil), NSLocalizedString(@"Notification", nil), NSLocalizedString(@"Animate", nil), NSLocalizedString(@"Audio Effect", nil), NSLocalizedString(@"Scene Transition", nil), NSLocalizedString(@"Background Music", nil), NSLocalizedString(@"Remove Sprite", nil), NSLocalizedString(@"Properties", nil), NSLocalizedString(@"Combine", nil), NSLocalizedString(@"Sequence", nil), NSLocalizedString(@"Stop Animation", nil), NSLocalizedString(@"Game Transition", nil)];
	return actionTypeDisplayNames[[self actionType]];
}

#pragma mark - Subclass Methods

// Implement in subclasses
+ (NSDictionary *)createDictionary {return @{};}
+ (NSString *)defaultName {return @"";};

#pragma mark - Property Methods

- (void)setActionType:(KGCActionType)actionType
{
	[self setInteger:actionType forKey:@"ActionType"];
}

- (KGCActionType)actionType
{
	return [self integerForKey:@"ActionType"];
}

- (void)setActionTrigger:(KGCActionTrigger)actionTrigger
{
	[self setInteger:actionTrigger forKey:@"Trigger"];
}

- (KGCActionTrigger)actionTrigger
{
	return [self integerForKey:@"Trigger"];
}

- (void)setActionTriggerNotificationName:(NSString *)actionTriggerNotificationName
{
	[self setObject:actionTriggerNotificationName forKey:@"NotificationName"];
}

- (NSString *)actionTriggerNotificationName
{
	if ([self hasObjectForKey:@"NotificationName"])
	{
		return [self objectForKey:@"NotificationName"];
	}

	return @"";
}

- (void)setDelay:(CGFloat)delay
{
	[self setDouble:delay forKey:@"Delay"];
}

- (CGFloat)delay
{
	return [self doubleForKey:@"Delay"];
}

- (void)setActionPoints:(NSInteger)actionPoints
{
	[self setInteger:actionPoints forKey:@"ActionPoints"];
}

- (NSInteger)actionPoints
{
	return [self integerForKey:@"ActionPoints"];
}

- (void)setRequiredActionPoints:(NSUInteger)requiredActionPoints
{
	[self setUnsignedInteger:requiredActionPoints forKey:@"RequiredActionPoints"];
}

- (NSUInteger)requiredActionPoints
{
	return [self unsignedIntegerForKey:@"RequiredActionPoints"];
}

- (void)setMaximumActionPoints:(NSUInteger)maximumActionPoints
{
	[self setUnsignedInteger:maximumActionPoints forKey:@"MaximumActionPoints"];
}

- (NSUInteger)maximumActionPoints
{
	return [self unsignedIntegerForKey:@"MaximumActionPoints"];
}

- (void)setTriggerKeys:(NSMutableArray *)triggerKeys
{
	[self setObject:triggerKeys forKey:@"TriggerKeys"];
}

- (NSMutableArray *)triggerKeys
{
	return [self objectForKey:@"TriggerKeys"];
}

- (void)setActionLinkType:(KGCActionLinkType)actionLinkType
{
	[self setInteger:actionLinkType forKey:@"LinkType"];
}

- (KGCActionLinkType)actionLinkType
{
	return [self integerForKey:@"LinkType"];
}

@end