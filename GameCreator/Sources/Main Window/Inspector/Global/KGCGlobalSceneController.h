//
//	KGCGlobalSceneController.h
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneController.h"

@interface KGCGlobalSceneController : KGCSceneController

@property (nonatomic, weak, readonly) NSPopUpButton *soundTypePopUp;
@property (nonatomic, weak, readonly) NSTableView *soundTableView;

- (void)tableViewSelectionDidChange:(NSNotification *)notification;

- (NSArray *)sounds;

// Implement in subclasses
- (NSString *)currentSoundKey;
- (NSString *)soundPopupSaveKey;

@end