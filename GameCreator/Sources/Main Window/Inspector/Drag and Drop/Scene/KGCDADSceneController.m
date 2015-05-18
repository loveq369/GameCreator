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
#import "KGCFileDropView.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"
#import <AVFoundation/AVFoundation.h>

@interface KGCDADSceneController () <KGCFileDropViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet KGCFileDropView *sceneDropField;
@property (nonatomic, weak) IBOutlet NSImageView *sceneIconView;
@property (nonatomic, weak) IBOutlet NSTextField *sceneImageNameLabel;
@property (nonatomic, weak) IBOutlet NSTextField *sceneRequiredPointsField;
@property (nonatomic, weak) IBOutlet NSButton *sceneRequireConfirmationButton;

@property (nonatomic, weak) IBOutlet NSPopUpButton *soundTypePopUp;
@property (nonatomic, weak) IBOutlet NSTableView *soundTableView;
@property (nonatomic, weak) IBOutlet NSButton *soundPlayButton;

@property (nonatomic, weak) IBOutlet NSTabView *settingsTabView;
@property (nonatomic, weak) IBOutlet NSTextField *noInteractionDelayField;

@property (nonatomic, weak) IBOutlet NSButton *disableConfirmInteractionButton;
@property (nonatomic, weak) IBOutlet NSButton *autoMoveBackWrongAnswersButton;

@end

@implementation KGCDADSceneController
{
	AVAudioPlayer *_audioPlayer;
}

#pragma mark - Initial Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSImage *pngIconImage = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
	[[self sceneIconView] setImage:pngIconImage];
	
	[[self soundPlayButton] setEnabled:NO];
	[[self settingsTabView] setHidden:YES];
	
	[[self autoMoveBackWrongAnswersButton] setState:NSOffState];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	[super setupWithSceneLayer:sceneLayer];
	
	KGCScene *scene = [self scene];
	
	NSString *displayName = @"None";
	NSString *imageName = [scene imageName];
	if (imageName)
	{
		displayName = imageName;
	}
	
	[[self sceneImageNameLabel] setStringValue:displayName];
	[[self sceneRequiredPointsField] setIntegerValue:[scene requiredPoints]];
	[[self sceneRequireConfirmationButton] setState:[scene requireConfirmation]];
	
	NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"KGCGameSceneSelectedSoundType"];
	NSPopUpButton *soundTypePopUp = [self soundTypePopUp];
	[soundTypePopUp selectItemAtIndex:index];
	
	[self changeSoundType:soundTypePopUp];
	[[self soundTableView] reloadData];
	
	[[self disableConfirmInteractionButton] setState:[scene isDisableConfirmInteraction]];
	[[self autoMoveBackWrongAnswersButton] setState:[scene autoMoveBackWrongAnswers]];
}

#pragma mark - Interface Methods

- (IBAction)chooseSceneImage:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png", @"jpg"]];
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^ (NSModalResponse returnCode)
	{
		if (returnCode == NSOKButton)
		{
			KGCScene *scene = [self scene];
			[scene setImageURL:[openPanel URL]];
			[[self sceneImageNameLabel] setStringValue:[scene imageName]];
		}
	}];
}

- (IBAction)changeSceneRequiredPoints:(id)sender
{
	[[self scene] setRequiredPoints:[sender doubleValue]];
}

- (IBAction)changeSceneRequireConfirmation:(id)sender
{
	[[self scene] setRequireConfirmation:[sender integerValue]];
}

- (IBAction)changeSoundType:(id)sender
{
	NSInteger index = [sender indexOfSelectedItem];
	[[self soundTableView] reloadData];
	
	[[self settingsTabView] selectTabViewItemAtIndex:index];
	
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"KGCGameSceneSelectedSoundType"];
}

