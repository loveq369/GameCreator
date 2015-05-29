//
//	KGCSceneController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneController.h"
#import "KGCSceneLayer.h"
#import "KGCFileDropView.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"

@interface KGCSceneController () <KGCFileDropViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *sceneNameField;
@property (nonatomic, weak) IBOutlet KGCFileDropView *sceneDropField;
@property (nonatomic, weak) IBOutlet NSImageView *sceneIconView;
@property (nonatomic, weak) IBOutlet NSTextField *sceneImageNameLabel;
@property (nonatomic, weak) IBOutlet NSButton *sceneImageClearButton;
@property (nonatomic, weak) IBOutlet NSButton *autoFadeInButton;
@property (nonatomic, weak) IBOutlet NSButton *autoFadeOutButton;

@end

@implementation KGCSceneController

#pragma mark - Initial Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSTextField *sceneNameField = [self sceneNameField];
	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		[sceneNameField setStringValue:[(KGCScene *)[self sceneObjects][0] name]];
		[sceneNameField setEnabled:YES];
	}
	else
	{
		[sceneNameField setStringValue:NSLocalizedString(@"<Multiple Items Selected>", nil)];
		[sceneNameField setEnabled:NO];
	}
		
	NSString *displayName = NSLocalizedString(@"None", nil);
	NSString *imageName = [self imageName];
	if (imageName)
	{
		displayName = imageName;
	}
	
	[[self sceneImageNameLabel] setStringValue:displayName];
	[[self sceneImageClearButton] setHidden:imageName == nil];
	
	NSNumber *number = [self objectForPropertyNamed:@"autoFadeIn" inArray:[self sceneObjects]];
	[self setObjectValue:number inCheckBox:[self autoFadeInButton]];
	
	number = [self objectForPropertyNamed:@"autoFadeOut" inArray:[self sceneObjects]];
	[self setObjectValue:number inCheckBox:[self autoFadeOutButton]];
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	NSImage *pngIconImage = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
	[[self sceneIconView] setImage:pngIconImage];
}

#pragma mark - Interface Methods

- (IBAction)changeSceneIdentifier:(id)sender
{
	[(KGCScene *)[self sceneObjects][0] setName:[sender stringValue]];
}

- (IBAction)chooseSceneImage:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png"]];
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^ (NSModalResponse returnCode)
	{
		if (returnCode == NSOKButton)
		{
			[self setImageAtURL:[openPanel URL]];
			NSString *imageName = [self imageName];
			[[self sceneImageNameLabel] setStringValue:imageName ? imageName : NSLocalizedString(@"None", nil)];
			[[self sceneImageClearButton] setHidden:imageName == nil];
		}
	}];
}

- (IBAction)removeSpriteImage:(id)sender
{
	[[self sceneObjects] makeObjectsPerformSelector:@selector(clearImage)];
	[[self sceneImageNameLabel] setStringValue:NSLocalizedString(@"None", nil)];
	[[self sceneImageClearButton] setHidden:YES];
}

- (IBAction)changeAutoFadeIn:(id)sender
{
	[self setAutoFadeIn:[sender state]];
}

- (IBAction)changeAutoFadeOut:(id)sender
{
	[self setAutoFadeOut:[sender state]];
}

#pragma mark - File Drop View Delegate Methods

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths
{
	if ([filePaths count] > 0)
	{
		NSURL *url = [[NSURL alloc] initFileURLWithPath:filePaths[0]];
		[self setImageAtURL:url];
		[[self sceneImageNameLabel] setStringValue:[self imageName]];
	}
}

#pragma mark - Multi getter/setter methods

- (NSString *)imageName
{
	return [self objectForPropertyNamed:@"imageName" inArray:[self sceneObjects]];
}

- (void)setImageAtURL:(NSURL *)imageURL
{
	[[self sceneObjects] makeObjectsPerformSelector:@selector(setImageURL:) withObject:imageURL];
}

- (void)setAutoFadeIn:(BOOL)autoFadeIn
{
	for (KGCScene *scene in [self sceneObjects])
	{
		[scene setAutoFadeIn:autoFadeIn];
	}
}

- (void)setAutoFadeOut:(BOOL)autoFadeOut
{
	for (KGCScene *scene in [self sceneObjects])
	{
		[scene setAutoFadeOut:autoFadeOut];
	}
}

@end