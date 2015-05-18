//
//	KGCFileDropView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 07-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCFileDropView.h"

@implementation KGCFileDropView

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	if (self)
	{
		[self setup];
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

- (void)setup
{
	[self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (BOOL)canBecomeKeyView
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return NSDragOperationEvery;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return NSDragOperationEvery;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	id <KGCFileDropViewDelegate> delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(fileDropView:droppedFileWithPaths:)])
	{
		NSPasteboard *pasteBoard = [sender draggingPasteboard];
		NSArray *filePaths = [pasteBoard propertyListForType:NSFilenamesPboardType];
		[delegate fileDropView:self droppedFileWithPaths:filePaths];
	}
}

@end