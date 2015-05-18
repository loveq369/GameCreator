//
//	KGCGameTransitionTemplateActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 19-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCGameTransitionTemplateActionView.h"
#import "KGCGameTransitionTemplateAction.h"
#import "KGCSceneLayer.h"
#import "KGCSceneContentView.h"
#import "KGCGameSet.h"
#import "KGCGame.h"
#import "KGCScene.h"

@interface KGCGameTransitionTemplateActionView ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *gamePopup;
@property (nonatomic, weak) IBOutlet NSPopUpButton *scenePopUp;

@end

@implementation KGCGameTransitionTemplateActionView
{
	KGCGameTransitionTemplateAction *_action;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_action = object;
	
	NSPopUpButton *gameIdentifierPopUp = [self gamePopup];
	[gameIdentifierPopUp removeAllItems];
	[gameIdentifierPopUp addItemWithTitle:@"None"];
	[[gameIdentifierPopUp menu] addItem:[NSMenuItem separatorItem]];
	
	NSString *gameIdentifier = [_action gameIdentifier];
	NSString *selectTitle;
	KGCGameSet *gameSet = [self gameSet];
	KGCGame *currentGame;
	for (KGCGame *game in [gameSet games])
	{
		NSString *name = [game name];
		[gameIdentifierPopUp addItemWithTitle:name];
		if ([gameIdentifier isEqualToString:[game identifier]])
		{
			selectTitle = name;
			currentGame = game;
		}
	}
	
	if (selectTitle)
	{
		[gameIdentifierPopUp selectItemWithTitle:selectTitle];
	}
	else
	{
		[gameIdentifierPopUp selectItemAtIndex:0];
	}
	
	
	NSPopUpButton *sceneNamePopup = [self scenePopUp];
	[sceneNamePopup removeAllItems];
	[sceneNamePopup addItemWithTitle:@"None"];
	[[sceneNamePopup menu] addItem:[NSMenuItem separatorItem]];
	[sceneNamePopup setEnabled:currentGame != nil];
	
	if (currentGame)
	{
		NSString *sceneName = [_action sceneName];
		NSString *selectTitle;
		for (KGCScene *scene in [currentGame scenes])
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
	}
}

- (IBAction)changeGameIdentifier:(id)sender
{
	NSInteger index = [sender indexOfSelectedItem];
	
	if (index == 0)
	{
		[_action setSceneName:nil];
	}
	else
	{
		NSString *gameIdentifier = [[self currentGame] identifier];
		if (![gameIdentifier isEqualToString:[_action identifier]])
		{
			[_action setGameIdentifier:gameIdentifier];
			[_action setSceneName:nil];
			[self setupWithSceneLayer:[self sceneLayer] withSettingsObject:_action];
		}
	}
}

- (IBAction)changeSceneName:(id)sender
{
	KGCGame *game = [self currentGame];
	NSArray *scenes = [game scenes];
	NSInteger index = [sender indexOfSelectedItem];
	
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

- (KGCGame *)currentGame
{
	NSPopUpButton *gameIdentifierPopUp = [self gamePopup];
	NSInteger index = [gameIdentifierPopUp indexOfSelectedItem] - 2;
	return [[self gameSet] games][index];
}

- (KGCGameSet *)gameSet
{
	id object = [_action parentObject];
	while (object && ![object isKindOfClass:[KGCGameSet class]])
	{
		object = [object parentObject];
	}
	
	return object;
}

@end