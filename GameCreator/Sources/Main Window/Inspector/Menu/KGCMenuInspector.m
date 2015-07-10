//
//	KGCMenuInspector.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCMenuInspector.h"
#import "KGCSpriteLayer.h"
#import "KGCSceneLayer.h"
#import "KGCMenuSceneController.h"
#import "KGCMenuSpriteController.h"
#import "KGCDADEventsController.h"
#import "KGCAnimationsController.h"
#import "KGCMenuSoundsInspectorViewController.h"

@interface KGCMenuInspector ()

@property (nonatomic, strong) KGCMenuSceneController *sceneController;
@property (nonatomic, strong) KGCMenuSpriteController *spriteController;
@property (nonatomic, strong) KGCDADEventsController *eventController;
@property (nonatomic, strong) KGCAnimationsController *animationsController;
@property (nonatomic, strong) KGCMenuSoundsInspectorViewController *soundsViewController;

@end

@implementation KGCMenuInspector

#pragma mark - Initial Methods

- (void)setup
{
	_sceneController = [[KGCMenuSceneController alloc] initWithNibName:nil bundle:nil];
	_spriteController = [[KGCMenuSpriteController alloc] initWithNibName:nil bundle:nil];
	_eventController = [[KGCDADEventsController alloc] initWithNibName:nil bundle:nil];
	_animationsController = [[KGCAnimationsController alloc] initWithNibName:nil bundle:nil];
	_soundsViewController = [[KGCMenuSoundsInspectorViewController alloc] initWithNibName:@"KGCSoundInspectorViewController" bundle:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subclass Methods

- (NSArray *)inspectorControllers
{
	return @[[self generalController], [self eventController], [self animationsController], [self soundsViewController]];
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