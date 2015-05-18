//
//  KGCSoundEffectTableCellView.m
//  GameCreator
//
//  Created by Maarten Foukhar on 01-05-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSoundEffectTableCellView.h"
#import <AVFoundation/AVFoundation.h>
#import "KGCGame.h"
#import "KGCScene.h"

@interface KGCSoundEffectTableCellView () <AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet NSImageView *iconImageView;
@property (nonatomic, weak) IBOutlet NSTextField *soundNameField;
@property (nonatomic, weak) IBOutlet NSButton *playButton;

@end

@implementation KGCSoundEffectTableCellView
{
	AVAudioPlayer *_audioPlayer;
	KGCGameSet *_gameSet;
	NSString *_soundEffectKey;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[[self soundNameField] setStringValue:NSLocalizedString(@"None", nil)];
	[[self iconImageView] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:@"mp3"]];
}

- (void)setupWithGameSet:(KGCGameSet *)gameSet soundEffectKey:(NSString *)soundEffectKey
{
	_gameSet = gameSet;
	_soundEffectKey = soundEffectKey;
	
	NSArray *soundNames = [_gameSet soundsForKey:soundEffectKey];
	
	if (soundNames && [soundNames count] > 0)
	{
		NSString *audioName = soundNames[0];
		[[self soundNameField] setStringValue:audioName];
		[[self playButton] setEnabled:YES];
	}
	else
	{
		[[self playButton] setEnabled:NO];
	}
}

- (IBAction)chooseSound:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"mp3", @"m4a", @"aac"]];
	NSInteger result = [openPanel runModal];
	if (result == NSOKButton)
	{
		NSURL *url = [openPanel URL];
		[_gameSet setSoundAtURL:url forKey:_soundEffectKey];
		
		for (KGCGame *game in [_gameSet games])
		{
			[game setSoundAtURL:url forKey:_soundEffectKey];
			for (KGCScene *scene in [game scenes])
			{
				[scene setSoundAtURL:url forKey:_soundEffectKey];
			}
		}
		
		[self setupWithGameSet:_gameSet soundEffectKey:_soundEffectKey];
	}
}

- (IBAction)play:(id)sender
{
	NSString *soundName = [_gameSet soundsForKey:_soundEffectKey][0];

	if (!_audioPlayer)
	{
		[sender setTitle:NSLocalizedString(@"Stop", nil)];
	
		KGCResourceController *resourceController = [[_gameSet document] resourceController];
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

#pragma mark - AudioPLayer Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[self playButton] setTitle:NSLocalizedString(@"Play", nil)];
	_audioPlayer = nil;
}

@end