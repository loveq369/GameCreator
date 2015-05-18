//
//	KGCTableTextField.m
//	GameCreator
//
//	Created by Maarten Foukhar on 21-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCTableTextField.h"

@implementation KGCTableTextField

- (void)mouseDown:(NSEvent *)theEvent
{
	[super performSelector:@selector(mouseDown:) withObject:theEvent afterDelay:2];
}

- (void)mouseUp:(NSEvent *)theEvent
{
//	[super performSelector:@selector(mouseUp:) withObject:theEvent afterDelay:2];
}

- (BOOL)becomeFirstResponder
{
		BOOL result = [super becomeFirstResponder];
		if (result)
		{
			[self performSelector:@selector(selectText:) withObject:self afterDelay:0.4];
		}
	
		return result;
}

- (void)performClick:(id)sender
{

}

@end