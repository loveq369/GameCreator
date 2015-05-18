//
//	KGCGameTransitionAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** A scene transition type */
typedef NS_ENUM(NSInteger, KGCGameTransitionActionTransition)
{
	KGCGameTransitionActionTransitionPush,
	KGCGameTransitionActionTransitionMove,
	KGCGameTransitionActionTransitionFade,
	KGCGameTransitionActionTransitionCrossFade
};

/** A scene transition direction */
typedef NS_ENUM(NSInteger, KGCGameTransitionActionTransitionDirection)
{
	KGCGameTransitionActionTransitionDirectionUp,
	KGCGameTransitionActionTransitionDirectionDown,
	KGCGameTransitionActionTransitionDirectionRight,
	KGCGameTransitionActionTransitionDirectionLeft
};

/** An action that executes a scene transition */
@interface KGCGameTransitionAction : KGCAction

@property (nonatomic, copy) NSString *gameIdentifier;

/** The name of the new scene */
@property (nonatomic, copy) NSString *sceneName;

/** The transition type of the new transition scene */
@property (nonatomic) KGCGameTransitionActionTransition transition;

/** The transition direction of the new transition scene */
@property (nonatomic) KGCGameTransitionActionTransitionDirection direction;

@end