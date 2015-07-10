//
//  KGCDADShapeSoundViewController.m
//  GameCreator
//
//  Created by Maarten Foukhar on 09-07-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADShapeSoundViewController.h"
#import "KGCScene.h"
#import "KGCSprite.h"

@interface KGCDADShapeSoundViewController ()

@property (nonatomic, strong) IBOutlet NSView *emptyLocationSoundView;

@property (nonatomic, weak) IBOutlet NSPopUpButton *gridPopUp;
@property (nonatomic, weak) IBOutlet NSTextField *rowField;
@property (nonatomic, weak) IBOutlet NSTextField *columnField;
@property (nonatomic, weak) IBOutlet NSTextField *rowsField;
@property (nonatomic, weak) IBOutlet NSTextField *columnsField;

@end

@implementation KGCDADShapeSoundViewController
{
	NSNib *_nib;
	NSMutableArray *_gridSprites;
}

#pragma mark - Initial Methods

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
	{
		_nib = [[NSNib alloc] initWithNibNamed:@"KGCDADShapeLocationSoundView" bundle:nil];
		[_nib instantiateWithOwner:self topLevelObjects:nil];
	}
	
	return self;
}

#pragma mark - Subclass Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSPopUpButton *gridPopUp = [self gridPopUp];
	[gridPopUp removeAllItems];
	[gridPopUp addItemWithTitle:@"None"];
	
	KGCScene *scene = [self sceneObjects][0];
	
	[[gridPopUp menu] addItem:[NSMenuItem separatorItem]];
	
	_gridSprites = [[NSMutableArray alloc] init];
	for (KGCSprite *sprite in [scene sprites])
	{
		if ([sprite spriteType] == 1)
		{
			[gridPopUp addItemWithTitle:[sprite name]];
			[_gridSprites addObject:sprite];
		}
	}
}

- (NSArray *)soundSets
{
	NSMutableArray *soundSets = [[super soundSets] mutableCopy];
	if ([[self sceneObjects][0] isKindOfClass:[KGCScene class]])
	{
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Empty Location Sounds", nil), @"Key": @"EmptyLocationSounds"}];
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Wrong Location Sounds", nil), @"Key": @"WrongLocationSounds"}];
		[soundSets addObject:@{@"Name": NSLocalizedString(@"Correct Location Sounds", nil), @"Key": @"CorrectLocationSounds"}];
	}
	
	return [NSArray arrayWithArray:soundSets];
}

- (NSString *)soundPopupSaveKey
{
	if ([[self sceneObjects][0] isKindOfClass:[KGCScene class]])
	{
		return @"KGCSelectedShapeSceneSoundType";
	}
	
	return @"KGCSelectedSpriteSoundType";
}

#pragma mark - Interface Actions

- (IBAction)changeSizePostion:(id)sender
{
	NSMutableDictionary *gridFrameDictionary = [[NSMutableDictionary alloc] init];
	NSArray *keys = @[@"row", @"column", @"numberOfRows", @"numberOfColumns"];
	NSArray *textFields = @[[self rowField], [self columnField], [self rowsField], [self columnsField]];
	for (NSInteger i = 0; i < [keys count]; i ++)
	{
		gridFrameDictionary[keys[i]] = @([textFields[i] doubleValue]);
	}
	[self setGridFrameDcitionary:gridFrameDictionary];
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[super tableViewSelectionDidChange:notification];

	NSString *currentSoundKey = [self currentSoundKey];
	if ([currentSoundKey isEqualToString:@"EmptyLocationSounds"])
	{
		NSDictionary *gridFrameDictionary = [self gridFrameDictionary];
		
		NSArray *keys = @[@"row", @"column", @"numberOfRows", @"numberOfColumns"];
		NSArray *textFields = @[[self rowField], [self columnField], [self rowsField], [self columnsField]];
		for (NSInteger i = 0; i < [keys count]; i ++)
		{
			NSString *key = keys[i];
			NSTextField *textField = textFields[i];
			[textField setDoubleValue:[gridFrameDictionary[key] doubleValue]];
		}
	}
}

#pragma mark - Subclass Methods

- (NSView *)viewForSoundSet:(NSDictionary *)soundSet
{
	if ([soundSet[@"Key"] isEqualToString:@"EmptyLocationSounds"])
	{
		return [self emptyLocationSoundView];
	}
	
	return nil;
}

#pragma mark - Convenient Methods

- (void)setGridFrameDcitionary:(NSDictionary *)gridFrameDictionary
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	
	if (selectedRow == -1)
	{
		return;
	}
	
	NSDictionary *soundDictionary = [self sounds][selectedRow];
	for (KGCSceneObject *sceneObject in [self sceneObjects])
	{
		for (NSMutableDictionary *otherSoundDictionary in [sceneObject soundDictionariesForKey:[self currentSoundKey]])
		{
			if ([otherSoundDictionary[@"_id"] isEqualToString:soundDictionary[@"_id"]])
			{
				otherSoundDictionary[@"GridFrame"] = gridFrameDictionary;
				[sceneObject updateDictionary];
			}
		}
	}
}

- (NSDictionary *)gridFrameDictionary
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	
	if (selectedRow == -1)
	{
		return @{@"row": @(0), @"column": @(0), @"numberOfRows": @(0), @"numberOfColumns": @(0)};
	}
	
	NSArray *sceneObjects = [self sceneObjects];
	NSDictionary *soundDictionary = [self sounds][selectedRow];
	NSDictionary *gridFrameDictionary;
	BOOL firstCheck = YES;
	for (KGCScene *scene in sceneObjects)
	{
		for (NSMutableDictionary *dictionary in [scene soundDictionariesForKey:[self currentSoundKey]])
		{
			if ([soundDictionary[@"_id"] isEqualToString:dictionary[@"_id"]])
			{
				if (firstCheck)
				{
					firstCheck = NO;
					gridFrameDictionary = dictionary[@"GridFrame"];
					
					if ([sceneObjects count] == 1)
					{
						return gridFrameDictionary;
					}
				}
				else
				{
					NSDictionary *otherGridFrameDictionary = dictionary[@"NoInteractionDelay"];
					if (![self gridDictionary:gridFrameDictionary isEqualToOtherGridDictionary:otherGridFrameDictionary])
					{
						return @{@"row": @(0), @"column": @(0), @"numberOfRows": @(0), @"numberOfColumns": @(0)};
					}
				}
			}
		}
	}
	
	return gridFrameDictionary ? gridFrameDictionary : @{@"row": @(0), @"column": @(0), @"numberOfRows": @(0), @"numberOfColumns": @(0)};
}

- (BOOL)gridDictionary:(NSDictionary *)gridDictionary isEqualToOtherGridDictionary:(NSDictionary *)otherGridDictionary
{
	return	[gridDictionary[@"row"] doubleValue] == [otherGridDictionary[@"row"] doubleValue] &&
			[gridDictionary[@"column"] doubleValue] == [otherGridDictionary[@"column"] doubleValue] &&
			[gridDictionary[@"numberOfRows"] doubleValue] == [otherGridDictionary[@"numberOfRows"] doubleValue] &&
			[gridDictionary[@"numberOfColumns"] doubleValue] == [otherGridDictionary[@"numberOfColumns"] doubleValue];
}
 
@end