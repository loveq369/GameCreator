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

- (void)setupWithSceneLayers:(NSArray *)sceneLayers;
- (void)update;

@property (nonatomic, weak, readonly) NSArray *sceneLayers;
@property (nonatomic, weak) NSWindow *window;

- (void)setup;
- (NSView *)inspectorView;
- (NSArray *)inspectorControllers;

@end