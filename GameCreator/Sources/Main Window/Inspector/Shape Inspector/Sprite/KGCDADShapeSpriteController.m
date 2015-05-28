//
//	KGCDADShapeSpriteController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADShapeSpriteController.h"
#import "KGCDADInspector.h"
#import "KGCSprite.h"
#import "KGCScene.h"
#import "KGCSceneContentView.h"
#import "KGCFileDropView.h"
#import "KGCGridAnswer.h"

#import "KGCAnswerCell.h"
#import "KGCAnswerPointsCell.h"

@interface KGCDADShapeSpriteController () <KGCFileDropViewDelegate>

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

@property (nonatomic, weak) IBOutlet NSTextField *gridRowsField;
@property (nonatomic, weak) IBOutlet NSTextField *gridColumnsField;
@property (nonatomic, weak) IBOutlet NSTextField *gridMaxShapes;

@property (nonatomic, weak) IBOutlet NSTextField *spriteCountField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteGridRowsField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteGridColumnsField;
@property (nonatomic, weak) IBOutlet NSTableView *gridAnswerTableView;
@property (nonatomic, weak) IBOutlet NSView *gridAnswerSettingsView;
@property (nonatomic, weak) IBOutlet NSTextField *gridAnswerRowField;
@property (nonatomic, weak) IBOutlet NSTextField *gridAnswerColumnField;
@property (nonatomic, weak) IBOutlet NSButton *allAnswersCheckBox;
@property (nonatomic, weak) IBOutlet NSTextField *gridAnswerPointsField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *gridAnswerSpritePopUp;

@end

@implementation KGCDADShapeSpriteController
{
	NSMutableArray *_currentTargetSprites;
}

#pragma mark - Initial Methods

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_currentTargetSprites = [[NSMutableArray alloc] init];
	
	NSImage *pngIconImage = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
	[[self spriteIconView] setImage:pngIconImage];
	
	[[self gridAnswerSettingsView] setHidden:YES];
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
	
	if (spriteType == 1)
	{
		[[self gridRowsField] setIntegerValue:[sprite gridRows]];
		[[self gridColumnsField] setIntegerValue:[sprite gridColumns]];
		[[self gridMaxShapes] setIntegerValue:[sprite maxShapes]];
	}
	else if (spriteType == 2)
	{
		[[self spriteCountField] setIntegerValue:[sprite maxInstanceCount]];
		
		NSSize gridSize = [sprite gridSize];
		[[self spriteGridRowsField] setDoubleValue:gridSize.height];
		[[self spriteGridColumnsField] setDoubleValue:gridSize.width];
	}
	
	[self updateVisualProperties];	
		
	[[self spriteTypeTabView] selectTabViewItemAtIndex:spriteType];
	
	[_currentTargetSprites removeAllObjects];
	[_currentTargetSprites addObject:[NSNull null]];
	[_currentTargetSprites addObject:[NSNull null]];
  
	NSPopUpButton *gridAnswerSpritePopup = [self gridAnswerSpritePopUp];
	[gridAnswerSpritePopup removeAllItems];
	[gridAnswerSpritePopup addItemWithTitle:@"None"];
	[[gridAnswerSpritePopup menu] addItem:[NSMenuItem separatorItem]];
	  
	NSArray *sprites = [(KGCScene *)[sprite parentObject] sprites];
	
	for (KGCSprite *sprite in sprites)
	{
		if ([sprite spriteType] == 1)
		{
			[gridAnswerSpritePopup addItemWithTitle:[sprite name]];
			[_currentTargetSprites addObject:sprite];
		}
	}
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

- (IBAction)changeSpriteCount:(id)sender
{
	[[self sprite] setMaxInstanceCount:[sender integerValue]];
}

- (IBAction)changeSpriteGridSize:(id)sender
{
	CGFloat width = [[self spriteGridColumnsField] doubleValue];
	CGFloat height = [[self spriteGridRowsField] doubleValue];

	[[self sprite] setGridSize:NSMakeSize(width, height)];
}

- (IBAction)changeGridRows:(id)sender
{
	[[self sprite] setGridRows:[sender integerValue]];
}

- (IBAction)changeGridColumns:(id)sender
{
	[[self sprite] setGridColumns:[sender integerValue]];
}

- (IBAction)changeGridMaxShapes:(id)sender
{
	[[self sprite] setMaxShapes:[sender integerValue]];
}

