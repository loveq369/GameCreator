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

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object;
{
	_sceneLayer = sceneLayer;
}

- (KGCSceneObject *)sceneObject
{
	return [[self sceneLayer] sceneObject];
}

@end