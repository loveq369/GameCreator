//
//	KGCRandomPositionAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCRandomPositionAnimationView.h"
#import "KGCRandomPositionAnimation.h"

@interface KGCRandomPositionAnimationView ()

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSTextField *minXField;
@property (nonatomic, weak) IBOutlet NSTextField *minYField;
@property (nonatomic, weak) IBOutlet NSTextField *maxXField;
@property (nonatomic, weak) IBOutlet NSTextField *maxYField;

@end

@implementation KGCRandomPositionAnimationView
{
	KGCRandomPositionAnimation *_animation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation duration]];
	
	NSPoint minimumPosition = [_animation minimumPosition];
	[[self minXField] setDoubleValue:minimumPosition.x];
	[[self minYField] setDoubleValue:minimumPosition.y];
	
	NSPoint maximumPosition = [_animation maximumPosition];
	[[self maxXField] setDoubleValue:maximumPosition.x];
	[[self maxYField] setDoubleValue:maximumPosition.y];
	
}

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[sender doubleValue]];
}

- (IBAction)changeMinimumPosition:(id)sender
{
	CGFloat x = [[self minXField] doubleValue];
	CGFloat y = [[self minYField] doubleValue];
	[_animation setMinimumPosition:NSMakePoint(x, y)];
}

- (IBAction)changeMaximumPosition:(id)sender
{
	CGFloat x = [[self maxXField] doubleValue];
	CGFloat y = [[self maxYField] doubleValue];
	[_animation setMaximumPosition:NSMakePoint(x, y)];
}

@end