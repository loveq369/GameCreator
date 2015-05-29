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
#import "KGCGridAnswer.h"
#import "KGCAnswerCell.h"
#import "KGCAnswerPointsCell.h"

@interface KGCDADShapeSpriteController ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteTypePopUp;
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
	
	[[self gridAnswerSettingsView] setHidden:YES];
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
	
	if (spriteType == 1)
	{
		NSArray *properties = @[@"gridRows", @"gridColumns", @"maxShapes"];
		NSArray *textFields = @[[self gridRowsField], [self gridColumnsField], [self gridMaxShapes]];
		for (NSInteger i = 0; i < [properties count]; i ++)
		{
			NSString *propertyName = properties[i];
			NSTextField *textField = textFields[i];
			id object = [self objectForPropertyNamed:propertyName inArray:sceneObjects];
			[self setObjectValue:object inTextField:textField];
		}
	}
	else if (spriteType == 2)
	{
		NSNumber *maxInstanceCount = [self objectForPropertyNamed:@"maxInstanceCount" inArray:sceneObjects];
		[self setObjectValue:maxInstanceCount inTextField:[self spriteCountField]];
		
		[self updateGridSize];
	}
		
	[[self spriteTypeTabView] selectTabViewItemAtIndex:spriteType];
	
	[_currentTargetSprites removeAllObjects];
	
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (!multipleSprites)
	{
		KGCSprite *sprite = sceneObjects[0];
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

- (IBAction)changeSpriteCount:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"maxInstanceCount" inArray:[self sceneObjects]];
}

- (IBAction)changeSpriteGridSize:(id)sender
{	
	if (sender == [self spriteGridColumnsField])
	{
		[self setWidth:[[self spriteGridColumnsField] doubleValue]];
	}
	else if (sender == [self spriteGridRowsField])
	{
		[self setHeight:[[self spriteGridRowsField] doubleValue]];
	}
}

- (IBAction)changeGridRows:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"gridRows" inArray:[self sceneObjects]];
}

- (IBAction)changeGridColumns:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"gridColumns" inArray:[self sceneObjects]];
}

- (IBAction)changeGridMaxShapes:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"maxShapes" inArray:[self sceneObjects]];
}

- (IBAction)addGridAnswer:(id)sender
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (!multipleSprites)
	{
		KGCSprite *sprite = sceneObjects[0];
		KGCGridAnswer *gridAnswer = [KGCGridAnswer gridAnswerWitDocument:[sprite document]];
		[sprite addGridAnswer:gridAnswer];
		[[self gridAnswerTableView] reloadData];
	}
}

- (IBAction)removeGridAnswer:(id)sender
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (!multipleSprites)
	{
		KGCSprite *sprite = sceneObjects[0];
		NSInteger row = [[self gridAnswerTableView] selectedRow];
		
		if (row != -1)
		{
			KGCGridAnswer *gridAnswer = [sprite gridAnswers][row];
			[sprite removeGridAnswer:gridAnswer];
			[[self gridAnswerTableView] reloadData];
		}
		else
		{
			NSBeep();
		}
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
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return 0;
	}
	else
	{
		return [[sceneObjects[0] gridAnswers] count];
	}
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return nil;
	}
	else
	{
		KGCGridAnswer *gridAnswer = [sceneObjects[0] gridAnswers][row];
		
		NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"AnswerTableCell" owner:nil];
		[[tableCellView textField] setStringValue:[gridAnswer name]];
		
		return tableCellView;
	}
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

#pragma mark - Property Methods

- (NSSize)gridSizeGlobalWidth:(BOOL *)globalWidth globalHeight:(BOOL *)globalHeight
{
	*globalWidth = YES;
	*globalHeight = YES;

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCSprite *)sceneObjects[0] gridSize];
	}
	
	BOOL firstCheck = YES;
	BOOL wrongWidth = NO;
	BOOL wrongHeight = NO;
	NSSize size = NSZeroSize;
	for (KGCSprite *sprite in sceneObjects)
	{
		if (firstCheck)
		{
			firstCheck = NO;
			size = [sprite gridSize];
		}
		else
		{
			NSSize otherSize = [sprite gridSize];
			if (!wrongWidth && (otherSize.width != size.width))
			{
				wrongWidth = YES;
				*globalWidth = NO;
			}
			if (!wrongHeight && (otherSize.height != size.height))
			{
				wrongHeight = YES;
				*globalHeight = NO;
			}
			
			if (wrongWidth && wrongHeight)
			{
				return NSZeroSize;
			}
		}
	}
	
	return size;
}

- (void)setWidth:(CGFloat)width
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		NSSize gridSize = [sprite gridSize];
		gridSize.width = width;
		[sprite setGridSize:gridSize];
	}
}

- (void)setHeight:(CGFloat)height
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		NSSize gridSize = [sprite gridSize];
		gridSize.height = height;
		[sprite setGridSize:gridSize];
	}
}

#pragma mark - Convenient Methods

- (void)updateGridSize
{
	BOOL globalWidth, globalHeight;
	NSSize gridSize = [self gridSizeGlobalWidth:&globalWidth globalHeight:&globalHeight];
	
	NSTextField *spriteGridColumnsField = [self spriteGridColumnsField];
	if (globalWidth)
	{
		[spriteGridColumnsField setDoubleValue:gridSize.width];
	}
	else
	{
		[spriteGridColumnsField setStringValue:@"--"];
	}
	
	NSTextField *spriteGridRowsField = [self spriteGridRowsField];
	if (globalHeight)
	{
		[spriteGridRowsField setDoubleValue:gridSize.height];
	}
	else
	{
		[spriteGridRowsField setStringValue:@"--"];
	}
}

- (KGCGridAnswer *)currentGridAnswer
{
	NSArray *sceneObjects = [self sceneObjects];
	BOOL multipleSprites = [sceneObjects count] > 1;
	if (multipleSprites)
	{
		return nil;
	}

	NSInteger row = [[self gridAnswerTableView] selectedRow];
	
	if (row != -1)
	{
		return [sceneObjects[0] gridAnswers][row];
	}
	
	return nil;
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