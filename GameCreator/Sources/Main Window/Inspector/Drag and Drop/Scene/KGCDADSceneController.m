//
//	KGCDADSceneController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADSceneController.h"
#import "KGCDADInspector.h"
#import "KGCSceneLayer.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"

@interface KGCDADSceneController ()

@property (nonatomic, weak) IBOutlet NSTextField *sceneRequiredPointsField;
@property (nonatomic, weak) IBOutlet NSButton *sceneRequireConfirmationButton;
@property (nonatomic, weak) IBOutlet NSTextField *noInteractionDelayField;
@property (nonatomic, weak) IBOutlet NSButton *disableConfirmInteractionButton;
@property (nonatomic, weak) IBOutlet NSButton *autoMoveBackWrongAnswersButton;

@end

@implementation KGCDADSceneController

#pragma mark - Initial Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[[self autoMoveBackWrongAnswersButton] setState:NSOffState];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSNumber *requiredPoints = [self objectForPropertyNamed:@"requiredPoints" inArray:[self sceneObjects]];
	[self setObjectValue:requiredPoints inTextField:[self sceneRequiredPointsField]];
		
	NSArray *properties = @[@"requireConfirmation", @"disableConfirmInteraction", @"autoMoveBackWrongAnswers"];
	NSArray *checkBoxes = @[[self sceneRequireConfirmationButton], [self disableConfirmInteractionButton], [self autoMoveBackWrongAnswersButton]];
	for (NSInteger i = 0; i < [properties count]; i ++)
	{
		NSString *propertyName = properties[i];
		NSButton *checkBox = checkBoxes[i];
		id object = [self objectForPropertyNamed:propertyName inArray:[self sceneObjects]];
		[self setObjectValue:object inCheckBox:checkBox];
	}
}

#pragma mark - Interface Methods

- (IBAction)changeSceneRequiredPoints:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"requiredPoints" inArray:[self sceneObjects]];
}

- (IBAction)changeSceneRequireConfirmation:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"requireConfirmation" inArray:[self sceneObjects]];
}

- (IBAction)changeNoInteractionDelay:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"noInteractionDelay" inArray:[self sceneObjects]];
}

- (IBAction)changeDisableConfirmInteraction:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"disableConfirmInteraction" inArray:[self sceneObjects]];
}

- (IBAction)changeAutoMoveBackAnswers:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"autoMoveBackWrongNaswers" inArray:[self sceneObjects]];
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[super tableViewSelectionDidChange:notification];

	NSInteger selectedRow = [[self soundTableView] selectedRow];
	BOOL rowSelected = selectedRow != -1;
	
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	if (rowSelected && index == 6)
	{
		NSNumber *noInteractionDelay = [self noInteractionDelay];
		[self setObjectValue:noInteractionDelay inTextField:[self noInteractionDelayField]];
	}
}

#pragma mark - Subclass Methods

- (NSString *)currentSoundKey
{
	NSArray *soundKeys = @[@"IntroSounds", @"HintSounds", @"SameAnswerSounds", @"CorrectAnswerSounds", @"WrongAnswerSounds", @"AutoAnswerSounds", @"NoInteractionSounds"];
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	return soundKeys[index];
}

- (NSString *)soundPopupSaveKey
{
	return @"KGCGameSceneSelectedSoundType";
}

#pragma mark - Convenient Methods

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