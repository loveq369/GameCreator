//
//	KGCAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 16-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "KGCDataObject.h"

@class KGCSceneLayer;
@class KGCSettingsView;

/** An action trigger */
typedef NS_ENUM(NSInteger, KGCActionTrigger)
{
	KGCActionTriggerNone,
	KGCActionTriggerOnCreation,
	KGCActionTriggerClick, // Also touch/tap
	KGCActionTriggerDrop,
	KGCActionTriggerDropped,
	KGCActionTriggerDropOut,
	KGCActionTriggerLink,
	KGCActionTriggerUnlink,
	KGCActionTriggerNotification,
	KGCActionTriggerPointsChanged,
	KGCActionTriggerMouseHover,
	KGCActionTriggerMouseEnter,
	KGCActionTriggerMouseExit,
	KGCActionTriggerSceneTransition
};

/** An action type */
typedef NS_ENUM(NSInteger, KGCActionType)
{
	KGCActionTypeNone,
	KGCActionTypeEmpty,
	KGCActionTypeNotification,
	KGCActionTypeAnimate,
	KGCActionTypeAudio,
	KGCActionTypeScene,
	KGCActionTypeBackgroundMusic,
	KGCActionTypeRemoveSprite,
	KGCActionTypeProperties,
	KGCActionTypeCombine,
	KGCActionTypeSequence,
	KGCActionTypeStopAnimation
};

/** An action link type */
typedef NS_ENUM(NSInteger, KGCActionLinkType)
{
	KGCActionLinkTypeNone,
	KGCActionLinkTypeLink,
	KGCActionLinkTypeUnlink
};

/** A scene/sprite action object, actions are performed based on the trigger that is set */
@interface KGCAction : KGCDataObject

/** Create a new action
 *	@param type The type of the action
 *	@param document The document the action belongs to
 *	@return Returns a newly created action
 */
+ (id)newActionWithType:(KGCActionType)type document:(KGCDocument *)document;

/** Action class for a type string (used in the action dictionaries */
+ (Class)actionClassForType:(KGCActionType)type;

/** The info view of the action
	@param sceneLayers The layers to use to get the settings
 *	@return Returns an info view for the inspectors
 */
- (KGCSettingsView *)infoViewForSceneLayers:(NSArray *)sceneLayers;

/** The action type display name
 *	@return Returns an action type display name base on the action type (integer)
 */
- (NSString *)actionTypeDisplayName;

/** The actions type */
@property (nonatomic) KGCActionType actionType;

/** The actions trigger */
@property (nonatomic) KGCActionTrigger actionTrigger;

/** The action trigger notification name (if applicable) */
@property (nonatomic) NSString *actionTriggerNotificationName;

/** The action link type */
@property (nonatomic) KGCActionLinkType actionLinkType;

/** The delay at which the action is performed */
@property (nonatomic) CGFloat delay;

@property (nonatomic, weak) NSMutableArray *triggerKeys;

/** The action points that can be earned for the action */
@property (nonatomic) NSInteger actionPoints;

/** The required action points to perform the action */
@property (nonatomic) NSUInteger requiredActionPoints;

/** The maximum number of action points */
@property (nonatomic) NSUInteger maximumActionPoints;

@end