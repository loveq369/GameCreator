//
//	KGCEvent.h
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGCDataObject.h"
#import "KGCTemplateAction.h"

@class KGCSceneLayer;

/** An event type */
typedef NS_ENUM(NSUInteger, KGCEventType)
{
	KGCEventTypeNone,
	KGCEventTypeCreation,
	KGCEventTypeClick,
	KGCEventTypeHover,
	KGCEventTypeDrop,
	KGCEventTypeConfirmAnswer,
	KGCEventTypePointsChanged,
	KGCEventTypeNotification,
	KGCEventTypeRightAnswer,
	KGCEventTypeWrongAnswer,
	KGCEventTypeSceneTransition,
  KGCEventTypeDraggableSpriteEnter,
  KGCEventTypeDraggableSpriteExit
};

/** An event object */
@interface KGCEvent : KGCDataObject

/** Create a new event
 *	@param document The document the event belongs to
 *	@return Returns a newly configured event object (designated create method!!!)
 */
+ (id)newEventWithDocument:(KGCDocument *)document;

/** The events event type */
@property (nonatomic) KGCEventType eventType;

/** The event targets */
@property (nonatomic, weak) NSMutableArray *targets;

/** The required points for the event */
@property (nonatomic) NSInteger requiredPoints;

/** The maximum points that allow the ecent actions to be performed */
@property (nonatomic) NSInteger maxPoints;

/** If the action sprite should be linked */
@property (nonatomic, getter = isLinked) BOOL linked;

/** Notification name */
@property (nonatomic, copy) NSString *notificationName;

/** If the actions should be fired in order or all at the same time */
@property (nonatomic, getter = isOrdered) BOOL ordered;

- (NSArray *)templateActions;
- (void)addTemplateAction:(KGCTemplateAction *)templateAction;
- (void)removeTemplateAction:(KGCTemplateAction *)templateAction;

@end