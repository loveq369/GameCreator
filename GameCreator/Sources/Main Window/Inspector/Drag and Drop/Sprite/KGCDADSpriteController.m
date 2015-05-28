//
//	KGCDADSpriteController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADSpriteController.h"
#import "KGCDADInspector.h"
#import "KGCSprite.h"
#import "KGCScene.h"
#import "KGCSceneContentView.h"
#import "KGCFileDropView.h"
#import "KGCAnswer.h"

#import "KGCAnswerCell.h"
#import "KGCAnswerPointsCell.h"

@interface KGCDADSpriteController () <NSTableViewDataSource, NSTableViewDelegate, KGCFileDropViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *spriteNameField;
@property (nonatomic, weak) IBOutlet KGCFileDropView *spriteDropField;
@property (nonatomic, weak) IBOutlet NSImageView *spriteIconView;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImageNameLabel;
@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteImageTypePopUp;
@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteTypePopUp;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionXField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionYField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteScaleField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteZOrderField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteOpacityField;
@property (nonatomic, weak) IBOutlet NSSlider *spriteOpacitySlider;
@property (nonatomic, weak) IBOutlet NSTabView *spriteTypeTabView;
@property (nonatomic, weak) IBOutlet NSTextField *spriteAnswerMaxField;
@property (nonatomic, weak) IBOutlet NSTableView *spriteAnswerTableView;
@property (nonatomic, weak) IBOutlet NSButton *spriteAnswerAddButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteAnswerAddPopUp;
@property (nonatomic, weak) IBOutlet NSTextField *spriteMaxItemsField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteGroupNameField;
@property (nonatomic, weak) IBOutlet NSView *spriteAnswerSettingsView;
@property (nonatomic, weak) IBOutlet NSTextField *spriteAnswerPointsField;
@property (nonatomic, weak) IBOutlet NSButton *spriteAnswerDropPositionButton;
@property (nonatomic, weak) IBOutlet NSTextField *spriteAnswerDropPositionXField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteAnswerDropPositionYField;

@end

@implementation KGCDADSpriteController
{
	NSMutableArray *_currentAnswerSprites;
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
	[[self spriteTypePopUp] selectItemAtIndex:spriteType];
	
	NSInteger lastSpriteImageType = [[NSUserDefaults standardUserDefaults] integerForKey:@"KGCInspectorLastSelectedSpriteImageType"];
	[[self spriteImageTypePopUp] selectItemAtIndex:lastSpriteImageType];
	
	NSString *spriteImageName = lastSpriteImageType == 0 ? [sprite imageName] : [sprite backgroundImageName];
	[[self spriteImageNameLabel] setStringValue:spriteImageName ? spriteImageName : NSLocalizedString(@"None", nil)];
	
	[self updateVisualProperties];	
		
	[[self spriteTypeTabView] selectTabViewItemAtIndex:spriteType];
	[[self spriteAnswerMaxField] setIntegerValue:[sprite maxAnswerCount]];
	[[self spriteMaxItemsField] setIntegerValue:[sprite maxGroupItems]];
	[[self spriteAnswerSettingsView] setHidden:[[self spriteAnswerTableView] selectedRow] == -1];
	
	NSString *groupName = [sprite groupName];
	[[self spriteGroupNameField] setStringValue:groupName ? groupName : @""];
	
	NSTableView *spriteAnswerTableView = [self spriteAnswerTableView];
	NSInteger index = [spriteAnswerTableView selectedRow];
	[spriteAnswerTableView reloadData];
	[spriteAnswerTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
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
		if (returnCode == NSOKButton)
		{
			KGCSprite *sprite = [self sprite];
			BOOL normalImage = [[self spriteImageTypePopUp] indexOfSelectedItem] == 0;
			if (normalImage)
			{
				[sprite setImageURL:[openPanel URL]];
			}
			else
			{
				[sprite setBackgroundImageURL:[openPanel URL]];
			}
			
			NSString *spriteImageName = normalImage ? [sprite imageName] : [sprite backgroundImageName];
			[[self spriteImageNameLabel] setStringValue:spriteImageName ? spriteImageName : NSLocalizedString(@"None", nil)];
		}
	}];
}

- (IBAction)changeSpriteImageType:(id)sender
{
	NSUInteger index = [sender indexOfSelectedItem];
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"KGCInspectorLastSelectedSpriteImageType"];

	KGCSprite *sprite = [self sprite];
	NSString *spriteImageName = index == 0 ? [sprite imageName] : [sprite backgroundImageName];
	[[self spriteImageNameLabel] setStringValue:spriteImageName ? spriteImageName : NSLocalizedString(@"None", nil)];
}

