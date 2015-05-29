//
//	KGCStopAnimationActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCStopAnimationActionView.h"
#import "KGCStopAnimationAction.h"
#import "KGCSceneObject.h"
#import "KGCAnimation.h"

@interface KGCStopAnimationActionView ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *animationsPopup;

@end

@implementation KGCStopAnimationActionView
{
	KGCStopAnimationAction *_animation;
}

- (void)setupWithSceneLayers:(NSArray *)sceneLayers withSettingsObject:(id)object
{
	[super setupWithSceneLayers:sceneLayers withSettingsObject:object];
	
	_animation = object;
	
	NSPopUpButton *animationsPopup = [self animationsPopup];
	[animationsPopup removeAllItems];
	[animationsPopup addItemWithTitle:@"None"];
	
	NSArray *spriteAnimations = [(KGCSceneObject *)[_animation parentObject] animations];
	
	if ([spriteAnimations count] > 0)
	{
		[animationsPopup addItemWithTitle:NSLocalizedString(@"All Animations", nil)];
		[[animationsPopup menu] addItem:[NSMenuItem separatorItem]];
		
		for (KGCAnimation *animation in spriteAnimations)
		{
			[animationsPopup addItemWithTitle:[animation name]];
		}
		
		[animationsPopup setAutoenablesItems:YES];
	}
	else
	{
		[animationsPopup setAutoenablesItems:NO];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No Available Animations" action:NULL keyEquivalent:@""];
		[item setEnabled:NO];
		[[animationsPopup menu] addItem:item];
	}
}

- (IBAction)changeAnimation:(id)sender
{
	NSInteger index = [sender indexOfSelectedItem];
	if (index == 0)
	{
		[_animation setStopAnimationType:KGCStopAnimationActionTypeNone];
		[_animation setAnimationIdentifier:nil];
	}
	else if (index == 1)
	{
		[_animation setStopAnimationType:KGCStopAnimationActionTypeAll];
	}
	else
	{
		index -= 2;
		NSArray *spriteAnimations = [(KGCSceneObject *)[_animation parentObject] animations];
		KGCAnimation *animation = spriteAnimations[index];
		[_animation setAnimationIdentifier:[animation identifier]];
		[_animation setStopAnimationType:KGCStopAnimationActionTypeSingle];
	}
}

@end