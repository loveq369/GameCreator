//
//	KGCDADEventsController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADEventsController.h"
#import "KGCDADInspector.h"
#import "KGCSceneContentView.h"
#import "KGCSpriteLayer.h"
#import "KGCEvent.h"
#import "KGCTemplateAction.h"
#import "KGCEventTableCell.h"
#import "KGCBasicTableCell.h"

@interface KGCDADEventsController () <NSTableViewDataSource, NSTableViewDelegate, KGCBasicTableCellDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *eventsTableView;
@property (nonatomic, weak) IBOutlet NSButton *eventsAddButton;
@property (nonatomic, weak) IBOutlet NSTableView *eventsActionTableView;
@property (nonatomic, weak) IBOutlet NSButton *eventsActionAddButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *eventsActionAddPopUp;
@property (nonatomic, weak) IBOutlet NSButton *eventsActionDeleteButton;
@property (nonatomic, weak) IBOutlet NSButton *eventsActionOrderedButton;
@property (nonatomic, weak) IBOutlet NSView *eventsDefaultSettingsView;
@property (nonatomic, weak) IBOutlet NSTextField *delayField;
@property (nonatomic, weak) IBOutlet NSTextField *requiredPointsField;
@property (nonatomic, weak) IBOutlet NSTextField *maxiumPointsField;
@property (nonatomic, weak) IBOutlet NSButton *linkedButton;
@property (nonatomic, weak) IBOutlet NSTextField *notificationNameField;
@property (nonatomic, weak) IBOutlet NSView *eventsActionSettingsView;

@end

@implementation KGCDADEventsController

#pragma mark - Initial Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSTableView *eventsTableView = [self eventsTableView];
	[eventsTableView setDoubleAction:@selector(editTableViewCell:)];
	[eventsTableView setTarget:self];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	[super setupWithSceneLayer:sceneLayer];
	
	[[self eventsTableView] reloadData];
	[self updateCurrentEvent];
}

- (void)update
{
//	[self updateTemplateActionSettingsView];
}

#pragma mark - Interface Actions

