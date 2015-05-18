//
//	KGCSceneContentView.h
//	GameCreator
//
//	Created by Maarten Foukhar on 13-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGCDocument.h"

@class KGCScene;
@class KGCSceneContentView;
@class KGCAction;
@class KGCEvent;
@class KGCTemplateAction;
@class KGCSceneLayer;

@protocol KGCSceneViewDelegate <NSObject>

- (void)sceneViewSpriteSelectionChanged:(KGCSceneContentView *)sceneView;

@end

@interface KGCSceneContentView : NSView

- (void)setupWithScene:(KGCScene *)scene;

@property (nonatomic, weak) KGCScene *scene;

@property (nonatomic, weak) IBOutlet id <KGCSceneViewDelegate> delegate;

@property (nonatomic, strong, readonly) KGCSceneLayer *contentLayer;

- (NSArray *)selectedSpriteLayers;

@property (nonatomic) NSSize contentSize;

@property (nonatomic) CGFloat scale;

- (void)setScale:(CGFloat)scale animated:(BOOL)animated;

@property (nonatomic, getter = isPositionEditModeActive) BOOL positionEditModeActive;

- (NSImage *)sceneCaptureImage;

- (NSArray *)spriteLayers;

@property (nonatomic, weak, readonly) KGCDocument *document;

@property (nonatomic, getter = isInteractionDisabled) BOOL interactionDisabled;

@end