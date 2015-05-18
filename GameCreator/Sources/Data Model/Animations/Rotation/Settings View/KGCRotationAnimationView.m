//
//	KGCRotationAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCRotationAnimationView.h"
#import "KGCRotationAnimation.h"

@interface KGCRotationAnimationView ()

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSTextField *degreesField;

@end

@implementation KGCRotationAnimationView
{
	KGCRotationAnimation *_animation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation duration]];
	[[self degreesField] setDoubleValue:[_animation angle]];
}

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[sender doubleValue]];
}

- (IBAction)changeAngle:(id)sender
{
	[_animation setAngle:[sender doubleValue]];
}

@end