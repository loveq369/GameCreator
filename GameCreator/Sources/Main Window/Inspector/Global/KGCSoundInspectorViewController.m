//
//  KGCSoundInspectorViewController.m
//  GameCreator
//
//  Created by Maarten Foukhar on 07-07-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSoundInspectorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "KGCSceneObject.h"

@interface KGCSoundInspectorViewController () <AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet NSPopUpButton *soundTypePopUp;
@property (nonatomic, weak) IBOutlet NSPopUpButton *soundPlayModePopUp;
@property (nonatomic, weak) IBOutlet NSTableView *soundTableView;
@property (nonatomic, weak) IBOutlet NSButton *soundPlayButton;
@property (nonatomic, weak) IBOutlet NSView *settingsView;
@property (nonatomic, weak) IBOutlet NSView *advancedSettingsView;

@end

@implementation KGCSoundInspectorViewController
{
	AVAudioPlayer *_audioPlayer;
	NSView *_currentSettingsView;
}

#pragma mark - Initial Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
  
	[[self soundPlayButton] setEnabled:NO];
	[[self settingsView] setHidden:YES];
	[[self advancedSettingsView] setHidden:YES];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSPopUpButton *soundTypePopUp = [self soundTypePopUp];
	[soundTypePopUp removeAllItems];
	
	NSArray *soundSets = [self soundSets];
	for (NSDictionary *soundSet in soundSets)
	{
		[soundTypePopUp addItemWithTitle:soundSet[@"Name"]];
	}
	
	NSString *soundPopupSaveKey = [self soundPopupSaveKey];
	if (soundPopupSaveKey)
	{
		NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:soundPopupSaveKey];
		[soundTypePopUp selectItemAtIndex:index];
	}
	
	[self changeSoundType:soundTypePopUp];
	[[self soundTableView] reloadData];
}

#pragma mark - Interface Methods

- (IBAction)changeSoundType:(id)sender
{
	NSInteger index = [sender indexOfSelectedItem];
	NSDictionary *soundSet = [self soundSets][index];
	
	NSView *advancedSettingsView = [self advancedSettingsView];
	[[advancedSettingsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	_currentSettingsView = [self viewForSoundSet:soundSet];
	if (_currentSettingsView)
	{
		NSRect advancedSettingsViewFrame = [advancedSettingsView frame];
		NSRect settingsViewFrame = [advancedSettingsView frame];
		settingsViewFrame.origin.x = 0.0;
		settingsViewFrame.origin.y = 0.0;
		settingsViewFrame.size.width = advancedSettingsViewFrame.size.width;
		settingsViewFrame.size.height = advancedSettingsViewFrame.size.height;
	
		[_currentSettingsView setFrame:settingsViewFrame];
		[advancedSettingsView addSubview:_currentSettingsView];
	}
	
	NSString *soundPopupSaveKey = [self soundPopupSaveKey];
	if (soundPopupSaveKey)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:index forKey:soundPopupSaveKey];
	}
	
	[[self soundTableView] reloadData];
	
	KGCSoundPlayMode soundPlayMode = [self soundPlayMode];
	NSPopUpButton *soundPlayModePopUp = [self soundPlayModePopUp];
	[soundPlayModePopUp setEnabled:[[self sounds] count] > 0];
	
	if (soundPlayMode == KGCSoundPlayModeMultiple)
	{
		[soundPlayModePopUp setTitle:NSLocalizedString(@"Multple", nil)];
	}
	else
	{
		[soundPlayModePopUp selectItemAtIndex:soundPlayMode];
	}
}

- (IBAction)changeSoundPlayMode:(id)sender
{
	KGCSoundPlayMode soundPlayMode = [sender indexOfSelectedItem];
	NSString *currentSoundKey = [self currentSoundKey];
	
	for (KGCSceneObject *sceneObject in [self sceneObjects])
	{
		[sceneObject setSoundPlayMode:soundPlayMode forKey:currentSoundKey];
	}
}

- (IBAction)addSound:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"mp3", @"m4a", @"aac"]];
	[openPanel beginSheetModalForWindow:[[[self sceneObjects][0] document] windowForSheet] completionHandler:^ (NSInteger result)
	{
		if (result == NSOKButton)
		{
			for (KGCSceneObject *sceneObject in [self sceneObjects])
			{
				[sceneObject addSoundAtURL:[openPanel URL] forKey:[self currentSoundKey]];
			}
			[[self soundTableView] reloadData];
			
			NSPopUpButton *soundPlayModePopUp = [self soundPlayModePopUp];
			[soundPlayModePopUp setEnabled:[[self sounds] count] > 0];
		}
	}];
}

