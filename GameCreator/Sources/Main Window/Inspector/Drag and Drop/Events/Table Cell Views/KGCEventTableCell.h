//
//	KGCEventTableCell.h
//	GameCreator
//
//	Created by Maarten Foukhar on 21-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KGCEvent;

@interface KGCEventTableCell : NSTableCellView

- (void)setupWithEvent:(KGCEvent *)event;

@property (nonatomic, weak, readonly) NSPopUpButton *eventTypePopUp;

@end