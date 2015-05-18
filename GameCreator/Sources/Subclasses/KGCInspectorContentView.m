//
//	KGCInspectorContentView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 13-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCInspectorContentView.h"

@implementation KGCInspectorContentView
{
	CGFloat _arrowLocation;
}

- (instancetype)initWithFrame:(NSRect)frameRect arrowLocation:(CGFloat)arrowLocation
{
	self = [super initWithFrame:frameRect];
	
	if (self)
	{
		_arrowLocation = arrowLocation;
	}
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	CGFloat cornerRadius = 12.0;
	NSRect bounds = [self bounds];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(cornerRadius, bounds.size.height - 8.0)];
	[path lineToPoint:NSMakePoint(_arrowLocation - 8.0, bounds.size.height - 8.0)];
	[path lineToPoint:NSMakePoint(_arrowLocation, bounds.size.height)];
	[path lineToPoint:NSMakePoint(_arrowLocation + 8.0, bounds.size.height - 8.0)];
	[path lineToPoint:NSMakePoint(bounds.size.width - cornerRadius, bounds.size.height - 8.0)];
	[path curveToPoint:NSMakePoint(bounds.size.width, (bounds.size.height - 8.0) - 20.0) controlPoint1:NSMakePoint(bounds.size.width, bounds.size.height - 8.0) controlPoint2:NSMakePoint(bounds.size.width, bounds.size.height - 8.0)];
	[path lineToPoint:NSMakePoint(bounds.size.width, cornerRadius)];
	[path curveToPoint:NSMakePoint(bounds.size.width - cornerRadius, 0.0) controlPoint1:NSMakePoint(bounds.size.width, 0.0) controlPoint2:NSMakePoint(bounds.size.width, 0.0)];
	[path lineToPoint:NSMakePoint(cornerRadius, 0.0)];
	[path curveToPoint:NSMakePoint(0.0, cornerRadius) controlPoint1:NSMakePoint(0.0, 0.0) controlPoint2:NSMakePoint(0.0, 0.0)];
	[path lineToPoint:NSMakePoint(0.0, (bounds.size.height - 8.0) - cornerRadius)];
	[path curveToPoint:NSMakePoint(cornerRadius, bounds.size.height - 8.0) controlPoint1:NSMakePoint(0.0, bounds.size.height - 8.0) controlPoint2:NSMakePoint(0.0, bounds.size.height - 8.0)];
	[[NSColor colorWithDeviceWhite:243.0 / 255.0 alpha:1.0] set];
	[path fill];
	[[NSColor blackColor] set];
}

@end
