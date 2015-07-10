//
//  KGCDADSoundInspectorViewController.m
//  GameCreator
//
//  Created by Maarten Foukhar on 07-07-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADSoundInspectorViewController.h"
#import "KGCSprite.h"

@implementation KGCDADSoundInspectorViewController

- (NSArray *)soundSets
{
	NSMutableArray *soundSets = [[NSMutableArray alloc] init];
	[soundSets addObject:@{@"Name": NSLocalizedString(@"Intro Sounds", nil), @"Key": @"IntroSounds"}];
	[soundSets addObject:@{@"Name": NSLocalizedString(@"Hint Sounds", nil), @"Key": @"HintSounds"}];
	[soundSets addObject:@{@"Name": NSLocalizedString(@"Same Answer Sounds", nil), @"Key": @"SameAnswerSounds"}];
	[soundSets addObject:@{@"Name": NSLocalizedString(@"Correct Answer Sounds", nil), @"Key": @"CorrectAnswerSounds"}];
	[soundSets addObject:@{@"Name": NSLocalizedString(@"Wrong Answer Sounds", nil), @"Key": @"WrongAnswerSounds"}];
	[soundSets addObject:@{@"Name": NSLocalizedString(@"Auto Answer Sounds", nil), @"Key": @"AutoAnswerSounds"}];
	[soundSets addObject:@{@"Name": NSLocalizedString(@"No Interaction Sounds", nil), @"Key": @"NoInteractionSounds"}];
	
	if ([[self sceneObjects][0] isKindOfClass:[KGCSprite class]])
	{
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Mouse Click Sounds", nil), @"Key": @"MouseClickSounds"}];
	}
	
	return [NSArray arrayWithArray:soundSets];
}

- (NSString *)soundPopupSaveKey
{
	if ([[self sceneObjects][0] isKindOfClass:[KGCSprite class]])
	{
		return @"KGCSelectedSpriteSoundType";
	}
	
	return @"KGCSelectedSceneSoundType";
}

@end