- (IBAction)eventAdd:(id)sender
{
	KGCEvent *event = [KGCEvent newEventWithDocument:[[self sceneObject] document]];
	
	KGCSceneObject *sceneObject = [self sceneObject];
	[sceneObject addEvent:event];
	
	NSTableView *eventsTableView = [self eventsTableView];
	[eventsTableView reloadData];
	NSArray *events = [sceneObject events];
	NSInteger newRow = [events count] - 1;
	[eventsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
	[eventsTableView editColumn:0 row:newRow withEvent:nil select:YES];
}

- (IBAction)changeRequiredPoints:(id)sender
{
	[[self currentEvent] setRequiredPoints:[sender integerValue]];
}

- (IBAction)changeMaxPoints:(id)sender
{
	[[self currentEvent] setMaxPoints:[sender integerValue]];
}

- (IBAction)changeLinked:(id)sender
{
	[[self currentEvent] setLinked:[sender state]];
}

- (IBAction)changeNotificationName:(id)sender
{
	[[self currentEvent] setNotificationName:[sender stringValue]];
}

- (IBAction)eventDelete:(id)sender
{
	KGCEvent *event = [self currentEvent];	
	if (event)
	{
		KGCSceneObject *sceneObject = [self sceneObject];
		[sceneObject removeEvent:event];
		
		NSTableView *eventsTableView = [self eventsTableView];
		[eventsTableView deselectAll:nil];
		[eventsTableView reloadData];
		[[self eventsActionTableView] reloadData];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)addEventTemplateAction:(id)sender
{
	if (sender == [self eventsActionAddButton])
	{
		[[self eventsActionAddPopUp] performClick:nil];
	}
	else
	{
		NSUInteger type = [sender indexOfSelectedItem];
		if (type != KGCTemplateActionTypeNone)
		{
			KGCEvent *event = [self currentEvent];
			KGCTemplateAction *newAction = [KGCTemplateAction newActionWithType:type document:[[self sceneObject] document]];
			[event addTemplateAction:newAction];
			[[self eventsActionTableView] reloadData];
		}
	}
}

- (IBAction)deleteEventTemplateAction:(id)sender
{
	NSInteger row = [[self eventsActionTableView] selectedRow];
	
	if (row != -1)
	{
		KGCEvent *event = [self currentEvent];
		[event removeTemplateAction:[event templateActions][row]];
		[[self eventsActionTableView] reloadData];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)changeOrdered:(id)sender
{
	[[self currentEvent] setOrdered:[sender state]];
}

- (IBAction)changeDelay:(id)sender
{
	[[self currentAction] setDelay:[sender doubleValue]];
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if (tableView == [self eventsTableView])
	{
		return [[[self sceneObject] events] count];
	}
	else if (tableView == [self eventsActionTableView])
	{
		return [[[self currentEvent] templateActions] count];
	}
		
	return 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *tableCellView;
	
	if (tableView == [self eventsTableView])
	{
		KGCEvent *event = [self eventForRow:row];
	
		tableCellView = [tableView makeViewWithIdentifier:@"EventTableCell" owner:nil];
		[(KGCEventTableCell *)tableCellView setupWithEvent:event];
	}
	else if (tableView == [self eventsActionTableView])
	{
		KGCTemplateAction *templateAction = [[self currentEvent] templateActions][row];
		
		tableCellView = [tableView makeViewWithIdentifier:@"ActionTableCell" owner:nil];
		[[tableCellView textField] setStringValue:[templateAction name]];
		[(KGCBasicTableCell *)tableCellView setDelegate:self];
		[(KGCBasicTableCell *)tableCellView setRow:row];
	}
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tableView = [notification object];
	if (tableView == [self eventsTableView])
	{
		[self updateCurrentEvent];
	}
	else if (tableView == [self eventsActionTableView])
	{
		[self updateTemplateActionSettingsView];
	}
}

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
	// Support for us being a dragging source
	return nil;
}

#pragma mark - BasicTableCell Delegate Methods

- (void)basicTableCell:(KGCBasicTableCell *)basicTableCell didChangeText:(NSString *)newText
{
	KGCTemplateAction *action = [[self currentEvent] templateActions][[basicTableCell row]];
	[action setName:newText];
}

#pragma mark - Convenient Methods

- (KGCEvent *)currentEvent
{
	return [self eventForRow:[[self eventsTableView] selectedRow]];
}

- (KGCEvent *)eventForRow:(NSUInteger)row
{
	if (row == -1)
	{
		return nil;
	}
	
	return [[self sceneObject] events][row];
}

- (void)updateCurrentEvent
{
	NSTableView *eventsTableView = [self eventsTableView];
	NSInteger row = [eventsTableView selectedRow];
	
	if (row != -1)
	{
		[[self eventsActionTableView] setEnabled:YES];
		[[self eventsActionAddButton] setEnabled:YES];
		
		NSPopUpButton *eventsActionAddPopUp = [self eventsActionAddPopUp];
		[eventsActionAddPopUp setEnabled:YES];
		[eventsActionAddPopUp setHidden:NO];
		
		[[self eventsActionAddPopUp] setEnabled:YES];
		[[self eventsActionDeleteButton] setEnabled:YES];
		[[self eventsActionOrderedButton] setEnabled:YES];
		[[self eventsActionTableView] reloadData];
		
		KGCEvent *event = [self currentEvent];
		
		NSTextField *requiredPointsField = [self requiredPointsField];
		[requiredPointsField setIntegerValue:[event requiredPoints]];
		[requiredPointsField setEnabled:YES];
		
		NSTextField *maxiumPointsField = [self maxiumPointsField];
		[maxiumPointsField setIntegerValue:[event maxPoints]];
		[maxiumPointsField setEnabled:YES];
		
		NSButton *linkedButton = [self linkedButton];
		[linkedButton setState:[event isLinked]];
		[linkedButton setEnabled:YES];
		
		NSTextField *notificationNameField = [self notificationNameField];
		NSString *notificationName = [event notificationName];
		if (notificationName)
		{
			[notificationNameField setStringValue:notificationName];
		}
		else
		{
			[notificationNameField setStringValue:@""];
		}
		[notificationNameField setEnabled:[event eventType] == KGCEventTypeNotification];
		
		NSButton *eventsActionOrderedButton = [self eventsActionOrderedButton];
		[eventsActionOrderedButton setState:[event isOrdered]];
		[eventsActionOrderedButton setEnabled:YES];
	}
	else
	{
		[[self eventsActionTableView] setEnabled:NO];
		[[self eventsActionAddButton] setEnabled:NO];
		
		NSPopUpButton *eventsActionAddPopUp = [self eventsActionAddPopUp];
		[eventsActionAddPopUp setEnabled:NO];
		[eventsActionAddPopUp setHidden:YES];
		
		[[self eventsActionDeleteButton] setEnabled:NO];
		[[self eventsActionOrderedButton] setEnabled:NO];
		[[self eventsActionTableView] reloadData];
		
		NSTextField *requiredPointsField = [self requiredPointsField];
		[requiredPointsField setStringValue:@""];
		[requiredPointsField setEnabled:NO];
		
		NSTextField *maxiumPointsField = [self maxiumPointsField];
		[maxiumPointsField setStringValue:@""];
		[maxiumPointsField setEnabled:NO];
		
		NSButton *linkedButton = [self linkedButton];
		[linkedButton setState:NSOffState];
		[linkedButton setEnabled:NO];
		
		NSTextField *notificationNameField = [self notificationNameField];
		[notificationNameField setStringValue:@""];
		[notificationNameField setEnabled:NO];
		
		NSButton *eventsActionOrderedButton = [self eventsActionOrderedButton];
		[eventsActionOrderedButton setState:NSOffState];
		[eventsActionOrderedButton setEnabled:NO];
		
		[[[self eventsActionSettingsView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	}
}

- (void)updateTemplateActionSettingsView
{
	NSView *eventsActionSettingsView = [self eventsActionSettingsView];
	[[eventsActionSettingsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	NSArray *templateActions = [[self currentEvent] templateActions];
	NSInteger selectedRow = [[self eventsActionTableView] selectedRow];
	if (selectedRow == -1 && selectedRow > [templateActions count] -1)
	{
		[[self eventsDefaultSettingsView] setHidden:YES];
	
		return;
	}
	
	[[self eventsDefaultSettingsView] setHidden:NO];
	
	
	KGCTemplateAction *templateAction = templateActions[selectedRow];
	
	if (!templateAction)
	{
		return;
	}
	
	[[self delayField] setDoubleValue:[templateAction delay]];
	
	NSView *actionInfoView = (NSView *)[templateAction infoViewForLayer:[self sceneLayer]];
	NSRect eventsActionSettingsViewFrame = [eventsActionSettingsView frame];
	if (actionInfoView)
	{
		NSRect actionInfoViewFrame = [actionInfoView frame];
		actionInfoViewFrame.size.height = eventsActionSettingsViewFrame.size.height;
		[actionInfoView setFrame:actionInfoViewFrame];
		[eventsActionSettingsView addSubview:actionInfoView];
	}
}

- (void)editTableViewCell:(id)sender
{
	NSUInteger selectedRow = [sender selectedRow];
	if (selectedRow != NSNotFound)
	{
		[sender editColumn:0 row:selectedRow withEvent:nil select:YES];
	}
}

- (KGCTemplateAction *)currentAction
{
	NSInteger row = [[self eventsActionTableView] selectedRow];
	
	if (row != -1)
	{
		NSArray *templateActions = [[self currentEvent] templateActions];
		KGCTemplateAction *templateAction = templateActions[row];
		
		return templateAction;
	}
	
	return nil;
}

@end