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
@property (nonatomic, weak) IBOutlet NSTextField *nameTextField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *triggerPopupButton;
@property (nonatomic, weak) IBOutlet NSTabView *triggerOptionsTabView;
@property (nonatomic, weak) IBOutlet NSTextField *triggerNotificationNameField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *actionLinkPopup;
@property (nonatomic, weak) IBOutlet NSTextField *actionTypeField;
@property (nonatomic, weak) IBOutlet NSTextField *delayTextField;
@property (nonatomic, weak) IBOutlet NSView *actionSettingsView;
@property (nonatomic, strong) IBOutlet NSView *actionTriggerSpritesView;
@property (nonatomic, weak) IBOutlet NSButton *actionTriggerSpritesEditButton;
@property (nonatomic, weak) IBOutlet NSTableView *actionTriggerSpritesTableView;
@property (nonatomic, weak) IBOutlet NSButton *actionTriggerSpritesAddButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *actionTriggerSpritesAddPopUp;
@property (nonatomic, weak) IBOutlet NSTextField *actionPointsField;
@property (nonatomic, weak) IBOutlet NSTextField *actionMaximumPointsField;
@property (nonatomic, weak) IBOutlet NSTextField *actionRequiredPointsField;

@end

@implementation KGCActionController
{
	KGCInspectorWindow *_inspectorWindow;
}

#pragma mark - Initial Methods

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	[super setupWithSceneLayer:sceneLayer];

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
		KGCSceneObject *sceneObject = [self sceneObject];
		
		KGCActionType actionType = [sender indexOfSelectedItem];
		KGCAction *newAction = [KGCAction newActionWithType:actionType document:[sceneObject document]];
		[sceneObject addAction:newAction];
		
		NSTableView *actionTableView = [self actionTableView];
		[actionTableView reloadData];
		NSArray *actions = [sceneObject actions];
		[actionTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[actions count] -1] byExtendingSelection:NO];
	}
}

- (IBAction)actionDelete:(id)sender
{
	KGCAction *action = [self currentAction];	
	if (action)
	{
		[[self sceneObject] removeAction:action];
		[[self actionTableView] reloadData];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)changeActionIdentifier:(id)sender
{
	[[self currentAction] setName:[sender stringValue]];
}

- (IBAction)changeActionTrigger:(id)sender
{
	KGCActionTrigger actionTrigger = [sender indexOfSelectedItem];
	[[self currentAction] setActionTrigger:actionTrigger];
	[[self actionTriggerSpritesEditButton] setEnabled:actionTrigger == KGCActionTriggerDrop || actionTrigger == KGCActionTriggerDropped || actionTrigger == KGCActionTriggerLink || actionTrigger == KGCActionTriggerUnlink];
}

- (IBAction)showActionTriggerSpriteView:(id)sender
{
	if (!_inspectorWindow)
	{
		[[self actionTriggerSpritesTableView] reloadData];
		NSView *actionTriggerSpritesView = [self actionTriggerSpritesView];
		
		NSRect senderFrame = [sender convertRect:[sender bounds] toView:nil];
		senderFrame = [[[self view] window] convertRectToScreen:senderFrame];
		NSRect actionTriggerSpritesViewFrame = [actionTriggerSpritesView frame];
		
		_inspectorWindow = [[KGCInspectorWindow alloc] initWithView:[self actionTriggerSpritesView] arrowLocation:0.0];
		
		NSRect windowFrame = [_inspectorWindow frame];
		CGFloat x = (senderFrame.origin.x + senderFrame.size.width / 2.0) - actionTriggerSpritesViewFrame.size.width / 2.0;
		CGFloat y = senderFrame.origin.y - windowFrame.size.height;
		NSPoint position = NSMakePoint(round(x), round(y));
		[_inspectorWindow setFrameOrigin:position];
		[_inspectorWindow showAnimated:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTriggerWindow) name:NSWindowDidResignKeyNotification object:_inspectorWindow];
	}
}

- (void)removeTriggerWindow
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:_inspectorWindow];
	
		[_inspectorWindow orderOut:nil];
		_inspectorWindow = nil;
	}];
}