- (IBAction)removeSound:(id)sender
{
	NSString *key = [self currentSoundKey];
	NSTableView *soundTableView = [self soundTableView];
	
	NSArray *sounds = [self sounds];
	NSInteger soundIndex = [soundTableView selectedRow];
	
	for (KGCSceneObject *sceneObject in [self sceneObjects])
	{
		[sceneObject removeSoundNamed:sounds[soundIndex][@"AudioName"] forKey:key];
	}
	
	[soundTableView reloadData];
	
	NSPopUpButton *soundPlayModePopUp = [self soundPlayModePopUp];
	[soundPlayModePopUp setEnabled:[[self sounds] count] > 0];
}

- (IBAction)play:(id)sender
{
	NSInteger soundIndex = [[self soundTableView] selectedRow];
	NSString *soundName = [self sounds][soundIndex][@"AudioName"];

	if (!_audioPlayer)
	{
		[sender setTitle:NSLocalizedString(@"Stop", nil)];
	
		KGCResourceController *resourceController = [[[self sceneObjects][0] document] resourceController];
		NSData *data = [resourceController audioDataForName:soundName];
		_audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
		[_audioPlayer setDelegate:self];
		[_audioPlayer play];
	}
	else
	{
		[_audioPlayer stop];
	}
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[self sounds] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"SoundTableCell" owner:nil];
	[[tableCellView textField] setStringValue:[self sounds][row][@"AudioName"]];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	BOOL rowSelected = selectedRow != -1;

	[[self soundPlayButton] setEnabled:rowSelected];
	[[self advancedSettingsView] setHidden:_currentSettingsView ? !rowSelected : YES];
	[[self settingsView] setHidden:_currentSettingsView ? !rowSelected : YES];
}

#pragma mark - AudioPLayer Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[self soundPlayButton] setTitle:NSLocalizedString(@"Play", nil)];
	_audioPlayer = nil;
}

#pragma mark - Convenient Methods

// Implement in subclasses (required)
- (NSArray *)soundSets
{
	return @[];
}

- (NSString *)soundPopupSaveKey
{
	return nil;
}

- (NSView *)viewForSoundSet:(NSDictionary *)soundSet
{
	return nil;
}

- (NSString *)currentSoundKey
{
	NSArray *soundSets = [self soundSets];
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	return soundSets[index][@"Key"];
}

- (KGCSoundPlayMode)soundPlayMode
{	
	NSString *currentSoundKey = [self currentSoundKey];
	KGCSoundPlayMode soundPlayMode = KGCSoundPlayModeCarousel;

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 0)
	{
		soundPlayMode = [sceneObjects[0] soundPlayModeForKey:currentSoundKey];
	}
	else
	{
		for (NSInteger i = 0; i < [sceneObjects count]; i ++)
		{
			KGCSceneObject *sceneObject = sceneObjects[i];
		
			if (i == 0)
			{
				soundPlayMode = [sceneObject soundPlayModeForKey:currentSoundKey];
			}
			else if (soundPlayMode != [sceneObject soundPlayModeForKey:currentSoundKey])
			{
				return KGCSoundPlayModeMultiple;
			}
		}
	}
	
	return soundPlayMode;
}

- (NSArray *)sounds
{
	NSString *currentSoundKey = [self currentSoundKey];

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCSceneObject *)sceneObjects[0] soundDictionariesForKey:currentSoundKey];
	}
	else
	{
		NSMutableArray *sounds;
		for (KGCSceneObject *sceneObject in [self sceneObjects])
		{
			if (sounds)
			{
				for (NSDictionary *soundDictionary in [sounds copy])
				{
					BOOL keepSound = NO;
					for (NSDictionary *otherSoundDictionary in [sceneObject soundDictionariesForKey:currentSoundKey])
					{
						if ([soundDictionary[@"_id"] isEqualToString:otherSoundDictionary[@"_id"]])
						{
							keepSound = YES;
						}
					}
					
					if (!keepSound)
					{
						[sounds removeObject:soundDictionary];
					}
				}
			}
			else
			{
				sounds = [[NSMutableArray alloc] initWithArray:[sceneObject soundDictionariesForKey:currentSoundKey]];
			}
		}
		return sounds;
	}
	
	return nil;
}

@end