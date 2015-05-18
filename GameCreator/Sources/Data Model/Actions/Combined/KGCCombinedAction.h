//
//	KGCCombinedAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** Combine multiple actions at the same time */
@interface KGCCombinedAction : KGCAction

/** The actions associated */
- (NSArray *)actions;

/** The actionKeys */
- (NSMutableArray *)actionKeys;

@end