- (IBAction)addGridAnswer:(id)sender
{
	KGCSprite *sprite = [self sprite];
	KGCGridAnswer *gridAnswer = [KGCGridAnswer gridAnswerWitDocument:[sprite document]];
	[sprite addGridAnswer:gridAnswer];
	[[self gridAnswerTableView] reloadData];
}

- (IBAction)removeGridAnswer:(id)sender
{
	NSInteger row = [[self gridAnswerTableView] selectedRow];
	
	if (row != -1)
	{
		KGCGridAnswer *gridAnswer = [[self sprite] gridAnswers][row];
		[[self sprite] removeGridAnswer:gridAnswer];
		[[self gridAnswerTableView] reloadData];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)changeGridAnswerRow:(id)sender
{
	[[self currentGridAnswer] setRow:[sender integerValue]];
	[self updateGridAnswerTableView];
}

- (IBAction)changeGridAnswerColumn:(id)sender
{
	[[self currentGridAnswer] setColumn:[sender integerValue]];
	[self updateGridAnswerTableView];
}

- (IBAction)changeGridAnswerPoints:(id)sender
{
	[[self currentGridAnswer] setPoints:[sender integerValue]];
	[self updateGridAnswerTableView];
}

- (IBAction)changeGridAllAnswers:(id)sender
{
	[[self currentGridAnswer] setAllOtherRowsAndColumns:[sender state]];
	[self updateGridAnswerTableView];
}

- (IBAction)changeTargetGridAnswerSprite:(id)sender
{
	NSInteger index = [sender indexOfSelectedItem];
	if (index == 0)
	{
		[[self currentGridAnswer] setTargetSpriteDictionary:nil];
	}
	else
	{
		KGCSprite *sprite = _currentTargetSprites[index];
		NSDictionary *dictionary = @{@"Name": [sprite name], @"SpriteIdentifier": [sprite identifier]};
		[[self currentGridAnswer] setTargetSpriteDictionary:dictionary];
	}
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[[self sprite] gridAnswers] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCGridAnswer *gridAnswer = [[self sprite] gridAnswers][row];
	
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"AnswerTableCell" owner:nil];
	[[tableCellView textField] setStringValue:[gridAnswer name]];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tableView = [notification object];
	if (tableView == [self gridAnswerTableView])
	{	
		[self updateCurrentGridAnswer];
	}
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

- (KGCGridAnswer *)currentGridAnswer
{
	NSInteger row = [[self gridAnswerTableView] selectedRow];
	
	if (row != -1)
	{
		return [[self sprite] gridAnswers][row];
	}
	
	return nil;
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

- (void)updateGridAnswerTableView
{
	NSTableView *gridAnswerTableView = [self gridAnswerTableView];
	NSUInteger selectedRow = [gridAnswerTableView selectedRow];
	[gridAnswerTableView reloadData];
	[gridAnswerTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
}

- (void)updateCurrentGridAnswer
{
	NSTableView *gridAnswerTableView = [self gridAnswerTableView];
	[[self gridAnswerSettingsView] setHidden:[gridAnswerTableView selectedRow] == -1];
		
	KGCGridAnswer *currentGridAnswer = [self currentGridAnswer];
	if (currentGridAnswer)
	{
		[[self gridAnswerPointsField] setIntegerValue:[currentGridAnswer points]];
		
		BOOL allAnswers = [currentGridAnswer allOtherRowsAndColumns];
		NSTextField *gridAnswerColumnField = [self gridAnswerColumnField];
		[gridAnswerColumnField setEnabled:!allAnswers];
		NSTextField *gridAnswerRowField = [self gridAnswerRowField];
		[gridAnswerRowField setEnabled:!allAnswers];
		[[self allAnswersCheckBox] setState:allAnswers];
		
		if (allAnswers)
		{
			[gridAnswerColumnField setStringValue:@""];
			[gridAnswerRowField setStringValue:@""];
		}
		else
		{
			[gridAnswerColumnField setIntegerValue:[currentGridAnswer column]];
			[gridAnswerRowField setIntegerValue:[currentGridAnswer row]];
		}
		
		NSDictionary *targetSpriteDictionary = [currentGridAnswer targetSpriteDictionary];
		if (targetSpriteDictionary)
		{
			NSString *title = targetSpriteDictionary[@"Name"];
			NSPopUpButton *gridAnswerSpritePopUp = [self gridAnswerSpritePopUp];
			if ([gridAnswerSpritePopUp indexOfItemWithTitle:title] != -1)
			{
				[gridAnswerSpritePopUp selectItemWithTitle:title];
			}
		}
	}
}

@end