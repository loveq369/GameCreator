//
//	KGCSpriteLayer.h
//	GameCreator
//
//	Created by Maarten Foukhar on 07-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KGCSceneLayer.h"
#import "KGCSprite.h"

@interface KGCSpriteLayer : KGCSceneLayer

- (void)update;

@property (nonatomic, getter = isSelected) BOOL selected;

- (void)setPosition:(CGPoint)position animated:(BOOL)animated;
- (void)setRotationDegrees:(CGFloat)degrees animated:(BOOL)animated;

@end