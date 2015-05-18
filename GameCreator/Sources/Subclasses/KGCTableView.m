//
//	KGCTableView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 20-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCTableView.h"

@implementation KGCTableView

- (void)copy:(id)sender
{
	id <KGCTableViewMenuDelegate> menuDelegate = [self menuDelegate];
	if ([menuDelegate respondsToSelector:@selector(tableView:copy:)])
	{
		[menuDelegate tableView:self copy:sender];
	}
}

- (void)paste:(id)sender
{
	id <KGCTableViewMenuDelegate> menuDelegate = [self menuDelegate];
	if ([menuDelegate respondsToSelector:@selector(tableView:paste:)])
	{
		[menuDelegate tableView:self paste:sender];
	}
}

@end