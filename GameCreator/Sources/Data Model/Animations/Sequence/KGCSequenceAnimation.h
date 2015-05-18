//
//	KGCSequenceAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

@interface KGCSequenceAnimation : KGCAnimation

/** The animations associated */
- (NSArray *)animations;

/** The animationKeys */
- (NSMutableArray *)animationKeys;

@end