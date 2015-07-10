//
//	KGCDADInspector.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADInspector.h"
#import "KGCSpriteLayer.h"
#import "KGCSceneLayer.h"
#import "KGCDADSceneController.h"
#import "KGCDADSpriteController.h"
#import "KGCDADEventsController.h"
#import "KGCAnimationsController.h"
#import "KGCDADSoundInspectorViewController.h"

@interface KGCDADInspector ()

@property (nonatomic, strong) KGCDADSceneController *sceneController;
@property (nonatomic, strong) KGCDADSpriteController *spriteController;
@property (nonatomic, strong) KGCDADEventsController *eventController;
@property (nonatomic, strong) KGCAnimationsController *animationsController;
@property (nonatomic, strong) KGCDADSoundInspectorViewController *soundsController;

@end

@implementation KGCDADInspector

#pragma mark - Initial Methods

- (void)setup
{
	_sceneController = [[KGCDADSceneController alloc] initWithNibName:nil bundle:nil];
	_spriteController = [[KGCDADSpriteController alloc] initWithNibName:nil bundle:nil];
	_eventController = [[KGCDADEventsController alloc] initWithNibName:nil bundle:nil];
	_animationsController = [[KGCAnimationsController alloc] initWithNibName:nil bundle:nil];
	_soundsController = [[KGCDADSoundInspectorViewController alloc] initWithNibName:@"KGCSoundInspectorViewController" bundle:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subclass Methods

- (NSArray *)inspectorControllers
{
	return @[[self generalController], [self eventController], [self animationsController], [self soundsController]];
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

@end