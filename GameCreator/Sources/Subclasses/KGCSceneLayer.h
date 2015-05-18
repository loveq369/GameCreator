//
//	KGCSceneLayer.h
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KGCImageLayer.h"
#import "KGCSceneContentView.h"

@class KGCSceneObject;

@interface KGCSceneLayer : KGCImageLayer

+ (instancetype)layerWithSceneObject:(KGCSceneObject *)sceneObject sceneContentView:(KGCSceneContentView *)sceneContentView;
- (void)setupWithSceneObject:(KGCSceneObject *)sceneObject;

@property (nonatomic, weak, readonly) KGCSceneContentView *sceneContentView;
@property (nonatomic, weak, readonly) KGCSceneObject *sceneObject;
- (KGCResourceController *)resourceController;
@property (nonatomic, getter = isPreviewModeEnabled) BOOL previewModeEnabled;

- (CGRect)realBounds;

@end