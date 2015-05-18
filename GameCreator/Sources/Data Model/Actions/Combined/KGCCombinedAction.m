//
//	KGCCombinedAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCCombinedAction.h"
#import "KGCSettingsViewManager.h"
#import "KGCSceneLayer.h"
#import "KGCSceneObject.h"

@implementation KGCCombinedAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Combine", @"ActionKeys" : [[NSMutableArray alloc] init]};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Combine Action", nil);
}

#pragma mark - Property Methods

- (NSMutableArray *)actionKeys
{
	return [self objectForKey:@"ActionKeys"];
}

- (NSArray *)actions
{
	NSArray *actions = [(KGCSceneObject *)[self parentObject] actions];
	NSMutableArray *filteredActions = [[NSMutableArray alloc] init];
	NSArray *actionKeys = [self actionKeys];
	
	for (KGCAction *action in actions)
	{
		if ([actionKeys containsObject:[action identifier]])
		{
			[filteredActions addObject:action];
		}
	}
	
	return [NSArray arrayWithArray:filteredActions];
}

@end