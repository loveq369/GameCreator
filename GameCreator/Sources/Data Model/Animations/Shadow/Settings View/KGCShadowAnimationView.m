//
//	KGCShadowAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCShadowAnimationView.h"
#import "KGCShadowAnimation.h"

@interface KGCShadowAnimationView ()

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSButton *showButton;

@end

@implementation KGCShadowAnimationView
{
	KGCShadowAnimation *_animation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation duration]];
	[[self showButton] setState:[_animation show]];
}

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[sender doubleValue]];
}

- (IBAction)changeShow:(id)sender
{
	[_animation setShow:[sender state]];
}

@end