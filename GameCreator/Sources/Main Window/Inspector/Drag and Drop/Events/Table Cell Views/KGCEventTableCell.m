//
//	KGCEventTableCell.m
//	GameCreator
//
//	Created by Maarten Foukhar on 21-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCEventTableCell.h"
#import "KGCEvent.h"
#import "KGCInspectorWindow.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"
#import "KGCSprite.h"

@interface KGCEventTableCell ()

@property (nonatomic, weak) IBOutlet NSTextField *eventNameField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *eventTypePopUp;
@property (nonatomic, strong) IBOutlet NSView *eventTargetsView;
@property (nonatomic, weak) IBOutlet NSButton *eventTargetsEditButton;
@property (nonatomic, weak) IBOutlet NSTableView *eventTargetsTableView;
@property (nonatomic, weak) IBOutlet NSButton *eventTargetsAddButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *eventTargetsAddPopUp;

@end

@implementation KGCEventTableCell
{
	KGCEvent *_event;
	KGCInspectorWindow *_inspectorWindow;
	NSMutableArray *_identifiers;
}

#pragma mark - Main Methods

- (void)setupWithEvent:(KGCEvent *)event
{
	_event = event;
	
	[[self eventNameField] setStringValue:[event name]];
	[[self eventTypePopUp] selectItemAtIndex:[event eventType]];
	[[self eventTargetsEditButton] setEnabled:[event eventType] == KGCEventTypeDrop];
}

#pragma mark - Interface Methods

#pragma mark Cell

- (IBAction)changeEventName:(id)sender
{
	[_event setName:[sender stringValue]];
}

- (IBAction)changeEventType:(id)sender
{
	[_event setEventType:[sender indexOfSelectedItem]];
}

- (IBAction)showEventTargetsView:(id)sender
{
	if (!_inspectorWindow)
	{
		[[self eventTargetsTableView] reloadData];
		
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"KGCTargetView" bundle:nil];
		[nib instantiateWithOwner:self topLevelObjects:nil];
		NSView *eventsTargetsView = [self eventTargetsView];
		
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeEventTargetView) name:NSWindowDidResignKeyNotification object:_inspectorWindow];
	}
}

- (void)removeEventTargetView
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:_inspectorWindow];
	
		[_inspectorWindow orderOut:nil];
		_inspectorWindow = nil;
	}];
}

#pragma mark Target View

- (IBAction)addEventsTarget:(id)sender
{
	NSPopUpButton *eventTargetsAddPopUp = [self eventTargetsAddPopUp];
	if (sender == [self eventTargetsAddButton])
	{
		[eventTargetsAddPopUp removeAllItems];
		[eventTargetsAddPopUp addItemWithTitle:@""];
		
		KGCSprite *eventSprite = (KGCSprite *)[_event parentObject];
		NSArray *sprites = [(KGCScene *)[eventSprite parentObject] sprites];
		NSArray *targets = [_event targets];
		
		_identifiers = [[NSMutableArray alloc] init];
		for (KGCSprite *sprite in sprites)
		{
			NSString *identifier = [sprite identifier];
			NSInteger spriteType = [sprite spriteType];
			if (![targets containsObject:identifier] && sprite != eventSprite && spriteType != 0)
			{
				[eventTargetsAddPopUp addItemWithTitle:[sprite name]];
				[_identifiers addObject:[sprite identifier]];
			}
		}
		
		if ([_identifiers count] > 0)
		{
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No Available Sprites" action:NULL keyEquivalent:@""];
			[item setEnabled:NO];
			[[eventTargetsAddPopUp menu] addItem:item];
		}
	
		[eventTargetsAddPopUp performClick:nil];
	}
	else
	{
		NSMutableArray *targets = [_event targets];
		if (!targets)
		{
			targets = [[NSMutableArray alloc] init];
			[_event setTargets:targets];
		}
		
		NSInteger index = [sender indexOfSelectedItem];
		[targets addObject:_identifiers[index]];
		[[self eventTargetsTableView] reloadData];
	}
}

- (IBAction)deleteEventsTarget:(id)sender
{
	NSMutableArray *targets = [_event targets];
	NSTableView *eventsTargetsTableView = [self eventTargetsTableView];
	NSInteger index = [eventsTargetsTableView selectedRow];
	
	if (index > -1)
	{
		[targets removeObjectAtIndex:index];
		[eventsTargetsTableView reloadData];
	}
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[_event targets] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString *target = [_event targets][row];
		
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"TargetTableCell" owner:nil];
	[[tableCellView textField] setStringValue:target];
	
	return tableCellView;
}

@end