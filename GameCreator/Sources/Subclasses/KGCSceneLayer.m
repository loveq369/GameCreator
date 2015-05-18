//
//	KGCSceneLayer.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneLayer.h"
#import "KGCHelperMethods.h"
#import "KGCAnimation.h"
#import "KGCAction.h"
#import "KGCEvent.h"
#import "KGCTemplateAction.h"
#import "KGCSceneContentView.h"
#import "KGCSceneObject.h"

@interface KGCSceneLayer ()

@property (nonatomic, weak) KGCSceneContentView *sceneContentView;

@end

@implementation KGCSceneLayer

#pragma mark - Initial Methods

+ (instancetype)layerWithSceneObject:(KGCSceneObject *)sceneObject sceneContentView:(KGCSceneContentView *)sceneContentView
{
	KGCSceneLayer *layer = [[self class] layer];
	[layer setupWithSceneObject:sceneObject];
	[layer setSceneContentView:sceneContentView];
	
	return layer;
}

- (void)setupWithSceneObject:(KGCSceneObject *)sceneObject
{
	_sceneObject = sceneObject;
}

#pragma mark - Main Methods

- (CGRect)realBounds
{
	NSImage *image = [self image];
	if (image)
	{
		CGSize imageSize = [image size];
		return CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
	}

	return CGRectZero;
}

- (KGCResourceController *)resourceController
{
	return [[[self sceneObject] document] resourceController];
}

@end