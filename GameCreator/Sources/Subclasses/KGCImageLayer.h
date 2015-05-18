//
//	KGCImageLayer.h
//	GameCreator
//
//	Created by Maarten Foukhar on 07-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface KGCImageLayer : CALayer

+ (instancetype)layerWithImage:(NSImage *)image;
@property (nonatomic, copy) NSImage *image;

@end