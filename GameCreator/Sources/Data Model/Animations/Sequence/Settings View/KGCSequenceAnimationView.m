//
//	KGCSequenceAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSequenceAnimationView.h"
#import "KGCSequenceAnimation.h"
#import "KGCSceneLayer.h"
#import "KGCSceneObject.h"

@interface KGCSequenceAnimationView ()

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *addPopupButton;

@end

@implementation KGCSequenceAnimationView
{
	KGCSequenceAnimation *_animation;
	NSMutableArray *_popUpAnimations;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_animation = object;
	[[self tableView] reloadData];
}

#pragma mark - Interface Actions

- (IBAction)showAddMenu:(id)sender
{
	NSPopUpButton *addPopupButton = [self addPopupButton];
	[addPopupButton removeAllItems];
	[addPopupButton addItemWithTitle:@""];
	
	_popUpAnimations = [[NSMutableArray alloc] init];
	
	NSArray *animations = [_animation animations];
	NSArray *spriteAnimations = [(KGCSceneObject *)[_animation parentObject] animations];
	for (KGCAnimation *animation in spriteAnimations)
	{
		if (![animations containsObject:animation] && animation != _animation)
		{
			NSLog(@"Adding: %@", [animation name]);
			[addPopupButton addItemWithTitle:[animation name]];
			[_popUpAnimations addObject:animation];
		}
	}
	
	if ([[addPopupButton itemArray] count] == 1)
	{
		[addPopupButton setAutoenablesItems:NO];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No Available Animations" action:NULL keyEquivalent:@""];
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
	NSInteger index = [[self addPopupButton] indexOfSelectedItem] -1;
	KGCAnimation *animation = _popUpAnimations[index];
	
	[[_animation animationKeys] addObject:[animation identifier]];
	[[self tableView] reloadData];
}

- (IBAction)delete:(id)sender
{
	NSInteger selectedRow = [[self tableView] selectedRow];
	
	if (selectedRow > -1)
	{
		KGCAnimation *animation = [_animation animations][selectedRow];
		[[_animation animationKeys] removeObject:[animation identifier]];
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
	return [[_animation animations] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCAnimation *animation = [_animation animations][row];

	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ActionTableCell" owner:nil];
	[[tableCellView textField] setStringValue:[animation name]];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}

@end