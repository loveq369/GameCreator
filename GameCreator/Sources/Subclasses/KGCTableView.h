//
//	KGCTableView.h
//	GameCreator
//
//	Created by Maarten Foukhar on 20-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KGCTableView;

@protocol KGCTableViewMenuDelegate <NSObject>

- (void)tableView:(KGCTableView *)tableView copy:(id)sender;
- (void)tableView:(KGCTableView *)tableView paste:(id)sender;

@end

@interface KGCTableView : NSTableView

@property (nonatomic, weak) IBOutlet id <KGCTableViewMenuDelegate> menuDelegate;

@end