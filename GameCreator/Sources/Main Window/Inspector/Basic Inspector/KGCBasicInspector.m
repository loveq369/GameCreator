//
//	KGCSpriteController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 16-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCBasicInspector.h"
#import "KGCAction.h"
#import "KGCFileDropView.h"
#import "KGCAnimation.h"
#import "KGCInspectorWindow.h"
#import "KGCSceneController.h"
#import "KGCSpriteController.h"
#import "KGCActionController.h"
#import "KGCAnimationsController.h"

@interface KGCBasicInspector ()

@property (nonatomic, weak) IBOutlet NSSegmentedControl *inspectorChooser;
@property (nonatomic, weak) IBOutlet NSView *inspectorView;
@property (nonatomic, weak) IBOutlet NSView *inspectorContentView;

@property (nonatomic, strong) KGCSceneController *sceneController;
@property (nonatomic, strong) KGCSpriteController *spriteController;
@property (nonatomic, strong) KGCActionController *eventController;
@property (nonatomic, strong) KGCAnimationsController *animationsController;

@end

@implementation KGCBasicInspector

#pragma mark - Initial Methods

- (instancetype)init
{
	self = [super init];
	
	if (self)
	{
		_sceneController = [[KGCSceneController alloc] initWithNibName:nil bundle:nil];
		_spriteController = [[KGCSpriteController alloc] initWithNibName:nil bundle:nil];
		_eventController = [[KGCActionController alloc] initWithNibName:nil bundle:nil];
		_animationsController = [[KGCAnimationsController alloc] initWithNibName:nil bundle:nil];
	
		NSNib *nib = [[NSNib alloc] initWithNibNamed:@"KGCBasicInspector" bundle:nil];
		[nib instantiateWithOwner:self topLevelObjects:nil];
	}
	
	return self;
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

#pragma mark - Interface Actions

- (IBAction)selectInspector:(id)sender
{
//	[self stopCurrentAnimation];

	NSSegmentedControl *inspectorChooser = [self inspectorChooser];
	NSInteger index = [inspectorChooser selectedSegment];
	NSString *indexString = [NSString stringWithFormat:@"%@LastIndex", NSStringFromClass([self class])];
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:indexString];
	NSView *inspectorContentView = [self inspectorContentView];
	NSRect inspectorContentViewFrame = [inspectorContentView frame];
	[[inspectorContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	NSArray *inspectorControllers = @[[self generalController], [self eventController], [self animationsController]];
	KGCInspectorViewController *inspectorController = inspectorControllers[index];
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

@end