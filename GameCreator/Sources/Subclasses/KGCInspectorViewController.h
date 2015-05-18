//
//	KGCInspectorViewController.h
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KGCSceneLayer;
@class KGCSceneObject;
@class KGCResourceController;

@interface KGCInspectorViewController : NSObject

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer;
- (void)update;
@property (nonatomic, weak, readonly) KGCSceneLayer *sceneLayer;
- (KGCSceneObject *)sceneObject;
- (KGCResourceController *)resourceController;
@property (nonatomic, strong, readonly) NSView *view;

@end