- (IBAction)changeSpriteType:(id)sender
{	
	NSInteger spriteType = [sender indexOfSelectedItem];
	[[self sprite] setSpriteType:spriteType];	
	[[self spriteTypeTabView] selectTabViewItemAtIndex:spriteType];
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

- (IBAction)changeSpriteMaxAnswerCount:(id)sender
{
	[[self sprite] setMaxAnswerCount:[sender integerValue]];
}

- (IBAction)addSpriteAnswer:(id)sender
{
	if (sender == [self spriteAnswerAddButton])
	{
		KGCSprite *sprite = [self sprite];
	
		NSPopUpButton *spriteAnswerAddPopUp = [self spriteAnswerAddPopUp];
		[spriteAnswerAddPopUp removeAllItems];
		[spriteAnswerAddPopUp addItemWithTitle:@""];
		NSArray *sprites = [(KGCScene *)[sprite parentObject] sprites];
		
		NSMutableArray *currentAnswerIdentifiers = [[NSMutableArray alloc] init];
		for (KGCAnswer *answer in [sprite answers])
		{
			[currentAnswerIdentifiers addObject:[answer answerIdentifier]];
		}
		
		_currentAnswerSprites = [[NSMutableArray alloc] init];
		for (KGCSprite *subSprite in sprites)
		{
			NSString *identifier = [subSprite identifier];
			if ([subSprite spriteType] == 2 && ![currentAnswerIdentifiers containsObject:identifier] && sprite != subSprite)
			{
				[spriteAnswerAddPopUp addItemWithTitle:[subSprite name]];
				[_currentAnswerSprites addObject:subSprite];
			}
		}
		if ([[spriteAnswerAddPopUp itemArray] count] == 1)
		{
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No Available Answers" action:NULL keyEquivalent:@""];
			[item setEnabled:NO];
			[[spriteAnswerAddPopUp menu] addItem:item];
		}
	
		[[self spriteAnswerAddPopUp] performClick:nil];
	}
	else
	{
		KGCSprite *currentAnswerSprite = _currentAnswerSprites[[sender indexOfSelectedItem] -1];
		KGCAnswer *answer = [KGCAnswer answerWithIdentifier:[currentAnswerSprite identifier] document:[currentAnswerSprite document]];
		[[self sprite] addAnswer:answer];
		[[self spriteAnswerTableView] reloadData];
	}
}

- (IBAction)deleteSpriteAnswer:(id)sender
{
	NSTableView *spriteAnswerTableView = [self spriteAnswerTableView];
	NSInteger row = [spriteAnswerTableView selectedRow];
	
	KGCSprite *sprite = [self sprite];
	KGCAnswer *answer = [sprite answers][row];
	[sprite removeAnswer:answer];
	
	[spriteAnswerTableView reloadData];
}

- (IBAction)changeMaxGroupItems:(id)sender
{
	[[self sprite] setMaxGroupItems:[sender integerValue]];
}

- (IBAction)changeGroupName:(id)sender
{
	[[self sprite] setGroupName:[sender stringValue]];
}

- (IBAction)changePoints:(id)sender
{
	[[self currentAnswer] setPoints:[sender doubleValue]];
}

- (IBAction)changeAutoDrop:(id)sender
{
	BOOL autoDropPosition = [sender state];
	[[self spriteAnswerDropPositionXField] setEnabled:autoDropPosition];
	[[self spriteAnswerDropPositionYField] setEnabled:autoDropPosition];
	[[self currentAnswer] setAutoDropPositionEnabled:autoDropPosition];
}

- (IBAction)changeDropPosition:(id)sender
{
	CGFloat x = [[self spriteAnswerDropPositionXField] doubleValue];
	CGFloat y = [[self spriteAnswerDropPositionYField] doubleValue];
	[[self currentAnswer] setDropPosition:NSMakePoint(x, y)];
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[[self sprite] answers] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCAnswer *answer = [[self sprite] answers][row];
	NSString *name = @"Unknown";
	
	KGCScene *scene = (KGCScene *)[[self sprite] parentObject];
	for (KGCSprite *sprite in [scene sprites])
	{
		if ([[sprite identifier] isEqualToString:[answer answerIdentifier]])
		{
			name = [sprite name];
			break;
		}
	}
	
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"AnswerTableCell" owner:nil];
	[[tableCellView textField] setStringValue:name];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tableView = [notification object];
	if (tableView == [self spriteAnswerTableView])
	{	
		[[self spriteAnswerSettingsView] setHidden:[tableView selectedRow] == -1];
		
		KGCAnswer *currentAnswer = [self currentAnswer];
		if (currentAnswer)
		{
			NSPoint position = [currentAnswer dropPosition];
			NSTextField *spriteAnswerDropPositionXField = [self spriteAnswerDropPositionXField];
			[spriteAnswerDropPositionXField setDoubleValue:position.x];
			NSTextField *spriteAnswerDropPositionYField = [self spriteAnswerDropPositionYField];
			[spriteAnswerDropPositionYField setDoubleValue:position.y];
		
			BOOL autoDropEnabled = [currentAnswer isAutoDropPositionEnabled];
			[[self spriteAnswerDropPositionButton] setState:autoDropEnabled];
			[spriteAnswerDropPositionXField setEnabled:autoDropEnabled];
			[spriteAnswerDropPositionYField setEnabled:autoDropEnabled];
		
			[[self spriteAnswerPointsField] setIntegerValue:[currentAnswer points]];
		}
	}
}

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{	
		// Support for us being a dragging source	
		return nil;
}

#pragma mark - File Drop View Delegate Methods

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths
{
	if ([filePaths count] > 0)
	{
		NSURL *url = [[NSURL alloc] initFileURLWithPath:filePaths[0]];
		
		KGCSprite *sprite = [self sprite];
		BOOL normalImage = [[self spriteImageTypePopUp] indexOfSelectedItem] == 0;
		if (normalImage)
		{
			[sprite setImageURL:url];
		}
		else
		{
			[sprite setBackgroundImageURL:url];
		}
		
		NSString *spriteImageName = normalImage ? [sprite imageName] : [sprite backgroundImageName];
		[[self spriteImageNameLabel] setStringValue:spriteImageName ? spriteImageName : NSLocalizedString(@"None", nil)];
	}
}

#pragma mark - Convenient Methods

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

- (KGCAnswer *)currentAnswer
{	
	NSUInteger row = [[self spriteAnswerTableView] selectedRow];
	
	if (row != -1)
	{
		return [[self sprite] answers][row];
	}
	
	return nil;
}

@end