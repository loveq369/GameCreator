//
//	KGCInspectorWindow.m
//	GameCreator
//
//	Created by Maarten Foukhar on 13-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCInspectorWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "NSBezierPath+CGPath.h"
#import "KGCInspectorContentView.h"

@implementation KGCInspectorWindow
{
	NSView *_view;
}

- (instancetype)initWithView:(NSView *)view arrowLocation:(CGFloat)arrowLocation
{
	NSRect viewBounds = [view bounds];
	
	self = [super initWithContentRect:viewBounds styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	if (self)
	{
		_view = view;
	
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setHasShadow:YES];
		
		NSRect frame = [self frame];
		KGCInspectorContentView *inspectorContentView = [[KGCInspectorContentView alloc] initWithFrame:NSMakeRect(0.0, 0.0, frame.size.width, frame.size.height) arrowLocation:arrowLocation];
		[inspectorContentView addSubview:_view];
		[self setContentView:inspectorContentView];
	}
	
	return self;
}

- (void)setup
{
	
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderOut:) name:NSWindowDidResignMainNotification object:self];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderOut:) name:NSWindowDidResignKeyNotification object:self];
}

- (void)showAnimated:(BOOL)animated
{
	[self makeKeyAndOrderFront:nil];
	[[_view layer] setOpacity:1.0];
	[[[self contentView] layer] setOpacity:1.0];
}

- (BOOL)canBecomeKeyWindow
{ 
		return YES; 
}

//- (BOOL)canBecomeMainWindow
//{ 
//		return YES; 
//}

@end