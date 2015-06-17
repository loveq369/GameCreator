//
//	KGCActionTableCell.m
//	GameCreator
//
//	Created by Maarten Foukhar on 21-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCActionTableCell.h"
#import "KGCAction.h"
#import "KGCInspectorWindow.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"
#import "KGCSprite.h"

@interface KGCActionTableCell ()

@property (nonatomic, weak) IBOutlet NSTextField *actionNameField;
@property (nonatomic, weak) IBOutlet NSTextField *actionTypeField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *actionTriggerPopUpButton;
@property (nonatomic, strong) IBOutlet NSView *actionTargetsView;
@property (nonatomic, weak) IBOutlet NSButton *actionTargetsEditButton;
@property (nonatomic, weak) IBOutlet NSTableView *actionTargetsTableView;
@property (nonatomic, weak) IBOutlet NSButton *actionTargetsAddButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *actionTargetsAddPopUp;

@end

@implementation KGCActionTableCell
{
	KGCAction *_action;
	KGCInspectorWindow *_inspectorWindow;
	NSMutableArray *_identifiers;
}

#pragma mark - Main Methods

- (void)setupWithAction:(KGCAction *)action
{
	_action = action;
	
	[[self actionNameField] setStringValue:[action name]];
	[[self actionTypeField] setStringValue:[action actionTypeDisplayName]];
	KGCActionTrigger actionTrigger = [action actionTrigger];
	[[self actionTriggerPopUpButton] selectItemAtIndex:actionTrigger];
	BOOL canEditTargets = (actionTrigger == KGCActionTriggerDrop || actionTrigger == KGCActionTriggerDropped || actionTrigger == KGCActionTriggerLink || actionTrigger == KGCActionTriggerUnlink || actionTrigger == KGCActionTriggerCollision);
	[[self actionTargetsEditButton] setEnabled:canEditTargets];
}

#pragma mark - Interface Methods

#pragma mark Cell

- (IBAction)changeActionName:(id)sender
{
	[_action setName:[sender stringValue]];
}

- (IBAction)changeActionTrigger:(id)sender
{
	[_action setActionTrigger:[sender indexOfSelectedItem]];
}

- (IBAction)showActionTargetsView:(id)sender
{
	if (!_inspectorWindow)
	{
		[[self actionTargetsTableView] reloadData];
		
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"KGCActionTargetView" bundle:nil];
		[nib instantiateWithOwner:self topLevelObjects:nil];
		NSView *eventsTargetsView = [self actionTargetsView];
		
		NSView *superview = [sender superview];
		NSRect senderFrame = [superview convertRect:[superview bounds] toView:nil];
		senderFrame = [[self window] convertRectToScreen:senderFrame];
		NSRect actionTriggerSpritesViewFrame = [eventsTargetsView frame];
		
		_inspectorWindow = [[KGCInspectorWindow alloc] initWithView:eventsTargetsView arrowLocation:[sender frame].origin.x + [sender frame].size.width / 2.0];
		
		NSRect windowFrame = [_inspectorWindow frame];
		CGFloat x = (senderFrame.origin.x + senderFrame.size.width / 2.0) - actionTriggerSpritesViewFrame.size.width / 2.0;
		CGFloat y = senderFrame.origin.y - windowFrame.size.height;
		y += [sender frame].origin.y;
		NSPoint position = NSMakePoint(round(x), round(y));
		[_inspectorWindow setFrameOrigin:position];
		[_inspectorWindow showAnimated:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeActionTargetView) name:NSWindowDidResignKeyNotification object:_inspectorWindow];
	}
}

- (void)removeActionTargetView
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:_inspectorWindow];
	
		[_inspectorWindow orderOut:nil];
		_inspectorWindow = nil;
	}];
}

#pragma mark Target View

- (IBAction)addTarget:(id)sender
{
	NSPopUpButton *actionTargetsAddPopUp = [self actionTargetsAddPopUp];
	if (sender == [self actionTargetsAddButton])
	{
		[actionTargetsAddPopUp removeAllItems];
		[actionTargetsAddPopUp addItemWithTitle:@""];
		
		KGCSprite *actionSprite = (KGCSprite *)[_action parentObject];
		NSArray *sprites = [(KGCScene *)[actionSprite parentObject] sprites];
		NSArray *targets = [_action triggerKeys];
		
		_identifiers = [[NSMutableArray alloc] init];
		for (KGCSprite *sprite in sprites)
		{
			NSString *identifier = [sprite identifier];
			NSInteger spriteType = [sprite spriteType];
			if (![targets containsObject:identifier] && sprite != actionSprite && spriteType != 0)
			{
				[actionTargetsAddPopUp addItemWithTitle:[sprite name]];
				[_identifiers addObject:[sprite identifier]];
			}
		}
		
		if ([_identifiers count] > 0)
		{
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No Available Sprites" action:NULL keyEquivalent:@""];
			[item setEnabled:NO];
			[[actionTargetsAddPopUp menu] addItem:item];
		}
	
		[actionTargetsAddPopUp performClick:nil];
	}
	else
	{
		NSMutableArray *targets = [_action triggerKeys];
		if (!targets)
		{
			targets = [[NSMutableArray alloc] init];
			[_action setTriggerKeys:targets];
		}
		
		NSInteger index = [sender indexOfSelectedItem];
		[targets addObject:_identifiers[index]];
		[[self actionTargetsTableView] reloadData];
	}
}

- (IBAction)deleteTarget:(id)sender
{
	NSMutableArray *targets = [_action triggerKeys];
	NSTableView *actionTargetsTableView = [self actionTargetsTableView];
	NSInteger index = [actionTargetsTableView selectedRow];
	
	if (index > -1)
	{
		[targets removeObjectAtIndex:index];
		[actionTargetsTableView reloadData];
	}
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[_action triggerKeys] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString *target = [_action triggerKeys][row];
		
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"TargetTableCell" owner:nil];
	[[tableCellView textField] setStringValue:target];
	
	return tableCellView;
}

@end