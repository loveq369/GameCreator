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
@property (nonatomic, weak) IBOutlet NSButton *autoFadeInButton;
@property (nonatomic, weak) IBOutlet NSButton *autoFadeOutButton;

@end

@implementation KGCSceneController

#pragma mark - Initial Methods

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	[super setupWithSceneLayer:sceneLayer];
	
	KGCSceneObject *sceneObject = [self sceneObject];
	KGCScene *scene = [self scene];
	
	[[self sceneNameField] setStringValue:[sceneObject name]];
		
	NSString *displayName = @"None";
	NSString *imageName = [scene imageName];
	if (imageName)
	{
		displayName = imageName;
	}
	
	[[self sceneImageNameLabel] setStringValue:displayName];
	[[self autoFadeInButton] setState:[scene autoFadeIn]];
	[[self autoFadeOutButton] setState:[scene autoFadeOut]];
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
	[[self sceneObject] setName:[sender stringValue]];
}

- (IBAction)chooseSceneImage:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png"]];
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^ (NSModalResponse returnCode)
	{
		[[self scene] setImageURL:[openPanel URL]];
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

- (KGCScene *)scene
{
	return (KGCScene *)[self sceneObject];
}

@end