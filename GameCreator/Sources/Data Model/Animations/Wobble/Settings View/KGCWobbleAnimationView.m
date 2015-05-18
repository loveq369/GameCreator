//
//	KGCWobbleAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCWobbleAnimationView.h"
#import "KGCWobbleAnimation.h"

@interface KGCWobbleAnimationView ()

@property (nonatomic, weak) IBOutlet NSTextField *durationField;

@end

@implementation KGCWobbleAnimationView
{
	KGCWobbleAnimation *_animation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation duration]];
}

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[sender doubleValue]];
}

@end