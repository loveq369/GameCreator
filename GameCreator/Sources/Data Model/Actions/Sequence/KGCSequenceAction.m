//
//	KGCSequenceAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSequenceAction.h"
#import "KGCSettingsViewManager.h"
#import "KGCSceneObject.h"

@implementation KGCSequenceAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Sequence", @"ActionKeys" : [[NSMutableArray alloc] init]};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Sequence Action", nil);
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