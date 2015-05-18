//
//	KGCSceneObject.m
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneObject.h"
#import "KGCAction.h"
#import "KGCAnimation.h"
#import "KGCEvent.h"
#import "KGCBackgroundMusicAction.h"
#import "KGCAudioEffectAction.h"
#import "KGCSoundTemplateAction.h"

@implementation KGCSceneObject
{
	NSMutableArray *_actions;
	NSMutableArray *_actionDictionaries;
	
	NSMutableArray *_animations;
	NSMutableArray *_animationDictionaries;
	
	NSMutableArray *_events;
	NSMutableArray *_eventDictionaries;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document
{
	self = [super initWithDictionary:dictionary document:document];
	
	if (self)
	{
		NSArray *allKeys = [dictionary allKeys];
	
		// Actions
		_actions = [[NSMutableArray alloc] init];
		
		if ([allKeys containsObject:@"Actions"])
		{
			_actionDictionaries = dictionary[@"Actions"];
			for (NSMutableDictionary *actionDictionary in _actionDictionaries)
			{
				KGCActionType actionType = [actionDictionary[@"ActionType"] integerValue];
				Class actionClass = [KGCAction actionClassForType:actionType];
				KGCAction *action = [[actionClass alloc] initWithDictionary:actionDictionary document:document];
				[action setParentObject:self];
				[_actions addObject:action];
			}
		}
		else
		{
			_actionDictionaries = [[NSMutableArray alloc] init];
			dictionary[@"Actions"] = _actionDictionaries;
		}
		
		// Animations
		_animations = [[NSMutableArray alloc] init];
		
		if ([allKeys containsObject:@"Animations"])
		{
			_animationDictionaries = dictionary[@"Animations"];
			for (NSMutableDictionary *animationDictionary in _animationDictionaries)
			{
				KGCAnimationType animationType = [animationDictionary[@"AnimationType"] integerValue];
				Class animationClass = [KGCAnimation animationClassForType:animationType];
				KGCAnimation *animation = [[animationClass alloc] initWithDictionary:animationDictionary document:document];
				[animation setParentObject:self];
				[_animations addObject:animation];
			}
		}
		else
		{
			_animationDictionaries = [[NSMutableArray alloc] init];
			dictionary[@"Animations"] = _animationDictionaries;
		}
		
    // Events
    _events = [[NSMutableArray alloc] init];
    
		if ([allKeys containsObject:@"Events"])
		{
			
			_eventDictionaries = dictionary[@"Events"];
			for (NSMutableDictionary *eventDictionary in _eventDictionaries)
			{
				KGCEvent *event = [[KGCEvent alloc] initWithDictionary:eventDictionary document:document];
				[event setParentObject:self];
				[_events addObject:event];
			}
		}
		else
		{
			_eventDictionaries = [[NSMutableArray alloc] init];
			dictionary[@"Events"] = _eventDictionaries;
		}
	}
	
	return self;
}

- (NSArray *)actions
{
	return [NSArray arrayWithArray:_actions];
}

- (void)addAction:(KGCAction *)action
{
	if (action)
	{
		[action setParentObject:self];
		[_actions addObject:action];
		[_actionDictionaries addObject:[action dictionary]];
		[self notifyDelegateAboutKeyChange:@"Actions"];
		[self updateDictionary];
	}
}

- (void)removeAction:(KGCAction *)action
{
	if ([_actions containsObject:action])
	{
		[_actions removeObject:action];
		[_actionDictionaries removeObject:[action dictionary]];
		[self notifyDelegateAboutKeyChange:@"Actions"];
		[self updateDictionary];
	}
}

- (NSArray *)animations
{
	return [NSArray arrayWithArray:_animations];
}

- (void)addAnimation:(KGCAnimation *)animation
{
	if (animation)
	{
		[animation setParentObject:self];
		[_animations addObject:animation];
		[_animationDictionaries addObject:[animation dictionary]];
		[self notifyDelegateAboutKeyChange:@"Animations"];
		[self updateDictionary];
	}
}

- (void)removeAnimation:(KGCAnimation *)animation
{
	if ([_animations containsObject:animation])
	{
		[_animations removeObject:animation];
		[_animationDictionaries removeObject:[animation dictionary]];
		[self notifyDelegateAboutKeyChange:@"Animations"];
		[self updateDictionary];
	}
}

- (NSArray *)events
{
	return [NSArray arrayWithArray:_events];
}

- (void)addEvent:(KGCEvent *)event
{
	if (event)
	{
		[event setParentObject:self];
		[_events addObject:event];
		[_eventDictionaries addObject:[event dictionary]];
		[self notifyDelegateAboutKeyChange:@"Events"];
		[self updateDictionary];
	}
}

- (void)removeEvent:(KGCEvent *)event
{
	if ([_events containsObject:event])
	{
		[_events removeObject:event];
		[_eventDictionaries removeObject:[event dictionary]];
		[self notifyDelegateAboutKeyChange:@"Events"];
		[self updateDictionary];
	}
}

@end