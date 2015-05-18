//
//	KGCSequenceAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** Perform multiple actions after eachother */
@interface KGCSequenceAction : KGCAction

/** The associated actions
 *	@return Returns the associated actions
 */
- (NSArray *)actions;

/** The actionKeys */
- (NSMutableArray *)actionKeys;

@end