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

@interface KGCMenuSpriteController () <NSTableViewDataSource, NSTableViewDelegate, KGCFileDropViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *spriteNameField;
@property (nonatomic, weak) IBOutlet KGCFileDropView *spriteDropField;
@property (nonatomic, weak) IBOutlet NSImageView *spriteIconView;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImageNameLabel;
@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteTypePopUp;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionXField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionYField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteScaleField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteZOrderField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteOpacityField;
@property (nonatomic, weak) IBOutlet NSSlider *spriteOpacitySlider;

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

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSImage *pngIconImage = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
	[[self spriteIconView] setImage:pngIconImage];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	[super setupWithSceneLayer:sceneLayer];
	[self update];
}

- (void)update
{
	KGCSprite *sprite = [self sprite];	
	NSInteger spriteType = [sprite spriteType];
	
	[[self spriteNameField] setStringValue:[sprite name]];
	[[self spriteImageNameLabel] setStringValue:[sprite imageName]];
	[[self spriteTypePopUp] selectItemAtIndex:spriteType == 0 ? 0 : 1];
	
	[self changeSoundType:[self soundTypePopUp]];
	[[self soundTableView] reloadData];
	
	[self updateVisualProperties];	
}

#pragma mark - Interface Methods

- (IBAction)changeSpriteIdentifier:(id)sender
{
	[[self sprite] setName:[sender stringValue]];
}

- (IBAction)chooseSpriteImage:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png", @"jpg"]];
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^ (NSModalResponse returnCode)
	{
		[[self sprite] setImageURL:[openPanel URL]];
	}];
}

- (IBAction)changeSpriteType:(id)sender
{	
	NSInteger spriteType = [sender indexOfSelectedItem];
	[[self sprite] setSpriteType:spriteType == 0 ? 0 : 3];	
}

- (IBAction)changeSpritePosition:(id)sender
{
	CGFloat x = [[self spriteImagePositionXField] doubleValue];
	CGFloat y = [[self spriteImagePositionYField] doubleValue];
	
	KGCSprite *sprite = [self sprite];
	KGCDocumentEditMode editMode = [[sprite document] editMode];
	if (editMode == KGCDocumentEditModeNormal)
	{
		[sprite setPosition:CGPointMake(x, y)];
	}
	else
	{
		[sprite setInitialPosition:CGPointMake(x, y)];
	}
}

- (IBAction)changeSpriteScale:(id)sender
{
	CGFloat scale = [sender doubleValue];
	
	KGCSprite *sprite = [self sprite];
	KGCDocumentEditMode editMode = [[sprite document] editMode];
	if (editMode == KGCDocumentEditModeNormal)
	{
		[sprite setScale:scale];
	}
	else
	{
		[sprite setInitialScale:scale];
	}
}

- (IBAction)changeSpriteZOrder:(id)sender
{
	NSInteger zOrder = [sender integerValue];
	
	KGCSprite *sprite = [self sprite];
	KGCDocumentEditMode editMode = [[sprite document] editMode];
	if (editMode == KGCDocumentEditModeNormal)
	{
		[sprite setZOrder:zOrder];
	}
	else
	{
		[sprite setInitialZOrder:zOrder];
	}
}

- (IBAction)changeSpriteAlpha:(id)sender
{
	CGFloat alpha;
	if (sender == [self spriteOpacitySlider])
	{
		alpha = [[self spriteOpacitySlider] doubleValue];
		[[self spriteOpacityField] setStringValue:[NSString stringWithFormat:@"%.0f", alpha]];
	}
	else
	{
		alpha = [[self spriteOpacityField] doubleValue];
		[[self spriteOpacitySlider] setDoubleValue:alpha];
	}
	
	KGCSprite *sprite = [self sprite];
	KGCDocumentEditMode editMode = [[sprite document] editMode];
	if (editMode == KGCDocumentEditModeNormal)
	{
		[sprite setAlpha:alpha / 100.0];
	}
	else
	{
		[sprite setInitialAlpha:alpha / 100.0];
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
	[openPanel beginSheetModalForWindow:[[[self sceneObject] document] windowForSheet] completionHandler:^ (NSInteger result)
	{
		if (result == NSOKButton)
		{
			[[self sprite] addSoundAtURL:[openPanel URL] forKey:[self currentSoundKey]];
			[[self soundTableView] reloadData];
		}
	}];
}

- (IBAction)removeSound:(id)sender
{
	NSString *key = [self currentSoundKey];
	
	KGCSprite *sprite = [self sprite];
	NSArray *soundNames = [sprite soundsForKey:[self currentSoundKey]];
	NSTableView *soundTableView = [self soundTableView];
	NSInteger soundIndex = [soundTableView selectedRow];
	[sprite removeSoundNamed:soundNames[soundIndex] forKey:key];
	[soundTableView reloadData];
}

- (IBAction)play:(id)sender
{
	KGCSprite *sprite = [self sprite];
	NSArray *soundNames = [sprite soundsForKey:[self currentSoundKey]];
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

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	KGCSprite *sprite = [self sprite];
	NSArray *soundNames = [sprite soundsForKey:[self currentSoundKey]];

	return [soundNames count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCSprite *sprite = [self sprite];
	NSArray *soundNames = [sprite soundsForKey:[self currentSoundKey]];
	
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"SoundTableCell" owner:nil];
	[[tableCellView textField] setStringValue:soundNames[row]];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[[self soundPlayButton] setEnabled:[[self soundTableView] selectedRow] != -1];
}

#pragma mark - File Drop View Delegate Methods

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths
{
	if ([filePaths count] > 0)
	{
		NSURL *url = [[NSURL alloc] initFileURLWithPath:filePaths[0]];
		
		KGCSprite *sprite = [self sprite];
		[sprite setImageURL:url];
		[[self spriteImageNameLabel] setStringValue:[sprite imageName]];
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
	NSArray *soundKeys = @[@"MouseEnterSounds", @"MouseClickSounds"];
	NSInteger index = [[self soundTypePopUp] indexOfSelectedItem];
	return soundKeys[index];
}

- (KGCSprite *)sprite
{
	return (KGCSprite *)[self sceneObject];
}

- (void)updatePosition:(NSNotification *)notification
{
	KGCSprite *sprite = [self sprite];
	CGPoint position = [sprite position];

	[[self spriteImagePositionXField] setDoubleValue:position.x];
	[[self spriteImagePositionYField] setDoubleValue:position.y];
}

- (void)updateVisualProperties
{
	KGCSprite *sprite = [self sprite];
	KGCDocumentEditMode editMode = [[sprite document] editMode];
	BOOL normalMode = (editMode == KGCDocumentEditModeNormal);
	
	CGPoint position = normalMode ? [sprite position] : [sprite initialPosition];
	[[self spriteImagePositionXField] setDoubleValue:position.x];
	[[self spriteImagePositionYField] setDoubleValue:position.y];
	
	[[self spriteScaleField] setDoubleValue:normalMode ? [sprite scale] : [sprite initialScale]];
	[[self spriteZOrderField] setIntegerValue:normalMode ? [sprite zOrder] : [sprite initialZOrder]];
	
	NSWindow *window = [[self view] window];
	NSEvent *currentEvent = [window currentEvent];
	if ([currentEvent type] != NSLeftMouseDragged && [window isKeyWindow])
	{
		CGFloat alpha = (normalMode ? [sprite alpha] : [sprite initialAlpha]) * 100.0;
		[[self spriteOpacityField] setDoubleValue:alpha];
		[[self spriteOpacitySlider] setDoubleValue:alpha];
	}
}

@end