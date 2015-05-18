//
//	KGCInspectorController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 11-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCInspectorController.h"
#import "KGCBasicInspector.h"
#import "KGCDADInspector.h"
#import "KGCDADShapeInspector.h"
#import "KGCMenuInspector.h"
#import "KGCScene.h"

@interface KGCInspectorController ()

@property (nonatomic, weak) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet KGCSceneContentView *sceneView;
@property (nonatomic, weak) IBOutlet NSView *inspectorContainerView;
@property (nonatomic, weak) IBOutlet NSTextField *noScenesField;

@end

@implementation KGCInspectorController
{
	KGCInspector *_inspector;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	NSView *inspectorContainerView = [self inspectorContainerView];
	[[inspectorContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

	if (sceneLayer)
	{
		[[self noScenesField] setHidden:YES];
	
		KGCSceneObject *sceneObject = [sceneLayer sceneObject];
		KGCScene *scene;
		if ([sceneObject isKindOfClass:[KGCScene class]])
		{
			scene = (KGCScene *)sceneObject;
		}
		else
		{
			scene = (KGCScene *)[sceneObject parentObject];
		}
		
		Class inspectorClasses[4] = {[KGCBasicInspector class], [KGCDADInspector class], [KGCDADShapeInspector class], [KGCMenuInspector class]};
		Class inspectorClass = inspectorClasses[[scene templateType]];
		_inspector = [[inspectorClass alloc] init];
		[_inspector setWindow:[self window]];
		
		NSView *inspectorView = [_inspector inspectorView];
		[inspectorView setFrame:[inspectorContainerView bounds]];
		[inspectorContainerView addSubview:inspectorView];
		
		[_inspector setupWithSceneLayer:sceneLayer];
	}
	else
	{
		[[self noScenesField] setHidden:NO];
	}
}

- (void)update
{
	[_inspector update];
}

@end