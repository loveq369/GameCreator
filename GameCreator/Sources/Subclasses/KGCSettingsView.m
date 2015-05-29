//
//	KGCSettingsView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSettingsView.h"
#import "KGCSceneLayer.h"

@implementation KGCSettingsView

- (void)setupWithSceneLayers:(NSArray *)sceneLayers withSettingsObject:(id)object;
{
	_sceneLayers = sceneLayers;
}

- (NSArray *)sceneObjects
{
	NSMutableArray *sceneObjects = [[NSMutableArray alloc] init];
	for (KGCSceneLayer *sceneLayer in [self sceneLayers])
	{
		[sceneObjects addObject:[sceneLayer sceneObject]];
	}

	return [NSArray arrayWithArray:sceneObjects];
}

@end