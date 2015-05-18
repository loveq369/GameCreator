//
//	KGCPathAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAnimation.h"

/** The path animators shapes (or free form) */
typedef NS_ENUM(NSInteger, KGCPathAnimatorShape)
{
	KGCPathAnimatorShapeCircle,
	KGCPathAnimatorShapeSquare,
	KGCPathAnimatorShapeFreeForm
};

@interface KGCPathAnimation : KGCAnimation

/** The duration of the animation */
@property (nonatomic) CGFloat duration;

/** The shape of the path */
@property (nonatomic) KGCPathAnimatorShape shape;

/** The shape frame (only used for none free form shapes) */
@property (nonatomic) NSRect shapeRect;

/** The shape points (only used for the free form shape */
- (NSMutableArray *)shapePoints;

/** The number of degrees to travel */
@property (nonatomic) CGFloat degrees;

/** Clockwise direction */
@property (nonatomic) BOOL clockWise;

@end