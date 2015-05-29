//
//	KGCMenuSpriteController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCMenuSpriteController.h"
#import "KGCMenuInspector.h"
#import "KGCSprite.h"
#import "KGCScene.h"
#import "KGCSceneContentView.h"
#import "KGCFileDropView.h"
#import "KGCAnswer.h"

#import "KGCAnswerCell.h"
#import "KGCAnswerPointsCell.h"
#import <AVFoundation/AVFoundation.h>

@interface KGCMenuSpriteController () <NSTableViewDataSource, NSTableViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteTypePopUp;
@property (nonatomic, weak) IBOutlet NSPopUpButton *soundTypePopUp;
@property (nonatomic, weak) IBOutlet NSTableView *soundTableView;
@property (nonatomic, weak) IBOutlet NSButton *soundPlayButton;

@end

@implementation KGCMenuSpriteController
{
	NSMutableArray *_currentAnswerSprites;
	AVAudioPlayer *_audioPlayer;
}

#pragma mark - Initial Methods

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	[self update];
}

- (void)update
{
	NSNumber *spriteType = [self objectForPropertyNamed:@"spriteType" inArray:[self sceneObjects]];
	if (spriteType)
	{
		[[self spriteTypePopUp] selectItemAtIndex:spriteType == 0 ? 0 : 1];
	}
	else
	{
		[[self spriteTypePopUp] setTitle:NSLocalizedString(@"Multiple Items Selected", nil)];
	}
	
	[self changeSoundType:[self soundTypePopUp]];
	[[self soundTableView] reloadData];
}

#pragma mark - Interface Methods

- (IBAction)changeSpriteType:(id)sender
{	
	NSInteger spriteType = [sender indexOfSelectedItem];
	for (KGCSprite *sprite in [self sceneObjects])
	{
		[sprite setSpriteType:spriteType == 0 ? 0 : 3];	
	}
}

- (IBAction)changeSoundType:(id)sender
{
	[[self soundTableView] reloadData];
}

- (IBAction)addSound:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"mp3", @"m4a", @"aac"]];
	[openPanel beginSheetModalForWindow:[[[self sceneObjects][0] document] windowForSheet] completionHandler:^ (NSInteger result)
	{
		if (result == NSOKButton)
		{
			for (KGCSprite *sprite in [self sceneObjects])
			{
				[sprite addSoundAtURL:[openPanel URL] forKey:[self currentSoundKey]];
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
	[[self soundPlayButton] setEnabled:[[self soundTableView] selectedRow] != -1];
}

#pragma mark - AudioPlayer Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[self soundPlayButton] setTitle:NSLocalizedString(@"Play", nil)];
	_audioPlayer = nil;
}

#pragma mark - Convenient Methods

- (NSString *)currentSoundKey
{
	NSArray *soundKeys = @[@"MouseEnterSounds", @"MouseClickSounds"];
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	return soundKeys[index];
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
	}
	
	return nil;
}



@end