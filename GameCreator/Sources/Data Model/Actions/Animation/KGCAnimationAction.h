//
//	KGCAnimationAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 16-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** An action that executes an animation */
@interface KGCAnimationAction : KGCAction

/** The associated animator key */
@property (nonatomic, copy) NSString *animationKey;

@end