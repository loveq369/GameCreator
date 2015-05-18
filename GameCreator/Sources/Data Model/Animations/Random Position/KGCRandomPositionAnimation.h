//
//	KGCRandomPositionAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

@interface KGCRandomPositionAnimation : KGCAnimation

@property (nonatomic) CGFloat duration;
@property (nonatomic) NSPoint minimumPosition;
@property (nonatomic) NSPoint maximumPosition;

@end