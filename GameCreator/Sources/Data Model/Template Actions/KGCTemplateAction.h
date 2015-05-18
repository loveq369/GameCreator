//
//	KGCTemplateAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGCDataObject.h"
#import "KGCSettingsView.h"

@class KGCSceneLayer;

/** The template action types */
typedef NS_ENUM(NSUInteger, KGCTemplateActionType)
{
	KGCTemplateActionTypeNone,
	KGCTemplateActionTypeAnimation,
	KGCTemplateActionTypeSound,
	KGCTemplateActionTypeConfirmAnswer,
	KGCTemplateActionTypeScene,
	KGCTemplateActionTypePlayHint,
	KGCTemplateActionTypeDelay
};

/** Simple actions used for templates */
@interface KGCTemplateAction : KGCDataObject

/** Get the class for a given template action type
 *	@param type The template action type
 *	@return Returns the template action class
 */
+ (Class)actionClassForType:(KGCTemplateActionType)type;

/** Create a new template action
 *	@param type The template action type
 *	@param document The document the template action belongs to
 *	@return Returns a new template action object
 */
+ (id)newActionWithType:(KGCTemplateActionType)type document:(KGCDocument *)document;

/** The template action type */
@property (nonatomic) KGCTemplateActionType templateActionType;

/** The template actions delay */
@property (nonatomic) CGFloat delay;

/** The info view of the template action
	@param layer The layer to use to get the settings
 *	@return Returns an info view for the inspectors
 */
- (KGCSettingsView *)infoViewForLayer:(KGCSceneLayer *)layer;

@end