//
//	KGCAnimation.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "KGCDataObject.h"

@class KGCSettingsView;
@class KGCSceneLayer;

/** An animation repeat mode */
typedef NS_ENUM(NSInteger, KGCAnimationRepeatMode)
{
	KGCAnimationRepeatModeNone,
	KGCAnimationRepeatModeAll,
	KGCAnimationRepeatModeCustom,
	KGCAnimationForwardAndBack,
	KGCAnimationForwardAndBackCustom
};

typedef NS_ENUM(NSInteger, KGCAnimationType)
{
	KGCAnimationTypeNone,
	KGCAnimationTypeImage,
	KGCAnimationTypePosition,
	KGCAnimationTypeRotate,
	KGCAnimationTypeFade,
	KGCAnimationTypeScale,
	KGCAnimationTypeSequence,
	KGCAnimationTypeCombine,
	KGCAnimationTypePath,
	KGCAnimationTypeMoveBack,
	KGCAnimationTypeShadow,
	KGCAnimationTypeWobble,
	KGCAnimationTypeRandomPosition
};

@interface KGCAnimation : KGCDataObject

/** Animation class for a type string (used in the animation dictionaries */
+ (Class)animationClassForType:(KGCAnimationType)type;

/** Create a new animation object
 *	@param type The type of animation object
 *	@param document The document the animation belongs to
 *	@return Returns a new animation object
 */
+ (id)newAnimationWithType:(KGCAnimationType)type document:(KGCDocument *)document;

/** Start an animation
 *	@param completion Called after the animation has finished
 */
- (void)startAnimationOnLayer:(CALayer *)layer completion:(void (^)(void))completion;

/** Reset an animation
 *	@param completion Called after the animation has finished
 */
- (void)resetAnimationOnLayer:(CALayer *)layer completion:(void (^)(void))completion;

/** Start an animation
 *	@param animated If the animation should be animated
 *	@param completion Called after the animation has finished
 */
- (void)startAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion;

/** Start a back animation
 *	@param animated If the animation should be animated
 *	@param completion Called after the animation has finished
 */
- (void)startBackAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion;

/** Stop all animations
 *	@param completion Called after the animation completes
 */
- (void)abortAnimationOnLayer:(CALayer *)layer completion:(void (^)(void))completion;

/** The info view of the animation
	@param sceneLayers The layers to use to get the settings
 *	@return Returns an info view for the inspectors
 */
- (KGCSettingsView *)infoViewForSceneLayers:(NSArray *)sceneLayers;

/** Can the animation be previewed
 *	@return Returns YES or NO
 */
- (BOOL)hasPreview;

/** The identifier of a current running animation
 * @return Returns an animation identifier
 */
- (NSString *)animationIdentifier;

/** The animation type */
@property (nonatomic, readonly) KGCAnimationType animationType;

/** The animation type display name
 *	@return The animation type display name based on the animation type (integer)
 */
@property (nonatomic, readonly) NSString *animationTypeDisplayName;

/** The animator repeat mode */
@property (nonatomic) KGCAnimationRepeatMode repeatMode;

/** The number of times to repeat animation (if applicable) */
@property (nonatomic) NSUInteger repeatCount;

@end