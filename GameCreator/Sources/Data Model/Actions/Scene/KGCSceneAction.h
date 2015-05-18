//
//	KGCSceneAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** A scene transition type */
typedef NS_ENUM(NSInteger, KGCSceneActionTransition)
{
	KGCSceneActionTransitionPush,
	KGCSceneActionTransitionMove,
	KGCSceneActionTransitionFade,
	KGCSceneActionTransitionCrossFade
};

/** A scene transition direction */
typedef NS_ENUM(NSInteger, KGCSceneActionTransitionDirection)
{
	KGCSceneActionTransitionDirectionUp,
	KGCSceneActionTransitionDirectionDown,
	KGCSceneActionTransitionDirectionRight,
	KGCSceneActionTransitionDirectionLeft
};

/** An action that executes a scene transition */
@interface KGCSceneAction : KGCAction

/** The name of the new scene */
@property (nonatomic, copy) NSString *sceneName;

/** The transition type of the new transition scene */
@property (nonatomic) KGCSceneActionTransition transition;

/** The transition direction of the new transition scene */
@property (nonatomic) KGCSceneActionTransitionDirection direction;

@end