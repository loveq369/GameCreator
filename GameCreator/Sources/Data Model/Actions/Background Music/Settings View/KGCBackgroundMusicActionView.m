//
//	KGCBackgroundMusicActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCBackgroundMusicActionView.h"
#import "KGCBackgroundMusicAction.h"
#import <AVFoundation/AVFoundation.h>
#import "KGCSceneContentView.h"
#import "KGCSpriteLayer.h"

@interface KGCBackgroundMusicActionView () <AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet NSImageView *iconImageView;
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSButton *playButton;

@end


@implementation KGCBackgroundMusicActionView
{
	KGCBackgroundMusicAction *_action;
	AVAudioPlayer *_audioPlayer;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[[self iconImageView] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:@"mp3"]];
}

- (void)setupWithSceneLayers:(NSArray *)sceneLayers withSettingsObject:(id)object
{
	[super setupWithSceneLayers:sceneLayers withSettingsObject:object];
	
	_action = object;
	[[self nameField] setStringValue:[_action audioName]];
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
			[[self nameField] setStringValue:[_action audioName]];
		}
	}];
}

- (IBAction)play:(id)sender
{
	if (!_audioPlayer)
	{
		[[self playButton] setTitle:@"Stop"];
	
		KGCResourceController *resourceController = [[self sceneLayers][0] resourceController];
		NSData *data = [resourceController audioDataForName:[_action audioName]];
		_audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
		[_audioPlayer setDelegate:self];
		[_audioPlayer play];
	}
	else
	{
		[[self playButton] setTitle:@"Play"];
		[_audioPlayer stop];
		_audioPlayer = nil;
	}
}

#pragma mark - AudioPLayer Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[self playButton] setTitle:@"Play"];
	_audioPlayer = nil;
}


@end