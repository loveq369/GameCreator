//
//	KGCGlobalSceneController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCGlobalSceneController.h"
#import "KGCMenuInspector.h"
#import "KGCSceneLayer.h"
#import "KGCFileDropView.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"
#import <AVFoundation/AVFoundation.h>

@interface KGCGlobalSceneController () <AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet NSPopUpButton *soundTypePopUp;
@property (nonatomic, weak) IBOutlet NSTableView *soundTableView;
@property (nonatomic, weak) IBOutlet NSButton *soundPlayButton;

@property (nonatomic, weak) IBOutlet NSTabView *settingsTabView;

@end

@implementation KGCGlobalSceneController
{
	AVAudioPlayer *_audioPlayer;
}

#pragma mark - Initial Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
  
	[[self soundPlayButton] setEnabled:NO];
	[[self settingsTabView] setHidden:YES];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSPopUpButton *soundTypePopUp = [self soundTypePopUp];
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

	[[self soundTableView] reloadData];
	[[self settingsTabView] selectTabViewItemAtIndex:index];
	
	NSString *soundPopupSaveKey = [self soundPopupSaveKey];
	if (soundPopupSaveKey)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:index forKey:soundPopupSaveKey];
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
			for (KGCScene *scene in [self sceneObjects])
			{
				[scene addSoundAtURL:[openPanel URL] forKey:[self currentSoundKey]];
			}
			[[self soundTableView] reloadData];
		}
	}];
}

- (IBAction)removeSound:(id)sender
{
	NSString *key = [self currentSoundKey];
	NSTableView *soundTableView = [self soundTableView];
	
	NSArray *sounds = [self sounds];
	NSInteger soundIndex = [soundTableView selectedRow];
	
	for (KGCScene *scene in [self sceneObjects])
	{
		[scene removeSoundNamed:sounds[soundIndex][@"AudioName"] forKey:key];
	}
	
	[soundTableView reloadData];
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
	
	NSTabView *settingsTabView = [self settingsTabView];
	[settingsTabView setHidden:!rowSelected];
}

#pragma mark - AudioPLayer Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[self soundPlayButton] setTitle:NSLocalizedString(@"Play", nil)];
	_audioPlayer = nil;
}

#pragma mark - Convenient Methods

// Implement in subclasses
- (NSString *)currentSoundKey
{
	return nil;
}

- (NSString *)soundPopupSaveKey
{
	return nil;
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