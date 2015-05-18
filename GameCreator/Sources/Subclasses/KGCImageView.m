//
//	KGCImageView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 12-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCImageView.h"
#import "KGCImageLayer.h"

@implementation KGCImageView

- (instancetype)initWithImage:(NSImage *)image
{
	NSSize imageSize = [image size];
	self = [super initWithFrame:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height)];
	
	if (self)
	{
		[self setup];
		[self setImage:image];
	}
	
	return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	if (self)
	{
		[self setup];
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	if (self)
	{
		[self setup];
	}
	
	return self;
}

- (void)setup
{
	[self setWantsLayer:YES];
	[[self superview] setWantsLayer:YES];

	KGCImageLayer *layer = [KGCImageLayer layer];
	[layer setAnchorPoint:CGPointZero];
	[layer setBounds:[self bounds]];
	[self setLayer:layer];
}

- (void)setImage:(NSImage *)image
{
	[(KGCImageLayer *)[self layer] setImage:image];
}

- (NSImage *)image
{
	return [(KGCImageLayer *)[self layer] image];
}

@end
