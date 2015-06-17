//
//	KGCActionTableCell.h
//	GameCreator
//
//	Created by Maarten Foukhar on 21-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KGCAction;

@interface KGCActionTableCell : NSTableCellView

- (void)setupWithAction:(KGCAction *)action;

@property (nonatomic, weak, readonly) NSPopUpButton *actionTriggerPopUpButton;

@end