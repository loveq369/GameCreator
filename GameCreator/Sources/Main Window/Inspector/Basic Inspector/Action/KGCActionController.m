//
//	KGCActionController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCActionController.h"
#import "KGCAction.h"
#import "KGCInspectorWindow.h"
#import "KGCScene.h"
#import "KGCSprite.h"

@interface KGCActionController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *actionTableView;
@property (nonatomic, weak) IBOutlet NSButton *actionBarButton;
@property (nonatomic, weak) IBOutlet NSButton *actionAddButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *actionAddPopUp;
@property (nonatomic, weak) IBOutlet NSTextField *triggerNotificationNameField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *actionLinkPopup;
@property (nonatomic, weak) IBOutlet NSTextField *delayTextField;
@property (nonatomic, weak) IBOutlet NSView *actionSettingsView;
@property (nonatomic, weak) IBOutlet NSTextField *actionPointsField;
@property (nonatomic, weak) IBOutlet NSTextField *actionMaximumPointsField;
@property (nonatomic, weak) IBOutlet NSTextField *actionRequiredPointsField;

@end

@implementation KGCActionController
{
	KGCInspectorWindow *_inspectorWindow;
}

#pragma mark - Initial Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];

	[[self actionTableView] reloadData];
	[self updateCurrentAction];
}

#pragma mark - Interface Methods

- (IBAction)actionAdd:(id)sender
{
	if (sender == [self actionAddButton])
	{
		[[self actionAddPopUp] performClick:nil];
	}
	else
	{
		NSArray *sceneObjects = [self sceneObjects];
		KGCActionType actionType = [sender indexOfSelectedItem];
		KGCAction *newAction = [KGCAction newActionWithType:actionType document:[sceneObjects[0] document]];
			
		for (KGCSceneObject *sceneObject in sceneObjects)
		{
			[sceneObject addAction:newAction];
		}
		
		NSTableView *actionTableView = [self actionTableView];
		[actionTableView reloadData];
		NSArray *actions = [self actions];
		[actionTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[actions count] -1] byExtendingSelection:NO];
	}
}

- (IBAction)actionDelete:(id)sender
{
	KGCAction *action = [self currentAction];	
	if (action)
	{
		for (KGCSceneObject *sceneObject in [self sceneObjects])
		{
			[sceneObject removeAction:action];
		}
		
		[[self actionTableView] reloadData];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)changeActionTriggerNotificationName:(id)sender
{
	[[self currentAction] setActionTriggerNotificationName:[sender stringValue]];
}

- (IBAction)changeActionLinkType:(id)sender
{
	[[self currentAction] setActionLinkType:[sender indexOfSelectedItem]];
}

- (IBAction)changeActionDelay:(id)sender
{
	[[self currentAction] setDelay:[sender doubleValue]];
}

- (IBAction)changeActionPoints:(id)sender
{
	[[self currentAction] setActionPoints:[sender doubleValue]];
}


- (IBAction)changeRequiredActionPoints:(id)sender
{
	[[self currentAction] setRequiredActionPoints:[sender doubleValue]];
}

- (IBAction)changeMaximumActionPoints:(id)sender
{
	[[self currentAction] setMaximumActionPoints:[sender doubleValue]];
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[self actions] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCAction *spriteAction = [self actionForRow:row];
		
	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ActionTableCell" owner:nil];
	[[tableCellView textField] setStringValue:[spriteAction name]];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateCurrentAction];
}

#pragma mark - Convenient Methods

- (KGCAction *)actionForRow:(NSUInteger)row
{
	if (row == -1)
	{
		return nil;
	}
	
	return [self actions][row];
}

- (KGCAction *)currentAction
{
	return [self actionForRow:[[self actionTableView] selectedRow]];
}

- (void)updateCurrentAction
{
	NSTableView *actionTableView = [self actionTableView];
	NSInteger row = [actionTableView selectedRow];
	
	if (row != -1)
	{
		KGCAction *spriteAction = [self currentAction];
		
		[[self triggerNotificationNameField] setStringValue:[spriteAction actionTriggerNotificationName]];
		
		NSPopUpButton *actionLinkPopup = [self actionLinkPopup];
		[actionLinkPopup selectItemAtIndex:[spriteAction actionLinkType]];
		[actionLinkPopup setEnabled:YES];
		
		NSTextField *actionPointsField = [self actionPointsField];
		[actionPointsField setIntegerValue:[spriteAction actionPoints]];
		[actionPointsField setEnabled:YES];
		
		NSTextField *actionMaximumPointsField = [self actionMaximumPointsField];
		[actionMaximumPointsField setIntegerValue:[spriteAction maximumActionPoints]];
		[actionMaximumPointsField setEnabled:YES];
		
		NSTextField *actionRequiredPointsField = [self actionRequiredPointsField];
		[actionRequiredPointsField setIntegerValue:[spriteAction requiredActionPoints]];
		[actionRequiredPointsField setEnabled:YES];
		
		NSTextField *delayTextField = [self delayTextField];
		[delayTextField setDoubleValue:[spriteAction delay]];
		[delayTextField setEnabled:YES];
		
		NSView *actionSettingsView = [self actionSettingsView];
		NSRect actionSettingsViewFrame = [actionSettingsView frame];
		[[actionSettingsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
		NSView *actionInfoView = (NSView *)[spriteAction infoViewForSceneLayers:[self sceneLayers]];
		if (actionInfoView)
		{
			NSRect actionInfoViewFrame = [actionInfoView frame];
			actionInfoViewFrame.size.height = actionSettingsViewFrame.size.height;
			[actionInfoView setFrame:actionInfoViewFrame];
			[actionSettingsView addSubview:actionInfoView];
		}
	}
	else
	{
		[[self actionLinkPopup] setEnabled:NO];
		
		NSTextField *actionPointsField = [self actionPointsField];
		[actionPointsField setIntegerValue:0];
		[actionPointsField setEnabled:NO];
		
		NSTextField *actionMaximumPointsField = [self actionMaximumPointsField];
		[actionMaximumPointsField setIntegerValue:0];
		[actionMaximumPointsField setEnabled:NO];
		
		NSTextField *actionRequiredPointsField = [self actionRequiredPointsField];
		[actionRequiredPointsField setIntegerValue:0];
		[actionRequiredPointsField setEnabled:NO];
		
		NSTextField *delayTextField = [self delayTextField];
		[delayTextField setDoubleValue:0.0];
		[delayTextField setEnabled:NO];
		
		[[[self actionSettingsView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	}
}

- (NSArray *)actions
{
	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCSceneObject *)sceneObjects[0] actions];
	}
	else
	{
		NSMutableArray *actions;
		for (KGCSceneObject *sceneObject in [self sceneObjects])
		{
			if (actions)
			{
				for (KGCAction *action in [actions copy])
				{
					BOOL keepAction = NO;
					for (KGCAction *otherAction in [sceneObject actions])
					{
						if (action == otherAction)
						{
							keepAction = YES;
						}
					}
					
					if (!keepAction)
					{
						[actions removeObject:action];
					}
				}
			}
			else
			{
				actions = [[NSMutableArray alloc] initWithArray:[sceneObject actions]];
			}
		}
	}
	
	return nil;
}

@end