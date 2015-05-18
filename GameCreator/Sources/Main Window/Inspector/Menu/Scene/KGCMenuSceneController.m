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
#import "KGCFileDropView.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"
#import <AVFoundation/AVFoundation.h>

@interface KGCMenuSceneController () <KGCFileDropViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet KGCFileDropView *sceneDropField;
@property (nonatomic, weak) IBOutlet NSImageView *sceneIconView;
@property (nonatomic, weak) IBOutlet NSTextField *sceneImageNameLabel;

@property (nonatomic, weak) IBOutlet NSButton *autoFadeInButton;
@property (nonatomic, weak) IBOutlet NSButton *autoFadeOutButton;

@property (nonatomic, weak) IBOutlet NSPopUpButton *soundTypePopUp;
@property (nonatomic, weak) IBOutlet NSTableView *soundTableView;
@property (nonatomic, weak) IBOutlet NSButton *soundPlayButton;

@property (nonatomic, weak) IBOutlet NSTabView *settingsTabView;
@property (nonatomic, weak) IBOutlet NSTextField *noInteractionDelayField;

@end

@implementation KGCMenuSceneController
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
	
	[[self autoFadeInButton] setState:[scene autoFadeIn]];
	[[self autoFadeOutButton] setState:[scene autoFadeOut]];
	
	[self changeSoundType:[self soundTypePopUp]];
	[[self soundTableView] reloadData];
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

- (IBAction)changeAutoFadeIn:(id)sender
{
	[[self scene] setAutoFadeIn:[sender state]];
}

- (IBAction)changeAutoFadeOut:(id)sender
{
	[[self scene] setAutoFadeOut:[sender state]];
}

- (IBAction)changeSoundType:(id)sender
{
	[[self soundTableView] reloadData];
	[[self settingsTabView] selectTabViewItemAtIndex:[sender indexOfSelectedItem]];
}

- (IBAction)addSound:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"mp3", @"m4a", @"aac"]];
	[openPanel beginSheetModalForWindow:[[[self sceneObject] document] windowForSheet] completionHandler:^ (NSInteger result)
	{
		if (result == NSOKButton)
		{
			[[self scene] addSoundAtURL:[openPanel URL] forKey:[self currentSoundKey]];
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
	if (rowSelected && index == 2)
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
		
		[scene setImageURL:url];
		[[self sceneImageNameLabel] setStringValue:[scene imageName]];
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
	NSArray *soundKeys = @[@"BackgroundSounds", @"IntroSounds", @"NoInteractionSounds", @"HintSounds", @"LeaveSounds"];
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