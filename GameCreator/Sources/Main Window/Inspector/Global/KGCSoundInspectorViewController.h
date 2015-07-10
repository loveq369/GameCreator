//
//  KGCSoundInspectorViewController.h
//  GameCreator
//
//  Created by Maarten Foukhar on 07-07-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCInspectorViewController.h"

@interface KGCSoundInspectorViewController : KGCInspectorViewController

@property (nonatomic, weak, readonly) NSPopUpButton *soundTypePopUp;
@property (nonatomic, weak, readonly) NSTableView *soundTableView;

- (void)tableViewSelectionDidChange:(NSNotification *)notification;

- (NSArray *)sounds;

// Implement in subclasses
- (NSArray *)soundSets;
- (NSString *)soundPopupSaveKey;
- (NSView *)viewForSoundSet:(NSDictionary *)soundSet;
- (NSString *)currentSoundKey;

@end