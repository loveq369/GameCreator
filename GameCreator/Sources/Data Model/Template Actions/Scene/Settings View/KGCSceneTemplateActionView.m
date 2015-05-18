//
//	KGCSceneTemplateActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 19-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneTemplateActionView.h"
#import "KGCSceneTemplateAction.h"
#import "KGCSceneLayer.h"
#import "KGCSceneContentView.h"
#import "KGCGame.h"
#import "KGCScene.h"

@interface KGCSceneTemplateActionView ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *scenePopUp;

@end

@implementation KGCSceneTemplateActionView
{
	KGCSceneTemplateAction *_action;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_action = object;
	
	NSPopUpButton *scenePopUp = [self scenePopUp];
	[scenePopUp removeAllItems];
	[scenePopUp addItemWithTitle:@"None"];
	[[scenePopUp menu] addItem:[NSMenuItem separatorItem]];
	
	NSString *sceneName = [_action sceneName];
	NSString *selectTitle;
	KGCGame *game = [self game];
	for (KGCScene *scene in [game scenes])
	{
		NSString *name = [scene name];
		[scenePopUp addItemWithTitle:name];
		
		if ([sceneName isEqualToString:[scene identifier]])
		{
			selectTitle = name;
		}
	}
	
	if (selectTitle)
	{
		[scenePopUp selectItemWithTitle:selectTitle];
	}
	else
	{
		[scenePopUp selectItemAtIndex:0];
	}
}

- (IBAction)changeScene:(id)sender
{
	KGCGame *game = [self game];
	NSArray *scenes = [game scenes];
	NSInteger index = [sender indexOfSelectedItem];
	
	if (index == 0)
	{
		[_action setSceneName:nil];
	}
	
	KGCScene *scene = scenes[index - 2];
	[_action setSceneName:[scene identifier]];
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

@end