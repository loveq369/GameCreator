//
//	KGCAnswer.h
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Maarten Foukhar. All rights reserved.
//

#import "KGCDataObject.h"

@interface KGCAnswer : KGCDataObject

+ (KGCAnswer *)answerWithIdentifier:(NSString *)identifier document:(KGCDocument *)document;

/** Answer identifier */
@property (nonatomic, copy) NSString *answerIdentifier;

/** The points for the given answer */
@property (nonatomic) NSInteger points;

/** If the auto drop position is enabled */
@property (nonatomic, getter = isAutoDropPositionEnabled) BOOL autoDropPositionEnabled;

/** The position to move to when auto drop is enabled */
@property (nonatomic) NSPoint dropPosition;

@end