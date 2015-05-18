//
//	KGCTemplateAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCTemplateAction.h"
#import "KGCAnimationTemplateAction.h"
#import "KGCSoundTemplateAction.h"
#import "KGCConfirmAnswerTemplateAction.h"
#import "KGCSceneTemplateAction.h"
#import "KGCTPlayHintemplateAction.h"
#import "KGCDelayTemplateAction.h"
#import "KGCGameTransitionTemplateAction.h"
#import "KGCSettingsViewManager.h"

@implementation KGCTemplateAction

+ (Class)actionClassForType:(KGCTemplateActionType)type
{
	Class classes[8] = {[KGCTemplateAction class], [KGCAnimationTemplateAction class], [KGCSoundTemplateAction class], [KGCConfirmAnswerTemplateAction class], [KGCSceneTemplateAction class], [KGCTPlayHintemplateAction class], [KGCGameTransitionTemplateAction class], [KGCDelayTemplateAction class]};
						
	return classes[type];
}

+ (id)newActionWithType:(KGCTemplateActionType)type document:(KGCDocument *)document
{
	Class class = [self actionClassForType:type];

	NSMutableDictionary *animationDictionary = [[class createDictionary] mutableCopy];
 	KGCTemplateAction *action = [[class alloc] initWithDictionary:animationDictionary document:document];
	[action setIdentifier:[[NSUUID UUID] UUIDString]];
	[action setName:NSLocalizedString(@"New Action", nil)];
	[action setTemplateActionType:type];
	
	return action;
}

#pragma mark - Main Methods

- (KGCSettingsView *)infoViewForLayer:(KGCSceneLayer *)layer
{
	KGCSettingsView *view = (KGCSettingsView *)[[KGCSettingsViewManager sharedManager] viewForBundleName:NSStringFromClass([self class])];
	[view setupWithSceneLayer:layer withSettingsObject:self];
	
	return view;
}

- (void)setTemplateActionType:(KGCTemplateActionType)templateActionType
{
	[self setInteger:templateActionType forKey:@"TemplateActionType"];
}

- (KGCTemplateActionType)templateActionType
{
	return [self integerForKey:@"TemplateActionType"];
}

- (void)setDelay:(CGFloat)delay
{
	[self setDouble:delay forKey:@"Delay"];
}

- (CGFloat)delay
{
	return [self doubleForKey:@"Delay"];
}

// Implement in subclasses
+ (NSString *)defaultName {return nil;};
+ (NSDictionary *)createDictionary {return nil;};

@end