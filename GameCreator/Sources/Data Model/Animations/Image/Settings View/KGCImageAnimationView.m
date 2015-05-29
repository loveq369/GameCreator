//
//	KGCImageAnimationView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 10-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCImageAnimationView.h"
#import "KGCImageAnimation.h"

@interface KGCImageAnimationView () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;

@end

@implementation KGCImageAnimationView
{
	KGCImageAnimation *_animation;
}

- (void)setupWithSceneLayers:(NSArray *)sceneLayers withSettingsObject:(id)object
{
	[super setupWithSceneLayers:sceneLayers withSettingsObject:object];
	
	_animation = object;
	
	[[self durationField] setDoubleValue:[_animation frameDuration]];
	[[self tableView] reloadData];
}

#pragma mark - Interface Actions

- (IBAction)changeDuration:(id)sender
{
	[_animation setFrameDuration:[sender doubleValue]];
}

- (IBAction)add:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png", @"jpg"]];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^ (NSModalResponse returnCode)
	{
		if (returnCode == NSOKButton)
		{
			for (NSURL *url in [openPanel URLs])
			{
				KGCResourceController *resourceController = [[_animation document] resourceController];
				NSString *resourceName = [resourceController resourceNameForURL:url type:KGCResourceInfoTypeImage];
				NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
				imageDictionary[@"ImageName"] = resourceName;
				[[_animation spriteImageNames] addObject:imageDictionary];
			}
			
			[_animation updateDictionary];
			[[self tableView] reloadData];
		}
	}];
}

- (IBAction)delete:(id)sender
{
	NSTableView *tableView = [self tableView];
	NSIndexSet *indexSet = [tableView selectedRowIndexes];
	
	if ([indexSet count] > 0)
	{
		[[_animation spriteImageNames] removeObjectsAtIndexes:indexSet];
		[_animation updateDictionary];
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
	return [[_animation spriteImageNames] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString *imageName = [_animation spriteImageNames][row][@"ImageName"];

	NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:@"ActionTableCell" owner:nil];
	[[tableCellView textField] setStringValue:imageName];
	
	return tableCellView;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}

@end