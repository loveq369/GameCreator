//
//	KGCInspectorWindow.h
//	GameCreator
//
//	Created by Maarten Foukhar on 13-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KGCInspectorWindow : NSWindow

- (instancetype)initWithView:(NSView *)view arrowLocation:(CGFloat)arrowLocation;
- (void)showAnimated:(BOOL)animated;

@end