- (IBAction)addActionTriggerSprite:(id)sender
{
	NSPopUpButton *actionTriggerSpritesAddPopUp = [self actionTriggerSpritesAddPopUp];
	if (sender == [self actionTriggerSpritesAddButton])
	{
		[actionTriggerSpritesAddPopUp removeAllItems];
		[actionTriggerSpritesAddPopUp addItemWithTitle:@""];
		
		KGCSceneObject *sceneObject = [self sceneObject];
		KGCScene *scene;
		if ([sceneObject isKindOfClass:[KGCScene class]])
		{
			scene = (KGCScene *)sceneObject;
		}
		else
		{
			scene = (KGCScene *)[sceneObject parentObject];
		}
		
		NSArray *sprites = [scene sprites];
		NSArray *triggerKeys = [[self currentAction] triggerKeys];
		
		BOOL titleAdded = NO;
		for (KGCSprite *sprite in sprites)
		{
			NSString *identifier = [sprite identifier];
			if (![triggerKeys containsObject:identifier] && sprite != sceneObject)
			{
				[actionTriggerSpritesAddPopUp addItemWithTitle:[sprite name]];
				titleAdded = YES;
			}
		}
		
		if (!titleAdded)
		{
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No Available Sprites" action:NULL keyEquivalent:@""];
			[item setEnabled:NO];
			[[actionTriggerSpritesAddPopUp menu] addItem:item];
		}
	
		[actionTriggerSpritesAddPopUp performClick:nil];
	}
	else
	{
		KGCAction *action = [self currentAction];
		NSMutableArray *triggerKeys = [action triggerKeys];
		if (!triggerKeys)
		{
			triggerKeys = [[NSMutableArray alloc] init];
			[action setTriggerKeys:triggerKeys];
		}
	
		[triggerKeys addObject:[sender titleOfSelectedItem]];
		[[self actionTriggerSpritesTableView] reloadData];
	}
}

- (IBAction)deleteActionTriggerSprite:(id)sender
{
	NSMutableArray *triggerKeys = [[self currentAction] triggerKeys];
	NSTableView *actionTriggerSpritesTableView = [self actionTriggerSpritesTableView];
	NSInteger index = [actionTriggerSpritesTableView selectedRow];
	
	if (index > -1)
	{
		[triggerKeys removeObjectAtIndex:index];
		[actionTriggerSpritesTableView reloadData];
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
	return [[[self sceneObject] actions] count];
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
	
	return [[self sceneObject] actions][row];
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
		
		NSTextField *nameTextField = [self nameTextField];
		[nameTextField setStringValue:[spriteAction name]];
		[nameTextField setEnabled:YES];
		
		NSPopUpButton *triggerPopupButon = [self triggerPopupButton];
		KGCActionTrigger actionTrigger = [spriteAction actionTrigger];
		[triggerPopupButon selectItemAtIndex:actionTrigger];
		[triggerPopupButon setEnabled:YES];
		
		NSTabView *triggerOptionsTabView = [self triggerOptionsTabView];
		[triggerOptionsTabView setHidden:NO];
		
		if (actionTrigger == KGCActionTriggerDrop || actionTrigger == KGCActionTriggerDropped || actionTrigger == KGCActionTriggerLink || actionTrigger == KGCActionTriggerUnlink)
		{
			[triggerOptionsTabView selectTabViewItemAtIndex:1];
		}
		else if (actionTrigger == KGCActionTriggerNotification)
		{
			[triggerOptionsTabView selectTabViewItemAtIndex:2];
			[[self triggerNotificationNameField] setStringValue:[spriteAction actionTriggerNotificationName]];
		}
		else
		{
			[triggerOptionsTabView selectTabViewItemAtIndex:0];
		}
		
		[[self actionTypeField] setStringValue:[spriteAction actionTypeDisplayName]];
		[[self actionTriggerSpritesEditButton] setEnabled:actionTrigger == KGCActionTriggerDrop || actionTrigger == KGCActionTriggerDropped || actionTrigger == KGCActionTriggerLink || actionTrigger == KGCActionTriggerUnlink];
		
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
		
		NSView *actionInfoView = (NSView *)[spriteAction infoViewForSceneLayer:[self sceneLayer]];
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
		NSTextField *nameTextField = [self nameTextField];
		[nameTextField setStringValue:@""];
		[nameTextField setEnabled:NO];
		
		NSPopUpButton *triggerPopupButon = [self triggerPopupButton];
		[triggerPopupButon selectItemAtIndex:0];
		[triggerPopupButon setEnabled:NO];
		
		NSTabView *triggerOptionsTabView = [self triggerOptionsTabView];
		[triggerOptionsTabView setHidden:YES];
		
		[[self actionTypeField] setStringValue:@""];
		[[self actionTriggerSpritesEditButton] setEnabled:NO];
		
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

@end