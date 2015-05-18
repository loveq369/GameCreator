//
//	KGCRotationAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

@interface KGCRotationAnimation : KGCAnimation

/** The animation duration */
@property (nonatomic) CGFloat duration;

/** The angle to animate to */
@property (nonatomic) CGFloat angle;

@end