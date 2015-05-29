//
//	KGCInspectorController.h
//	GameCreator
//
//	Created by Maarten Foukhar on 11-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGCSceneLayer.h"
#import "KGCInspector.h"

@interface KGCInspectorController : NSObject

- (void)setupWithSceneLayers:(NSArray *)sceneLayers;
- (void)update;

@property (nonatomic, weak, readonly) NSWindow *window;
@property (nonatomic, weak, readonly) NSView *inspectorContainerView;

@end