//
//	KGCAudioEffectActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAudioEffectActionView.h"
#import "KGCAudioEffectAction.h"
#import "KGCFileDropView.h"
#import <AVFoundation/AVFoundation.h>
#import "KGCSceneContentView.h"
#import "KGCSceneObject.h"

@interface KGCAudioEffectActionView () <AVAudioPlayerDelegate, KGCFileDropViewDelegate>

@property (nonatomic, weak) IBOutlet NSImageView *iconImageView;
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSButton *playButton;

@end

@implementation KGCAudioEffectActionView
{
	KGCAudioEffectAction *_action;
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
	[[self nameField] setStringValue:[_action audioEffectName]];
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
			[[self nameField] setStringValue:[_action audioEffectName]];
		}
	}];
}

- (IBAction)play:(id)sender
{
	if (!_audioPlayer)
	{
		[[self playButton] setTitle:@"Stop"];
	
		KGCResourceController *resourceController = [[[self sceneObjects][0] document] resourceController];
		NSData *data = [resourceController audioDataForName:[_action audioEffectName]];
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
		[[self nameField] setStringValue:[_action audioEffectName]];
	}
}

@end