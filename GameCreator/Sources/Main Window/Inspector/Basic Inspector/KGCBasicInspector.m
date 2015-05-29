//
//	KGCSpriteController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 16-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCBasicInspector.h"
#import "KGCAction.h"
#import "KGCFileDropView.h"
#import "KGCAnimation.h"
#import "KGCInspectorWindow.h"
#import "KGCSceneController.h"
#import "KGCSpriteController.h"
#import "KGCActionController.h"
#import "KGCAnimationsController.h"
#import "KGCScenePhysicsController.h"
#import "KGCSpritePhysicsController.h"

@interface KGCBasicInspector ()

@property (nonatomic, strong) KGCSceneController *sceneController;
@property (nonatomic, strong) KGCSpriteController *spriteController;
@property (nonatomic, strong) KGCActionController *eventController;
@property (nonatomic, strong) KGCAnimationsController *animationsController;
@property (nonatomic, strong) KGCScenePhysicsController *scenePhysicsController;
@property (nonatomic, strong) KGCSpritePhysicsController *spritePhysicsController;

@end

@implementation KGCBasicInspector

#pragma mark - Initial Methods

- (void)setup
{
	_sceneController = [[KGCSceneController alloc] initWithNibName:nil bundle:nil];
	_spriteController = [[KGCSpriteController alloc] initWithNibName:nil bundle:nil];
	_eventController = [[KGCActionController alloc] initWithNibName:nil bundle:nil];
	_animationsController = [[KGCAnimationsController alloc] initWithNibName:nil bundle:nil];
	_scenePhysicsController = [[KGCScenePhysicsController alloc] initWithNibName:nil bundle:nil];
	_spritePhysicsController = [[KGCSpritePhysicsController alloc] initWithNibName:nil bundle:nil];
}

#pragma mark - Subclass Methods

- (NSArray *)inspectorControllers
{
	return @[[self generalController], [self eventController], [self animationsController], [self physicsController]];
}

#pragma mark - Convenient Methods

- (KGCInspectorViewController *)generalController
{
	if ([[self sceneLayers][0] isKindOfClass:[KGCSpriteLayer class]])
	{
		return [self spriteController];
	}
	
	return [self sceneController];
}

- (KGCInspectorViewController *)physicsController
{
	if ([[self sceneLayers][0] isKindOfClass:[KGCSpriteLayer class]])
	{
		return [self spritePhysicsController];
	}
	
	return [self scenePhysicsController];
}

@end