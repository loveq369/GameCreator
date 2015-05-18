//
//	KGCSoundTemplateActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 19-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSoundTemplateActionView.h"
#import "KGCSoundTemplateAction.h"
#import "KGCFileDropView.h"
#import <AVFoundation/AVFoundation.h>
#import "KGCSceneContentView.h"
#import "KGCSpriteLayer.h"

@interface KGCSoundTemplateActionView () <AVAudioPlayerDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSImageView *iconImageView;
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSButton *loopButton;
@property (nonatomic, weak) IBOutlet NSButton *stopOtherSoundsButton;
@property (nonatomic, weak) IBOutlet NSButton *playButton;

@end

@implementation KGCSoundTemplateActionView
{
	KGCSoundTemplateAction *_action;
	AVAudioPlayer *_audioPlayer;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[[self iconImageView] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:@"mp3"]];
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_action = object;
  
  NSString *soundName = [_action soundName];
	[[self nameField] setStringValue:soundName ? soundName : NSLocalizedString(@"None", nil)];
	[[self loopButton] setState:[_action loops]];
	[[self stopOtherSoundsButton] setState:[_action stopOtherSounds]];
}

- (IBAction)chooseSound:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"mp3", @"m4a", @"aac"]];
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^ (NSModalResponse returnCode)
	{
		if (returnCode == NSOKButton)
		{
			[_action setSoundAtURL:[openPanel URL]];
			[[self nameField] setStringValue:[_action soundName]];
		}
	}];
}

- (IBAction)changeLoops:(id)sender
{
	[_action setLoop:[sender state]];
}

- (IBAction)changeStopOtherSounds:(id)sender
{
	[_action setStopOtherSounds:[sender state]];
}

- (IBAction)play:(id)sender
{
	if (!_audioPlayer)
	{
		[[self playButton] setTitle:@"Stop"];
	
		KGCResourceController *resourceController = [[_action document] resourceController];
		NSData *data = [resourceController audioDataForName:[_action soundName]];
		_audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
		[_audioPlayer setDelegate:self];
		[_audioPlayer play];
	}
	else
	{
		[_audioPlayer stop];
	}
}

#pragma mark - AudioPLayer Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[self playButton] setTitle:@"Play"];
	_audioPlayer = nil;
}

#pragma mark - File Drop View Delegate Methods

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths
{
	if ([filePaths count] > 0)
	{
		NSURL *url = [[NSURL alloc] initFileURLWithPath:filePaths[0]];
		[_action setSoundAtURL:url];
		[[self nameField] setStringValue:[_action soundName]];
	}
}

@end