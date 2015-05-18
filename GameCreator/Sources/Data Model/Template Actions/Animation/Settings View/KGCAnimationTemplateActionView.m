//
//	KGCAnimationTemplateActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 19-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCAnimationTemplateActionView.h"
#import "KGCSpriteLayer.h"
#import "KGCAnimation.h"
#import "KGCAnimationTemplateAction.h"
#import "KGCSceneObject.h"

@interface KGCAnimationTemplateActionView ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *animationPopup;
@property (nonatomic, weak) IBOutlet NSButton *resetButton;
@property (nonatomic, weak) IBOutlet NSButton *previewButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *activityIndicator;

@end

@implementation KGCAnimationTemplateActionView
{
	KGCAnimationTemplateAction *_action;
	KGCAnimation *_currentAnimation;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];

	_action = (KGCAnimationTemplateAction *)object;
	
	KGCSceneObject *sceneObject = [self sceneObject];
	NSArray *animations = [sceneObject animations];
	NSPopUpButton *animationPopup = [self animationPopup];
	[animationPopup removeAllItems];
	[animationPopup addItemWithTitle:NSLocalizedString(@"None", nil)];
	
	if ([animations count] > 0)
	{
		[[animationPopup menu] addItem:[NSMenuItem separatorItem]];
	}
	
	NSString *animationName;
	NSString *animationKey = [_action animationKey];
	for (KGCAnimation *animation in animations)
	{
		NSString *name = [animation name];
		if ([[animation identifier] isEqualToString:animationKey])
		{
			animationName = name;
		}
		
		[animationPopup addItemWithTitle:name];
	}
	
	if (animationName)
	{
		[animationPopup selectItemWithTitle:animationName];
	}
	else
	{
		[animationPopup selectItemAtIndex:0];
	}
}

- (IBAction)chooseAnimation:(id)sender
{
	KGCSceneObject *sceneObject = [self sceneObject];
	NSArray *animations = [sceneObject animations];
	NSInteger index = [[self animationPopup] indexOfSelectedItem];
	
	if (index == 0)
	{
		[_action setAnimationKey:nil];
		return;
	}
	
	KGCAnimation *animation = animations[index - 2];
	[_action setAnimationKey:[animation identifier]];
}

- (IBAction)preview:(id)sender
{
	if ([[sender title] isEqualTo:@"Stop"])
	{
		[self stopCurrentAnimation];
	}
	else
	{
		NSUInteger row = [[self animationPopup] indexOfSelectedItem];
		if (row < 2)
		{
			return;
		}
		row -= 2;
		
		[sender setTitle:@"Stop"];
		
		KGCSceneLayer *sceneLayer = [self sceneLayer];
		[sceneLayer setPreviewModeEnabled:YES];
		
		NSProgressIndicator *activityIndicator = [self activityIndicator];
		[activityIndicator startAnimation:nil];
		
		KGCAnimation *animation = [[self sceneObject] animations][row];
		_currentAnimation = animation;
		[animation startAnimationOnLayer:sceneLayer completion:^
		{
			[sender setTitle:@"Preview"];
			[sender setEnabled:NO];
		
			[[self resetButton] setEnabled:YES];
			[activityIndicator stopAnimation:nil];
		}];
	}
}

- (IBAction)stopPreview:(id)sender
{
	[[self resetButton] setEnabled:NO];
	
	KGCSceneLayer *sceneLayer = [self sceneLayer];
	
	NSProgressIndicator *activityIndicator = [self activityIndicator];
	[activityIndicator startAnimation:nil];
	
	[_currentAnimation resetAnimationOnLayer:sceneLayer completion:^
	{
		[[self previewButton] setEnabled:YES];
		[sceneLayer setPreviewModeEnabled:NO];
		[activityIndicator stopAnimation:nil];
	}];
}

- (void)stopCurrentAnimation
{
	if (_currentAnimation)
	{
		[[self activityIndicator] stopAnimation:nil];
		[[self previewButton] setTitle:@"Preview"];
		[[self resetButton] setEnabled:NO];
		
		KGCSceneLayer *sceneLayer = [self sceneLayer];
		[sceneLayer setPreviewModeEnabled:NO];

		[_currentAnimation abortAnimationOnLayer:sceneLayer completion:^
		{
			_currentAnimation = nil;
		}];
	}
}

@end