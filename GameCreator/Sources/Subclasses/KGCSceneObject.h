//
//	KGCSceneObject.h
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDataObject.h"

@class KGCAction;
@class KGCAnimation;
@class KGCEvent;

@interface KGCSceneObject : KGCDataObject

- (NSArray *)actions;
- (void)addAction:(KGCAction *)action;
- (void)removeAction:(KGCAction *)action;

- (NSArray *)animations;
- (void)addAnimation:(KGCAnimation *)animation;
- (void)removeAnimation:(KGCAnimation *)animation;

- (NSArray *)events;
- (void)addEvent:(KGCEvent *)event;
- (void)removeEvent:(KGCEvent *)event;

@end