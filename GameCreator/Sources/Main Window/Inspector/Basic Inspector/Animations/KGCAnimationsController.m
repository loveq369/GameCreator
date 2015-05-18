//
//	KGCAnimationsController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCAnimationsController.h"
#import "KGCAnimation.h"
#import "KGCSceneLayer.h"
#import "KGCSceneObject.h"
#import "KGCBasicTableCell.h"

@interface KGCAnimationsController () <NSTableViewDataSource, NSTableViewDelegate, KGCBasicTableCellDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *animationsTableView;
@property (nonatomic, weak) IBOutlet NSButton *animationBarButton;
@property (nonatomic, weak) IBOutlet NSButton *animationAddButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *animationAddPopUp;
@property (nonatomic, weak) IBOutlet NSTextField *animationNameField;
@property (nonatomic, weak) IBOutlet NSTextField *animationTypeField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *repeatModePopup;
@property (nonatomic, weak) IBOutlet NSTextField *repeatCountField;
@property (nonatomic, weak) IBOutlet NSButton *resetButton;
@property (nonatomic, weak) IBOutlet NSButton *previewButton;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (nonatomic, weak) IBOutlet NSView *animationSettingsView;

@end

@implementation KGCAnimationsController
{
	KGCAnimation *_currentAnimation;
}

#pragma mark - Main Method

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{	
	[super setupWithSceneLayer:sceneLayer];
	
	[[self animationsTableView] reloadData];
	[self updateCurrentAnimation];
}

#pragma mark - Interface Methods

- (IBAction)animationAdd:(id)sender
{
	if (sender == [self animationAddButton])
	{
		[[self animationAddPopUp] performClick:nil];
	}
	else
	{
		KGCSceneObject *sceneObject = [self sceneObject];
		
		KGCAnimationType animationType = [sender indexOfSelectedItem];
		KGCAnimation *newAnimation = [KGCAnimation newAnimationWithType:animationType document:[sceneObject document]];
		[sceneObject addAnimation:newAnimation];
		
		NSTableView *animationsTableView = [self animationsTableView];
		[animationsTableView reloadData];
		NSArray *animations = [sceneObject animations];
		[animationsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[animations count] -1] byExtendingSelection:NO];
	}
}

- (IBAction)animationDelete:(id)sender
{
	KGCAnimation *animation = [self currentAnimation];	
	if (animation)
	{
		[[self sceneObject] removeAnimation:animation];
		[[self animationsTableView] reloadData];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)changeAnimationIdentifier:(id)sender
{
	[[self currentAnimation] setName:[sender stringValue]];
}

- (IBAction)changeRepeatMode:(id)sender
{
	[[self currentAnimation] setRepeatMode:[sender indexOfSelectedItem]];
}

- (IBAction)changeRepeatCount:(id)sender
{
	[[self currentAnimation] setRepeatCount:[sender integerValue]];
}

- (IBAction)preview:(id)sender
{
	if ([[sender title] isEqualTo:@"Stop"])
	{
		[self stopCurrentAnimation];
	}
	else
	{
		[sender setTitle:@"Stop"];
		
		KGCSceneObject *sceneObject = [self sceneObject];
		KGCSceneLayer *sceneLayer = [self sceneLayer];
		
		[sceneLayer setPreviewModeEnabled:YES];
		
		NSProgressIndicator *activityIndicator = [self activityIndicator];
		[activityIndicator startAnimation:nil];

		NSUInteger row = [[self animationsTableView] selectedRow];
		KGCAnimation *animation = [sceneObject animations][row];
		_currentAnimation = animation;
		[animation startAnimationOnLayer:sceneLayer completion:^
		{
			[sender setTitle:@"Preview"];
			[sender setEnabled:NO];
		
			[[self resetButton] setEnabled:YES];
			[activityIndicator stopAnimation:nil];
		}];
	}
}

- (IBAction)stopPreview:(id)sender
{
	[[self resetButton] setEnabled:NO];
	
	KGCSceneLayer *sceneLayer = [self sceneLayer];
	
	NSProgressIndicator *activityIndicator = [self activityIndicator];
	[activityIndicator startAnimation:nil];
	
	[_currentAnimation resetAnimationOnLayer:sceneLayer completion:^
	{
		[[self previewButton] setEnabled:YES];
		[sceneLayer setPreviewModeEnabled:NO];
		[activityIndicator stopAnimation:nil];
	}];
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[[self sceneObject] animations] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	KGCAnimation *animation = [self animationForRow:row];
	
	KGCBasicTableCell *tableCellView = (KGCBasicTableCell *)[tableView makeViewWithIdentifier:@"AnimationTableCell" owner:nil];
	[[tableCellView textField] setStringValue:[animation name]];
	[tableCellView setDelegate:self];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self stopCurrentAnimation];
	[self updateCurrentAnimation];
}

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
		// Support for us being a dragging source
		return nil;
}

