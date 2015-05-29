//
//	KGCSceneActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSceneActionView.h"
#import "KGCSceneAction.h"
#import "KGCSpriteLayer.h"
#import "KGCSceneContentView.h"
#import "KGCGame.h"
#import "KGCScene.h"

@interface KGCSceneActionView ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *sceneNamePopup;
@property (nonatomic, weak) IBOutlet NSPopUpButton *transitionTypePopup;
@property (nonatomic, weak) IBOutlet NSPopUpButton *transitionDirectionPopup;

@end

@implementation KGCSceneActionView
{
	KGCSceneAction *_action;
}

- (void)setupWithSceneLayers:(NSArray *)sceneLayers withSettingsObject:(id)object
{
	[super setupWithSceneLayers:sceneLayers withSettingsObject:object];
	
	_action = object;
	
	NSPopUpButton *sceneNamePopup = [self sceneNamePopup];
	[sceneNamePopup removeAllItems];
	[sceneNamePopup addItemWithTitle:@"None"];
	[[sceneNamePopup menu] addItem:[NSMenuItem separatorItem]];
	
	NSString *sceneName = [_action sceneName];
	NSString *selectTitle;
	KGCGame *game = [self game];
	for (KGCScene *scene in [game scenes])
	{
		NSString *name = [scene name];
		[sceneNamePopup addItemWithTitle:name];
		
		if ([sceneName isEqualToString:[scene identifier]])
		{
			selectTitle = name;
		}
	}
	
	if (selectTitle)
	{
		[sceneNamePopup selectItemWithTitle:selectTitle];
	}
	else
	{
		[sceneNamePopup selectItemAtIndex:0];
	}
	
	
	[[self transitionTypePopup] selectItemAtIndex:[_action transition]];
	[[self transitionDirectionPopup] selectItemAtIndex:[_action direction]];
}

- (IBAction)changeSceneName:(id)sender
{
	KGCGame *game = [self game];
	NSArray *scenes = [game scenes];
	NSInteger index = [[self sceneNamePopup] indexOfSelectedItem];
	
	if (index == 0)
	{
		[_action setSceneName:nil];
	}
	else
	{
		KGCScene *scene = scenes[index - 2];
		[_action setSceneName:[scene identifier]];
	}
}

- (IBAction)changeTransition:(id)sender
{
	[_action setTransition:[(NSPopUpButton *)sender indexOfSelectedItem]];
}

- (IBAction)changeDirection:(id)sender
{
	[_action setDirection:[(NSPopUpButton *)sender indexOfSelectedItem]];
}

- (KGCGame *)game
{
	id object = [_action parentObject];
	while (object && ![object isKindOfClass:[KGCGame class]])
	{
		object = [object parentObject];
	}
	
	return object;
}



- (KGCScene *)scene
{
	id object = [_action parentObject];
	while (object && ![object isKindOfClass:[KGCScene class]])
	{
		object = [object parentObject];
	}
	
	return object;
}

@end