//
//	KGCFadeAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

@interface KGCFadeAnimation : KGCAnimation

/** The animation duration */
@property (nonatomic) CGFloat duration;

/** The alpha to animate the sprite to */
@property (nonatomic) CGFloat alpha;

@end