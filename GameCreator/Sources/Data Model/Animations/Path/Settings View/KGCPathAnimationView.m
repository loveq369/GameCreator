//
//	KGCPathAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCPathAnimationView.h"
#import "KGCPathAnimation.h"
#import "KGCSceneLayer.h"
#import "KGCSceneContentView.h"

@interface KGCPathAnimationView () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *shapePopup;
@property (nonatomic, weak) IBOutlet NSTabView *subSettingsTabView;

@property (nonatomic, weak) IBOutlet NSTextField *frameXField;
@property (nonatomic, weak) IBOutlet NSTextField *frameYField;
@property (nonatomic, weak) IBOutlet NSTextField *frameWidthField;
@property (nonatomic, weak) IBOutlet NSTextField *frameHeightField;
@property (nonatomic, weak) IBOutlet NSTextField *degreesField;
@property (nonatomic, weak) IBOutlet NSButton *clockWiseButton;

@property (nonatomic, weak) IBOutlet NSTableView *pointsTableView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSButton *deleteButton;
@property (nonatomic, weak) IBOutlet NSButton *startInteractiveModeButton;

@end

@implementation KGCPathAnimationView
{
	KGCPathAnimation *_animation;
}

- (void)awakeFromNib
{
	[[self subSettingsTabView] selectTabViewItemAtIndex:0];
}

- (void)setupWithSceneLayers:(NSArray *)sceneLayers withSettingsObject:(id)object
{
	[super setupWithSceneLayers:sceneLayers withSettingsObject:object];
	
	_animation = object;
	KGCPathAnimatorShape shape = [_animation shape];
	[[self subSettingsTabView] selectTabViewItemAtIndex:shape];
	[[self shapePopup] selectItemAtIndex:shape];
	
	[[self durationField] setDoubleValue:[_animation duration]];
	
	if (shape == KGCPathAnimatorShapeCircle) {
		NSRect shapeRect = [_animation shapeRect];
		[[self frameXField] setDoubleValue:shapeRect.origin.x];
		[[self frameYField] setDoubleValue:shapeRect.origin.y];
		[[self frameWidthField] setDoubleValue:shapeRect.size.width];
		[[self frameHeightField] setDoubleValue:shapeRect.size.height];
		[[self degreesField] setDoubleValue:[_animation degrees]];
		[[self clockWiseButton] setState:[_animation clockWise]];
	}
}

#pragma mark - Interface Methods

- (IBAction)changeDuration:(id)sender
{
	[_animation setDuration:[sender doubleValue]];
}

- (IBAction)changeShape:(id)sender
{
	NSInteger index = [sender indexOfSelectedItem];
	[_animation setShape:index];
	
	NSInteger tabIndex = 0;
	if (index == 0 || index == 1)
	{
		tabIndex = 0;
	}
	else if (index == 2)
	{
		tabIndex = 1;
	}
	[[self subSettingsTabView] selectTabViewItemAtIndex:tabIndex];
}


- (IBAction)changeX:(id)sender
{
	NSRect frame = [_animation shapeRect];
	frame.origin.x = [sender doubleValue];
	[_animation setShapeRect:frame];
}

- (IBAction)changeY:(id)sender
{
	NSRect frame = [_animation shapeRect];
	frame.origin.y = [sender doubleValue];
	[_animation setShapeRect:frame];
}

- (IBAction)changeWidth:(id)sender
{
	NSRect frame = [_animation shapeRect];
	frame.size.width = [sender doubleValue];
	[_animation setShapeRect:frame];
}

- (IBAction)changeHeight:(id)sender
{
	NSRect frame = [_animation shapeRect];
	frame.size.height = [sender doubleValue];
	[_animation setShapeRect:frame];
}

- (IBAction)changeDegrees:(id)sender
{
	[_animation setDegrees:[sender doubleValue]];
}

- (IBAction)changeClockWise:(id)sender
{
	[_animation setClockWise:[sender integerValue]];
}

- (IBAction)startInteractiveMode:(id)sender
{
//	[[[_animation sceneLayer] sceneContentView] setPositionEditModeActive:YES];
}

- (IBAction)add:(id)sender
{
//	NSPoint position = [[_animation sceneLayer] position];
//	NSDictionary *positionDictionary = @{@"x" : @(position.x), @"y" : @(position.y)};
//	[[_animation shapePoints] addObject:positionDictionary];
}

- (IBAction)delete:(id)sender
{
	NSInteger selectedRow = [[self pointsTableView] selectedRow];
	
	if (selectedRow > -1)
	{
		[[_animation shapePoints] removeObjectAtIndex:selectedRow];
	}
	else
	{
		NSBeep();
	}
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[_animation shapePoints] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSDictionary *pointDictionary = [_animation shapePoints][row];
	NSString *name = [NSString stringWithFormat:@"x: %f, y: %f", [pointDictionary[@"x"] doubleValue], [pointDictionary[@"y"] doubleValue]];

	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ActionTableCell" owner:nil];
	[[tableCellView textField] setStringValue:name];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}

@end