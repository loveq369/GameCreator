//
//	KGCScaleAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCScaleAnimationView.h"
#import "KGCScaleAnimation.h"

@interface KGCScaleAnimationView ()

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSTextField *scaleField;

@end

@implementation KGCScaleAnimationView
{
	KGCScaleAnimation *_animation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation duration]];
	[[self scaleField] setDoubleValue:[_animation scale]];
}

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[sender doubleValue]];
}

- (IBAction)changeScale:(id)sender
{
	[_animation setScale:[sender doubleValue]];
}

@end