- (IBAction)addSound:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"mp3", @"m4a", @"aac"]];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel beginSheetModalForWindow:[[[self sceneObject] document] windowForSheet] completionHandler:^ (NSInteger result)
	{
		if (result == NSOKButton)
		{
			NSArray *urls = [openPanel URLs];
			KGCScene *scene = [self scene];
			NSString *currentSoundKey = [self currentSoundKey];
			for (NSURL *url in urls)
			{
				[scene addSoundAtURL:url forKey:currentSoundKey];
			}
			
			[[self soundTableView] reloadData];
		}
	}];
}

- (IBAction)removeSound:(id)sender
{
	NSString *key = [self currentSoundKey];
	
	KGCScene *scene = [self scene];
	NSArray *soundNames = [scene soundsForKey:[self currentSoundKey]];
	NSTableView *soundTableView = [self soundTableView];
	NSInteger soundIndex = [soundTableView selectedRow];
	[scene removeSoundNamed:soundNames[soundIndex] forKey:key];
	[soundTableView reloadData];
}

- (IBAction)play:(id)sender
{
	KGCScene *scene = [self scene];
	NSArray *soundNames = [scene soundsForKey:[self currentSoundKey]];
	NSInteger soundIndex = [[self soundTableView] selectedRow];
	NSString *soundName = soundNames[soundIndex];

	if (!_audioPlayer)
	{
		[sender setTitle:NSLocalizedString(@"Stop", nil)];
	
		KGCResourceController *resourceController = [[[self sceneObject] document] resourceController];
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

- (IBAction)changeNoInteractionDelay:(id)sender
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	
	KGCScene *scene = [self scene];
	NSMutableDictionary *soundDictionary = [scene soundDictionariesForKey:[self currentSoundKey]][selectedRow];
	soundDictionary[@"NoInteractionDelay"] = @([sender integerValue]);
	[scene updateDictionary];
}

- (IBAction)changeDisableConfirmInteraction:(id)sender
{
	[[self scene] setDisableConfirmInteraction:[sender state]];
}

- (IBAction)changeAutoMoveBackAnswers:(id)sender
{
	[[self scene] setAutoMoveBackWrongAnswers:[sender state]];
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	KGCScene *scene = [self scene];
	NSArray *soundNames = [scene soundsForKey:[self currentSoundKey]];

	return [soundNames count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCScene *scene = [self scene];
	NSArray *soundNames = [scene soundsForKey:[self currentSoundKey]];
	
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"SoundTableCell" owner:nil];
	[[tableCellView textField] setStringValue:soundNames[row]];
	
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
	
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	if (rowSelected && index == 6)
	{
		KGCScene *scene = [self scene];
		NSMutableDictionary *soundDictionary = [scene soundDictionariesForKey:[self currentSoundKey]][selectedRow];
		[[self noInteractionDelayField] setIntegerValue:[soundDictionary[@"NoInteractionDelay"] integerValue]];
	}
}

#pragma mark - File Drop View Delegate Methods

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths
{
	if ([filePaths count] > 0)
	{
		NSURL *url = [[NSURL alloc] initFileURLWithPath:filePaths[0]];
		KGCScene *scene = [self scene];
		
		if (fileDropView == [self sceneDropField])
		{
			[scene setImageURL:url];
			[[self sceneImageNameLabel] setStringValue:[scene imageName]];
		}
	}
}

#pragma mark - AudioPLayer Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[self soundPlayButton] setTitle:NSLocalizedString(@"Play", nil)];
	_audioPlayer = nil;
}

#pragma mark - Convenient Methods

- (NSString *)currentSoundKey
{
	NSArray *soundKeys = @[@"IntroSounds", @"HintSounds", @"SameAnswerSounds", @"CorrectAnswerSounds", @"WrongAnswerSounds", @"AutoAnswerSounds", @"NoInteractionSounds"];
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	return soundKeys[index];
}

- (KGCSceneContentView *)sceneContentView
{
	return [[self sceneLayer] sceneContentView];
}

- (KGCScene *)scene
{
	return (KGCScene *)[self sceneObject];
}

@end