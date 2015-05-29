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
- (void)setupWithSceneLayers:(NSArray *)sceneLayers;
- (void)update;
@property (nonatomic, strong, readonly) NSArray *sceneLayers;
@property (nonatomic, strong, readonly) NSArray *sceneObjects;
- (KGCResourceController *)resourceController;
@property (nonatomic, strong, readonly) NSView *view;
- (id)objectForPropertyNamed:(NSString *)propertyName inArray:(NSArray *)objects;
- (void)setObject:(id)object forPropertyNamed:(NSString *)propertyName inArray:(NSArray *)objects;
- (void)setObjectValue:(id)objectValue inTextField:(NSTextField *)textField;
- (void)setObjectValue:(id)objectValue inCheckBox:(NSButton *)checkBox;

@end