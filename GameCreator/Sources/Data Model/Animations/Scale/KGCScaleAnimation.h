//
//	KGCScaleAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

@interface KGCScaleAnimation : KGCAnimation

/** The animation duration */
@property (nonatomic) CGFloat duration;

/** The end scale of the animation */
@property (nonatomic) CGFloat scale;

@end