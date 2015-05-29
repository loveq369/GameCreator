//
//	KGCImageLayer.m
//	GameCreator
//
//	Created by Maarten Foukhar on 07-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCImageLayer.h"
#import <AppKit/AppKit.h>

@implementation KGCImageLayer

+ (instancetype)layerWithImage:(NSImage *)image
{
	KGCImageLayer *layer = [KGCImageLayer layer];
	[CATransaction begin];
	[CATransaction setAnimationDuration:0.0];
	[layer setImage:image];
	[CATransaction commit];
	
	return layer;
}

- (void)setImage:(NSImage *)image
{
	_image = image;

	if (image)
	{
		[self setContents:(id)[image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil]];
	}
	else
	{
		[self setContents:nil];
	}
}

@end