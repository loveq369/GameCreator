//
//  KGCSoundEffectTableCellView.h
//  GameCreator
//
//  Created by Maarten Foukhar on 01-05-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGCGameSet.h"

@interface KGCSoundEffectTableCellView : NSTableCellView

- (void)setupWithGameSet:(KGCGameSet *)gameSet soundEffectKey:(NSString *)soundEffectKey;

@end