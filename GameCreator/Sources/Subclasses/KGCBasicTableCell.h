//
//	KGCBasicTableCell.h
//	GameCreator
//
//	Created by Maarten Foukhar on 23-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class	KGCBasicTableCell;

@protocol KGCBasicTableCellDelegate <NSObject>

- (void)basicTableCell:(KGCBasicTableCell *)basicTableCell didChangeText:(NSString *)newText;

@end

@interface KGCBasicTableCell : NSTableCellView

@property (nonatomic, weak) id <KGCBasicTableCellDelegate> delegate;

@property (nonatomic, weak) NSTableView *tableView;

@property (nonatomic) NSInteger row;

@end