//
//	KGCMenuInspector.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCMenuInspector.h"
#import "KGCSpriteLayer.h"
#import "KGCSceneLayer.h"
#import "KGCMenuSceneController.h"
#import "KGCMenuSpriteController.h"
#import "KGCDADEventsController.h"
#import "KGCAnimationsController.h"

@interface KGCMenuInspector ()

@property (nonatomic, weak) IBOutlet NSSegmentedControl *inspectorChooser;
@property (nonatomic, weak) IBOutlet NSView *inspectorView;
@property (nonatomic, weak) IBOutlet NSView *inspectorContentView;

@property (nonatomic, strong) KGCMenuSceneController *sceneController;
@property (nonatomic, strong) KGCMenuSpriteController *spriteController;
@property (nonatomic, strong) KGCDADEventsController *eventController;
@property (nonatomic, strong) KGCAnimationsController *animationsController;

@end

@implementation KGCMenuInspector

#pragma mark - Initial Methods

- (instancetype)init
{
	self = [super init];
	
	if (self)
	{
		_sceneController = [[KGCMenuSceneController alloc] initWithNibName:nil bundle:nil];
		_spriteController = [[KGCMenuSpriteController alloc] initWithNibName:nil bundle:nil];
		_eventController = [[KGCDADEventsController alloc] initWithNibName:nil bundle:nil];
		_animationsController = [[KGCAnimationsController alloc] initWithNibName:nil bundle:nil];
	
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"KGCMenuInspector" bundle:nil];
		[nib instantiateWithOwner:self topLevelObjects:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSString *indexString = [NSString stringWithFormat:@"%@LastIndex", NSStringFromClass([self class])];
	[[self inspectorChooser] selectSegmentWithTag:[[NSUserDefaults standardUserDefaults] integerForKey:indexString]];
	[self selectInspector:nil];
}

#pragma mark - Main Method

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	[super setupWithSceneLayer:sceneLayer];
	
	NSArray *inspectorControllers = @[[self generalController], [self eventController], [self animationsController]];
	[inspectorControllers makeObjectsPerformSelector:@selector(setupWithSceneLayer:) withObject:sceneLayer];
	
	[self selectInspector:nil];
}

- (void)update
{
	[[self currentViewController] update];
}

#pragma mark - Interface Actions

- (IBAction)selectInspector:(id)sender
{
	NSSegmentedControl *inspectorChooser = [self inspectorChooser];
	NSInteger index = [inspectorChooser selectedSegment];
	NSString *indexString = [NSString stringWithFormat:@"%@LastIndex", NSStringFromClass([self class])];
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:indexString];
	NSView *inspectorContentView = [self inspectorContentView];
	NSRect inspectorContentViewFrame = [inspectorContentView frame];
	[[inspectorContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	NSArray *inspectorControllers = @[[self generalController], [self eventController], [self animationsController]];
	KGCInspectorViewController *inspectorController = inspectorControllers[index];
	[inspectorController update];
	NSView *inspectorSubview = [inspectorController view];
	NSRect inspectorSubviewFrame = [inspectorSubview frame];
	inspectorSubviewFrame.origin = NSZeroPoint;
	inspectorSubviewFrame.size.height = inspectorContentViewFrame.size.height;
	[inspectorSubview setFrame:inspectorSubviewFrame];
	[inspectorContentView addSubview:inspectorSubview];
}

#pragma mark - Convenient Methods

- (KGCInspectorViewController *)generalController
{
	if ([[self sceneLayer] isKindOfClass:[KGCSpriteLayer class]])
	{
		return [self spriteController];
	}
	
	return [self sceneController];
}

- (KGCInspectorViewController *)currentViewController
{
	NSSegmentedControl *inspectorChooser = [self inspectorChooser];
	NSInteger index = [inspectorChooser selectedSegment];
	NSArray *inspectorControllers = @[[self generalController], [self eventController], [self animationsController]];
	return inspectorControllers[index];
}

@end