#pragma mark - BasicTableCell Delegate Methods

- (void)basicTableCell:(KGCBasicTableCell *)basicTableCell didChangeText:(NSString *)newText
{
	KGCAnimation *animation = [self currentAnimation];
	[animation setName:newText];
}

#pragma mark - Convenient Methods

- (KGCAnimation *)animationForRow:(NSUInteger)row
{
	if (row == -1)
	{
		return nil;
	}
	
	return [[self sceneObject] animations][row];
}

- (KGCAnimation *)currentAnimation
{
	return [self animationForRow:[[self animationsTableView] selectedRow]];
}

- (void)updateCurrentAnimation
{
	NSTableView *animationsTableView = [self animationsTableView];
	NSInteger row = [animationsTableView selectedRow];

	if (row != -1)
	{
		KGCSceneObject *sceneObject = [self sceneObject];
		KGCAnimation *animation = [sceneObject animations][row];
		
		NSTextField *animationNameField = [self animationNameField];
		[animationNameField setStringValue:[animation name]];
		[animationNameField setEnabled:YES];
		
		[[self animationTypeField] setStringValue:[animation animationTypeDisplayName]];
		
		NSPopUpButton *repeatModePopup = [self repeatModePopup];
		[repeatModePopup selectItemAtIndex:[animation repeatMode]];
		[repeatModePopup setEnabled:YES];
		
		NSTextField *repeatCountField = [self repeatCountField];
		[repeatCountField setDoubleValue:[animation repeatCount]];
		[repeatCountField setEnabled:YES];
		
		NSView *animationSettingsView = [self animationSettingsView];
		NSRect animationSettingsViewFrame = [animationSettingsView frame];
		[[animationSettingsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
		NSView *animationInfoView = (NSView *)[animation infoViewForSceneLayer:[self sceneLayer]];
		if (animationInfoView)
		{
			NSRect animationInfoViewFrame = [animationInfoView frame];
			animationInfoViewFrame.size.height = animationSettingsViewFrame.size.height;
			[animationInfoView setFrame:animationInfoViewFrame];
			[animationSettingsView addSubview:animationInfoView];
		}
		
		BOOL isPreviewModeEnabled = [[self sceneLayer] isPreviewModeEnabled];
		[[self previewButton] setEnabled:!isPreviewModeEnabled && [animation hasPreview]];
		[[self resetButton] setEnabled:isPreviewModeEnabled];
	}
	else
	{
		NSTextField *animationNameField = [self animationNameField];
		[animationNameField setStringValue:@""];
		[animationNameField setEnabled:NO];
		
		[[self animationTypeField] setStringValue:@""];
		
		NSPopUpButton *repeatModePopup = [self repeatModePopup];
		[repeatModePopup selectItemAtIndex:0];
		[repeatModePopup setEnabled:NO];
		
		NSTextField *repeatCountField = [self repeatCountField];
		[repeatCountField setDoubleValue:0.0];
		[repeatCountField setEnabled:NO];
		
		[[self previewButton] setEnabled:NO];
		[[self resetButton] setEnabled:NO];
		
		[[[self animationSettingsView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	}
}

- (void)stopCurrentAnimation
{
	if (_currentAnimation)
	{
		[[self activityIndicator] stopAnimation:nil];
		[[self previewButton] setTitle:@"Preview"];
		[[self resetButton] setEnabled:NO];
		[[self sceneLayer] setPreviewModeEnabled:NO];

		[_currentAnimation abortAnimationOnLayer:[self sceneLayer] completion:^
		{
			_currentAnimation = nil;
		}];
	}
}

@end