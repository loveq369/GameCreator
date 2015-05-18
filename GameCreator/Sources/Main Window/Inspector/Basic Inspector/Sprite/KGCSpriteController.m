//
//	KGCSpriteController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSpriteController.h"
#import "KGCFileDropView.h"
#import "KGCSprite.h"

@interface KGCSpriteController () <KGCFileDropViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *spriteNameField;
@property (nonatomic, weak) IBOutlet KGCFileDropView *spriteDropField;
@property (nonatomic, weak) IBOutlet NSImageView *spriteIconView;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImageNameLabel;
@property (nonatomic, weak) IBOutlet NSTextField *spriteLabelField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionXField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionYField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteScaleField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteZOrderField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteOpacityField;
@property (nonatomic, weak) IBOutlet NSSlider *spriteOpacitySlider;
@property (nonatomic, weak) IBOutlet NSButton *spriteDraggableCheckBox;
@property (nonatomic, weak) IBOutlet NSButton *spriteInteractionDisabledCheckBox;

@end

@implementation KGCSpriteController

#pragma mark - Initial Methods

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	[super setupWithSceneLayer:sceneLayer];
	
	KGCSprite *sprite = [self sprite];
		
	[[self spriteNameField] setStringValue:[sprite name]];
	[[self spriteImageNameLabel] setStringValue:[sprite imageName]];
	
	NSPoint position = [sprite position];
	[[self spriteImagePositionXField] setDoubleValue:position.x];
	[[self spriteImagePositionYField] setDoubleValue:position.y];
	
	[[self spriteScaleField] setDoubleValue:[sprite scale]];
	[[self spriteZOrderField] setIntegerValue:[sprite zOrder]];
	[[self spriteOpacityField] setDoubleValue:[sprite alpha] * 100.0];
	[[self spriteOpacitySlider] setDoubleValue:[sprite alpha] * 100.0];
	[[self spriteDraggableCheckBox] setState:[sprite isDraggable]];
	[[self spriteInteractionDisabledCheckBox] setState:[sprite isInteractionDisabled]];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSImage *pngIconImage = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
	[[self spriteIconView] setImage:pngIconImage];
	
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self selector:@selector(updatePosition:) name:@"KGCSpritePositionChanged" object:nil];
}

#pragma mark - Interface Methods

- (IBAction)changeSpriteIdentifier:(id)sender
{
	[[self sprite] setName:[sender stringValue]];
}

- (IBAction)chooseSpriteImage:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png"]];
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^ (NSModalResponse returnCode)
	{
		[[self sprite] setImageURL:[openPanel URL]];
	}];
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

- (IBAction)changeMaxLinks:(id)sender
{
	[[self sprite] setMaxLinks:[sender integerValue]];
}

- (IBAction)changeDraggable:(id)sender
{
	[[self sprite] setDraggable:[sender integerValue]];
}

- (IBAction)changeInteractionDisable:(id)sender
{
	[[self sprite] setInteractionDisabled:[sender integerValue]];
}

#pragma mark - File Drop View Delegate Methods

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths
{
	if ([filePaths count] > 0)
	{
		NSURL *url = [[NSURL alloc] initFileURLWithPath:filePaths[0]];
		
		KGCSprite *sprite = [self sprite];
		[[self sprite] setImageURL:url];
		[[self spriteImageNameLabel] setStringValue:[sprite imageName]];
	}
}

#pragma mark - Convenient Methods

- (KGCSprite *)sprite
{
	return (KGCSprite *)[self sceneObject];
}

- (void)updatePosition:(NSNotification *)notification
{
	CGPoint position = [[self sprite] position];

	[[self spriteImagePositionXField] setDoubleValue:position.x];
	[[self spriteImagePositionYField] setDoubleValue:position.y];
}

@end