//
//  KGCMenuSoundsInspectorViewController.m
//  GameCreator
//
//  Created by Maarten Foukhar on 07-07-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCMenuSoundsInspectorViewController.h"
#import "KGCSprite.h"
#import "KGCScene.h"

@implementation KGCMenuSoundsInspectorViewController

- (NSArray *)soundSets
{
	NSMutableArray *soundSets = [[NSMutableArray alloc] init];

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects[0] isKindOfClass:[KGCSprite class]])
	{
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Hint Sounds", nil), @"Key": @"HintSounds"}];
		[soundSets addObject:@{@"Name": NSLocalizedString(@"No Interaction Sounds", nil), @"Key": @"NoInteractionSounds"}];
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Mouse Enter Sounds", nil), @"Key": @"MouseEnterSounds"}];
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Mouse Click Sounds", nil), @"Key": @"MouseClickSounds"}];
	}
	else
	{
		if ([sceneObjects[0] isKindOfClass:[KGCScene class]])
		{
			[soundSets addObject:@{@"Name": NSLocalizedString(@"Background Sounds", nil), @"Key": @"BackgroundSounds"}];
		}
		
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Hint Sounds", nil), @"Key": @"HintSounds"}];
		[soundSets addObject:@{@"Name": NSLocalizedString(@"No Interaction Sounds", nil), @"Key": @"NoInteractionSounds"}];
	}
	
	return [NSArray arrayWithArray:soundSets];
}

- (NSString *)soundPopupSaveKey
{
	if ([[self sceneObjects][0] isKindOfClass:[KGCSprite class]])
	{
		return @"KGCMenuSelectedSoundType";
	}
	else
	{
		return @"KGCMenuSpriteSelectedSoundType";
	}
}

@end