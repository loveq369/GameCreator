//
//	KGCMenuSceneController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCMenuSceneController.h"
#import "KGCMenuInspector.h"
#import "KGCSceneLayer.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"

@interface KGCMenuSceneController ()

@property (nonatomic, weak) IBOutlet NSTextField *noInteractionDelayField;

@end

@implementation KGCMenuSceneController

#pragma mark - Interface Methods

- (IBAction)changeNoInteractionDelay:(id)sender
{
	[self setCurrentNoInteractionDelay:[sender doubleValue]];
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[super tableViewSelectionDidChange:notification];

	NSInteger selectedRow = [[self soundTableView] selectedRow];
	BOOL rowSelected = selectedRow != -1;
	
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	if (rowSelected && index == 2)
	{
		NSNumber *noInteractionDelay = [self noInteractionDelay];
		[self setObjectValue:noInteractionDelay inTextField:[self noInteractionDelayField]];
	}
}

#pragma mark - Convenient Methods

- (NSString *)currentSoundKey
{
	NSArray *soundKeys = @[@"BackgroundSounds", @"IntroSounds", @"NoInteractionSounds", @"HintSounds", @"LeaveSounds"];
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	return soundKeys[index];
}

- (void)setCurrentNoInteractionDelay:(NSTimeInterval)delay
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	
	if (selectedRow == -1)
	{
		return;
	}
	
	NSDictionary *soundDictionary = [self sounds][selectedRow];
	for (KGCScene *scene in [self sceneObjects])
	{
		for (NSMutableDictionary *otherSoundDictionary in [scene soundDictionariesForKey:[self currentSoundKey]])
		{
			if ([otherSoundDictionary[@"_id"] isEqualToString:soundDictionary[@"_id"]])
			{
				otherSoundDictionary[@"NoInteractionDelay"] = @(delay);
				[scene updateDictionary];
			}
		}
	}
}

- (NSNumber *)noInteractionDelay
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	
	if (selectedRow == -1)
	{
		return @(0);
	}
	
	NSDictionary *soundDictionary = [self sounds][selectedRow];
	NSTimeInterval interactionDelay = 0.0;
	BOOL firstCheck = YES;
	for (KGCScene *scene in [self sceneObjects])
	{
		for (NSMutableDictionary *dictionary in [scene soundDictionariesForKey:[self currentSoundKey]])
		{
			if ([soundDictionary[@"_id"] isEqualToString:dictionary[@"_id"]])
			{
				if (firstCheck)
				{
					firstCheck = NO;
					interactionDelay = [dictionary[@"NoInteractionDelay"] doubleValue];
				}
				else
				{
					NSTimeInterval otherInteractionDelay = [dictionary[@"NoInteractionDelay"] doubleValue];
					if (otherInteractionDelay != interactionDelay)
					{
						return nil;
					}
				}
			}
		}
	}
	
	return @(interactionDelay);
}

@end