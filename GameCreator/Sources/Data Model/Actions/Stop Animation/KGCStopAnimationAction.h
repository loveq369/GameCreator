//
//	KGCStopAnimationAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

typedef NS_ENUM(NSUInteger, KGCStopAnimationActionType)
{
    KGCStopAnimationActionTypeNone,
    KGCStopAnimationActionTypeSingle,
    KGCStopAnimationActionTypeAll,
};

@interface KGCStopAnimationAction : KGCAction

@property (nonatomic) KGCStopAnimationActionType stopAnimationType;

@property (nonatomic) NSString *animationIdentifier;

@end