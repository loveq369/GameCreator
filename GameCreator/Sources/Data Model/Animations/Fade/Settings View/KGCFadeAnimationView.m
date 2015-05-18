//
//	KGCFadeAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCFadeAnimationView.h"
#import "KGCFadeAnimation.h"

@interface KGCFadeAnimationView ()

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSTextField *alphaField;

@end

@implementation KGCFadeAnimationView
{
	KGCFadeAnimation *_animation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation duration]];
	[[self alphaField] setDoubleValue:[_animation alpha]];
}

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[sender doubleValue]];
}

- (IBAction)changeAlpha:(id)sender
{
	[_animation setAlpha:[sender doubleValue]];
}

@end