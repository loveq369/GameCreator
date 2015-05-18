//
//	KGCDADShapeSceneController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADShapeSceneController.h"
#import "KGCDADInspector.h"
#import "KGCSceneLayer.h"
#import "KGCFileDropView.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"

@interface KGCDADShapeSceneController () <KGCFileDropViewDelegate>

@property (nonatomic, weak) IBOutlet KGCFileDropView *sceneDropField;
@property (nonatomic, weak) IBOutlet NSImageView *sceneIconView;
@property (nonatomic, weak) IBOutlet NSTextField *sceneImageNameLabel;
@property (nonatomic, weak) IBOutlet NSTextField *sceneRequiredPointsField;
@property (nonatomic, weak) IBOutlet NSButton *sceneRequireConfirmationButton;

@end

@implementation KGCDADShapeSceneController

#pragma mark - Initial Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSImage *pngIconImage = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
	[[self sceneIconView] setImage:pngIconImage];
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
}

#pragma mark - Interface Methods

- (IBAction)chooseSceneImage:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png", @"jpg"]];
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^ (NSModalResponse returnCode)
	{
		[[self scene] setImageURL:[openPanel URL]];
	}];
}

- (IBAction)changeSceneRequiredPoints:(id)sender
{
	[[self scene] setRequiredPoints:[sender doubleValue]];
}

- (IBAction)changeSceneRequireConfirmation:(id)sender
{
	[[self scene] setRequireConfirmation:[sender boolValue]];
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

#pragma mark - Convenient Methods

- (KGCSceneContentView *)sceneContentView
{
	return [[self sceneLayer] sceneContentView];
}

- (KGCScene *)scene
{
	return (KGCScene *)[self sceneObject];
}

@end