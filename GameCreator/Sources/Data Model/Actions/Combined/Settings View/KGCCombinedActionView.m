//
//	KGCCombinedActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCCombinedActionView.h"
#import "KGCCombinedAction.h"
#import "KGCSceneObject.h"
#import "KGCSceneContentView.h"

@interface KGCCombinedActionView ()

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *addPopupButton;

@end

@implementation KGCCombinedActionView
{
	KGCCombinedAction *_action;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_action = object;
	
	[[self tableView] reloadData];
}

#pragma mark - Interface Actions

- (IBAction)showAddMenu:(id)sender
{
	NSPopUpButton *addPopupButton = [self addPopupButton];
	[addPopupButton removeAllItems];
	[addPopupButton addItemWithTitle:@""];
	
	NSArray *actions = [_action actions];
	NSArray *spriteActions = [[self sceneObject] actions];
	for (KGCAction *action in spriteActions)
	{
		if (![actions containsObject:action] && action != _action)
		{
			[addPopupButton addItemWithTitle:[action name]];
		}
	}
	
	if ([[addPopupButton itemArray] count] == 1)
	{
		[addPopupButton setAutoenablesItems:NO];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No Available Actions" action:NULL keyEquivalent:@""];
		[item setEnabled:NO];
		[[addPopupButton menu] addItem:item];
	}
	else
	{
		[addPopupButton setAutoenablesItems:YES];
	}

	[[self addPopupButton] performClick:nil];
}

- (IBAction)add:(id)sender
{
	[[_action actionKeys] addObject:[[self addPopupButton] titleOfSelectedItem]];
	[[self tableView] reloadData];
}

- (IBAction)delete:(id)sender
{
	NSInteger selectedRow = [[self tableView] selectedRow];
	
	if (selectedRow > -1)
	{
		KGCAction *action = [_action actions][selectedRow];
		[[_action actionKeys] removeObject:[action identifier]];
		[[self tableView] reloadData];
	}
	else
	{
		NSBeep();
	}
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[_action actions] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCAction *action = [_action actions][row];

	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ActionTableCell" owner:nil];
	[[tableCellView textField] setStringValue:[action name]];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}

@end