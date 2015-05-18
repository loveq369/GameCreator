//
//	KGCImageAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

@interface KGCImageAnimation : KGCAnimation

/** The sprite frames */
- (NSMutableArray *)spriteImageNames;

/** The duration of each frame */
@property (nonatomic) NSTimeInterval frameDuration;

@end