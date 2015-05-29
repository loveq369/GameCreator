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

- (void)setupWithSceneLayers:(NSArray *)sceneLayers withSettingsObject:(id)object
{
	[super setupWithSceneLayers:sceneLayers withSettingsObject:object];

	_action = (KGCAnimationTemplateAction *)object;
	
	NSArray *animations = [self sceneObjectAnimations];
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
	NSArray *animations = [self sceneObjectAnimations];
	NSInteger index = [[self animationPopup] indexOfSelectedItem];
	
	if (index == 0)
	{
		[_action setAnimationKey:nil];
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
		
		NSProgressIndicator *activityIndicator = [self activityIndicator];
		[activityIndicator startAnimation:nil];
		
		KGCAnimation *animation = [self sceneObjectAnimations][row];
		_currentAnimation = animation;
		
		NSArray *sceneLayers = [self sceneLayers];
		__block NSUInteger count = [sceneLayers count];
		for (KGCSceneLayer *sceneLayer in [self sceneLayers])
		{
			[sceneLayer setPreviewModeEnabled:YES];
			
			[animation startAnimationOnLayer:sceneLayer completion:^
			{
				count -= 1;
				
				if (count == 0)
				{
					[sender setTitle:@"Preview"];
					[sender setEnabled:NO];
				
					[[self resetButton] setEnabled:YES];
					[activityIndicator stopAnimation:nil];
				}
			}];
		}
	}
}

- (IBAction)stopPreview:(id)sender
{
	[[self resetButton] setEnabled:NO];
	
	NSArray *sceneLayers = [self sceneLayers];
	__block NSUInteger count = [sceneLayers count];
	for (KGCSceneLayer *sceneLayer in sceneLayers)
	{
		NSProgressIndicator *activityIndicator = [self activityIndicator];
		[activityIndicator startAnimation:nil];
		
		[_currentAnimation resetAnimationOnLayer:sceneLayer completion:^
		{
			[sceneLayer setPreviewModeEnabled:NO];
		
			count -= 1;
			
			if (count == 0)
			{
				[[self previewButton] setEnabled:YES];
				[activityIndicator stopAnimation:nil];
			}
		}];
	}
}

- (void)stopCurrentAnimation
{
	if (_currentAnimation)
	{
		[[self activityIndicator] stopAnimation:nil];
		[[self previewButton] setTitle:@"Preview"];
		[[self resetButton] setEnabled:NO];
		
		NSArray *sceneLayers = [self sceneLayers];
		__block NSUInteger count = [sceneLayers count];
		for (KGCSceneLayer *sceneLayer in sceneLayers)
		{
			[sceneLayer setPreviewModeEnabled:NO];

			[_currentAnimation abortAnimationOnLayer:sceneLayer completion:^
			{
				count -= 1;
				if (count == 0)
				{
					_currentAnimation = nil;
				}
			}];
		}
	}
}

#pragma mark - Convenient Methods

- (NSArray *)sceneObjectAnimations
{
	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCSceneObject *)sceneObjects[0] animations];
	}
	else
	{
		NSMutableArray *animations;
		for (KGCSceneObject *sceneObject in [self sceneObjects])
		{
			if (animations)
			{
				for (KGCAnimation *animation in [animations copy])
				{
					BOOL keepAction = NO;
					for (KGCAnimation *otherAnimation in [sceneObject animations])
					{
						if (animation == otherAnimation)
						{
							keepAction = YES;
						}
					}
					
					if (!keepAction)
					{
						[animations removeObject:animation];
					}
				}
			}
			else
			{
				animations = [[NSMutableArray alloc] initWithArray:[sceneObject animations]];
			}
		}
	}
	
	return nil;
}

@end