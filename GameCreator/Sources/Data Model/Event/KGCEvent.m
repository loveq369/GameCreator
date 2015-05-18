//
//	KGCEvent.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCEvent.h"

@implementation KGCEvent
{
		
	NSMutableArray *_templateActions;
	NSMutableArray *_templateActionDictionaries;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document
{
	self = [super initWithDictionary:dictionary document:document];
	
	if (self)
	{
		// Template Actions
		_templateActions = [[NSMutableArray alloc] init];
		_templateActionDictionaries = dictionary[@"TemplateActions"];
		
		if (_templateActionDictionaries)
		{
			for (NSMutableDictionary *templateActionDictionary in _templateActionDictionaries)
			{
				KGCTemplateActionType templateActionType = [templateActionDictionary[@"TemplateActionType"] integerValue];
				Class templateActionClass = [KGCTemplateAction actionClassForType:templateActionType];
				KGCTemplateAction *templateAction = [[templateActionClass alloc] initWithDictionary:templateActionDictionary document:document];
				[templateAction setParentObject:self];
				[_templateActions addObject:templateAction];
			}
		}
		else
		{
			_templateActionDictionaries = [[NSMutableArray alloc] init];
			dictionary[@"TemplateActions"] = _templateActionDictionaries;
		}
	}
	
	return self;
}

+ (id)newEventWithDocument:(KGCDocument *)document
{
	NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
	newDictionary[@"_id"] = [[NSUUID UUID] UUIDString];
	newDictionary[@"Name"] = NSLocalizedString(@"New Event", nil);
	newDictionary[@"EventType"] = @(KGCEventTypeNone);
	newDictionary[@"Targets"] = [[NSMutableArray alloc] init];
	newDictionary[@"Ordered"] = @(NO);
	newDictionary[@"Delay"] = @(0.0);
	
	return [[KGCEvent alloc] initWithDictionary:newDictionary document:document];
}

- (void)setEventType:(KGCEventType)eventType
{
	[self setInteger:eventType forKey:@"EventType"];
}

- (KGCEventType)eventType
{
	return [self integerForKey:@"EventType"];
}

- (void)setTargets:(NSMutableArray *)targets
{
	[self setObject:targets forKey:@"Targets"];
}

- (NSMutableArray *)targets
{
	return [self objectForKey:@"Targets"];
}

- (void)setTemplateActionNames:(NSMutableArray *)templateActionNames
{
	[self setObject:templateActionNames forKey:@"TemplateActionNames"];
}

- (NSMutableArray *)templateActionNames
{
	return [self objectForKey:@"TemplateActionNames"];
}

- (void)setDelay:(CGFloat)delay
{
	[self setDouble:delay forKey:@"Delay"];
}

- (CGFloat)delay
{
	return [self doubleForKey:@"Delay"];
}

- (void)setOrdered:(BOOL)ordered
{
	[self setBool:ordered forKey:@"Ordered"];
}

- (BOOL)isOrdered
{
	return [self boolForKey:@"Ordered"];
}

- (void)setRequiredPoints:(NSInteger)requiredPoints
{
	[self setInteger:requiredPoints forKey:@"RequiredPoints"];
}

- (NSInteger)requiredPoints
{
	return [self integerForKey:@"RequiredPoints"];
}

- (void)setMaxPoints:(NSInteger)maxPoints
{
	[self setInteger:maxPoints forKey:@"MaxPoints"];
}

- (NSInteger)maxPoints
{
	return [self integerForKey:@"MaxPoints"];
}

- (void)setLinked:(BOOL)linked
{
	[self setBool:linked forKey:@"Linked"];
}

- (BOOL)isLinked
{
	return [self boolForKey:@"Linked"];
}

- (void)setNotificationName:(NSString *)notificationName
{
	[self setObject:[notificationName copy] forKey:@"NotificationName"];
}

- (NSString *)notificationName
{
	return [self objectForKey:@"NotificationName"];
}

- (NSArray *)templateActions
{
	return [NSArray arrayWithArray:_templateActions];
}

- (void)addTemplateAction:(KGCTemplateAction *)templateAction
{
	if (templateAction)
	{
		[templateAction setParentObject:self];
		[_templateActions addObject:templateAction];
		[_templateActionDictionaries addObject:[templateAction dictionary]];
		[self notifyDelegateAboutKeyChange:@"TemplateActions"];
		[self updateDictionary];
	}
}

- (void)removeTemplateAction:(KGCTemplateAction *)templateAction
{
	if ([_templateActions containsObject:templateAction])
	{
		[_templateActions removeObject:templateAction];
		[_templateActionDictionaries removeObject:[templateAction dictionary]];
		[self notifyDelegateAboutKeyChange:@"TemplateActions"];
		[self updateDictionary];
	}
}

@end