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
#import "KGCAnswer.h"

#import "KGCAnswerCell.h"
#import "KGCAnswerPointsCell.h"

@interface KGCDADSpriteController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteTypePopUp;
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

#pragma mark - Main Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	[self update];
}

- (void)update
{
	NSArray *sceneObjects = [self sceneObjects];
	
	NSNumber *spriteTypeNumber = [self objectForPropertyNamed:@"spriteType" inArray:sceneObjects];
	NSInteger spriteType = [spriteTypeNumber integerValue];
	
	[[self spriteTypePopUp] selectItemAtIndex:spriteType];
	[[self spriteTypeTabView] selectTabViewItemAtIndex:spriteType];
	[[self spriteAnswerSettingsView] setHidden:[[self spriteAnswerTableView] selectedRow] == -1];
	
	NSArray *properties = @[@"maxAnswerCount", @"maxGroupItems", @"groupName"];
	NSArray *textFields = @[[self spriteAnswerMaxField], [self spriteMaxItemsField], [self spriteGroupNameField]];
	for (NSInteger i = 0; i < [properties count]; i ++)
	{
		NSString *propertyName = properties[i];
		NSTextField *textField = textFields[i];
		id object = [self objectForPropertyNamed:propertyName inArray:sceneObjects];
		[self setObjectValue:object inTextField:textField];
	}
	
	NSTableView *spriteAnswerTableView = [self spriteAnswerTableView];
	NSInteger index = [spriteAnswerTableView selectedRow];
	[spriteAnswerTableView reloadData];
	[spriteAnswerTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
}

#pragma mark - Interface Methods

- (IBAction)changeSpriteType:(id)sender
{	
	NSInteger spriteType = [sender indexOfSelectedItem];
	
	for (KGCSprite *sprite in [self sceneObjects])
	{
		[sprite setSpriteType:spriteType];
	}
	
	[[self spriteTypeTabView] selectTabViewItemAtIndex:spriteType];
}

- (IBAction)changeSpriteMaxAnswerCount:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"maxAnswerCount" inArray:[self sceneObjects]];
}

- (IBAction)addSpriteAnswer:(id)sender
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return;
	}
	
	KGCSprite *sprite = sceneObjects[0];

	if (sender == [self spriteAnswerAddButton])
	{
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
		[sprite addAnswer:answer];
		[[self spriteAnswerTableView] reloadData];
	}
}

- (IBAction)deleteSpriteAnswer:(id)sender
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return;
	}
	
	KGCSprite *sprite = sceneObjects[0];

	NSTableView *spriteAnswerTableView = [self spriteAnswerTableView];
	NSInteger row = [spriteAnswerTableView selectedRow];
	
	KGCAnswer *answer = [sprite answers][row];
	[sprite removeAnswer:answer];
	
	[spriteAnswerTableView reloadData];
}

- (IBAction)changeMaxGroupItems:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"maxGroupItems" inArray:[self sceneObjects]];
}

- (IBAction)changeGroupName:(id)sender
{
	[self setObject:[sender stringValue] forPropertyNamed:@"groupName" inArray:[self sceneObjects]];
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
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return 0;
	}
	
	KGCSprite *sprite = sceneObjects[0];

	return [[sprite answers] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return nil;
	}
	
	KGCSprite *sprite = sceneObjects[0];

	KGCAnswer *answer = [sprite answers][row];
	NSString *name = @"Unknown";
	
	KGCScene *scene = (KGCScene *)[sprite parentObject];
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

#pragma mark - Convenient Methods

- (KGCAnswer *)currentAnswer
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return nil;
	}

	NSUInteger row = [[self spriteAnswerTableView] selectedRow];
	
	if (row != -1)
	{
		return [sceneObjects[0] answers][row];
	}
	
	return nil;
}

@end