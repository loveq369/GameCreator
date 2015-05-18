//
//	KGCPositionAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

@interface KGCPositionAnimation : KGCAnimation

/** The duration of the animation */
@property (nonatomic) CGFloat duration;

/** The end position of the animation */
@property (nonatomic) NSPoint endPosition;

@end