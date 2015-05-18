//
//	KGCBasicTableCell.m
//	GameCreator
//
//	Created by Maarten Foukhar on 23-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCBasicTableCell.h"

@implementation KGCBasicTableCell

- (void)dealloc
{
	[self setDelegate:nil];
}

- (IBAction)textChanged:(id)sender
{
	id <KGCBasicTableCellDelegate> delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(basicTableCell:didChangeText:)])
	{
		[delegate basicTableCell:self didChangeText:[sender stringValue]];
	}
}

@end