//
//	KGCInspector.h
//	GameCreator
//
//	Created by Maarten Foukhar on 11-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KGCSceneLayer;

@interface KGCInspector : NSObject

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer;
- (void)update;

@property (nonatomic, weak, readonly) KGCSceneLayer *sceneLayer;
@property (nonatomic, weak) NSWindow *window;

- (NSView *)inspectorView;

@end