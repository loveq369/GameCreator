//
//	KGCSettingsView.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSceneLayer.h"

@class KGCSceneObject;
@class KGCSceneLayer;

/** A settings view for the different inspectors */
@interface KGCSettingsView : NSView

/** Setup an settings view
 *	@param layer The layer where the settings are for
 *	@param object The settings object (like an action, animation and more)
 */
- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object;

/** The layer where the settings are for */
@property (nonatomic, weak, readonly) KGCSceneLayer *sceneLayer;

- (KGCSceneObject *)sceneObject;

@end