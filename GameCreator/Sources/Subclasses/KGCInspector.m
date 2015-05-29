//
//	KGCInspector.m
//	GameCreator
//
//	Created by Maarten Foukhar on 11-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCInspector.h"
#import "KGCInspectorViewController.h"

@interface KGCInspector ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *inspectorChooserPopUp;
@property (nonatomic, weak) IBOutlet NSView *inspectorView;
@property (nonatomic, weak) IBOutlet NSView *inspectorContentView;

@end

@implementation KGCInspector

- (instancetype)init
{
	self = [super init];
	
	if (self)
	{
		[self setup];
	
		NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([self class]) bundle:nil];
		[nib instantiateWithOwner:self topLevelObjects:nil];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	NSString *indexString = [NSString stringWithFormat:@"%@LastIndex", NSStringFromClass([self class])];
	[[self inspectorChooserPopUp] selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:indexString]];
	[self selectInspector:nil];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	_sceneLayers = sceneLayers;
	
	[[self inspectorControllers] makeObjectsPerformSelector:@selector(setupWithSceneLayers:) withObject:sceneLayers];
	
	[self selectInspector:nil];
}

- (void)update
{
	[[self currentViewController] update];
}

#pragma mark - Interface Actions

- (IBAction)selectInspector:(id)sender
{
	NSPopUpButton *inspectorChooserPopUp = [self inspectorChooserPopUp];
	NSInteger index = [inspectorChooserPopUp indexOfSelectedItem];
	NSString *indexString = [NSString stringWithFormat:@"%@LastIndex", NSStringFromClass([self class])];
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:indexString];
	NSView *inspectorContentView = [self inspectorContentView];
	NSRect inspectorContentViewFrame = [inspectorContentView frame];
	[[inspectorContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	KGCInspectorViewController *inspectorController = [self inspectorControllers][index];
	NSView *inspectorSubview = [inspectorController view];
	NSRect inspectorSubviewFrame = [inspectorSubview frame];
	inspectorSubviewFrame.origin = NSZeroPoint;
	inspectorSubviewFrame.size.height = inspectorContentViewFrame.size.height;
	[inspectorSubview setFrame:inspectorSubviewFrame];
	[inspectorContentView addSubview:inspectorSubview];
}

#pragma mark - Subclass Methods

- (void)setup {};

- (NSArray *)inspectorControllers {return nil;};

#pragma mark - Convenient Methods

- (KGCInspectorViewController *)currentViewController
{
	NSPopUpButton *inspectorChooserPopUp = [self inspectorChooserPopUp];
	NSInteger index = [inspectorChooserPopUp indexOfSelectedItem];
	return [self inspectorControllers][index];
}

@end