//
//	KGCPropertiesAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** An action that changes the sprite properties */
@interface KGCPropertiesAction : KGCAction

/** The properties the action will change */
- (NSMutableDictionary *)properties;

@end