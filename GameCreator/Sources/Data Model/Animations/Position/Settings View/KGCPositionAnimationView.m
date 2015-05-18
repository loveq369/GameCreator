//
//	KGCPositionAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCPositionAnimationView.h"
#import "KGCPositionAnimation.h"

@interface KGCPositionAnimationView ()

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSTextField *xField;
@property (nonatomic, weak) IBOutlet NSTextField *yField;

@end

@implementation KGCPositionAnimationView
{
	KGCPositionAnimation *_animation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation duration]];
	[[self xField] setDoubleValue:[_animation endPosition].x];
	[[self yField] setDoubleValue:[_animation endPosition].y];
}

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[[self durationField] doubleValue]];
}

- (IBAction)changeX:(id)sender
{
	CGPoint endPosition = [_animation endPosition];
	endPosition.x = [[self xField] doubleValue];
	[_animation setEndPosition:endPosition];
}

- (IBAction)changeY:(id)sender
{
	CGPoint endPosition = [_animation endPosition];
	endPosition.y = [[self yField] doubleValue];
	[_animation setEndPosition:endPosition];
}

@end