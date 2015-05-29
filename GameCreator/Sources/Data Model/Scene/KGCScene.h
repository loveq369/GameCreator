//
//	KGCScene.h
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneObject.h"

@class KGCSprite;

typedef NS_ENUM(NSUInteger, KGCTemplateType) {
	KGCTemplateTypeBasic,
	KGCTemplateTypeDragAndDrop,
	KGCTemplateTypeDragAndDropShape,
	KGCTemplateTypeMenu
};

/** A scene data object */
@interface KGCScene : KGCSceneObject

+ (KGCScene *)sceneWithName:(NSString *)name templateType:(KGCTemplateType)templateType document:(KGCDocument *)document;

@property (nonatomic) KGCTemplateType templateType;

/** The scene sprites 
 *	@return Returns the scenes sprites
 */
- (NSArray *)sprites;

/** Add a new sprite
 *	@param sprite The sprite to add
 */
- (void)addSprite:(KGCSprite *)sprite;

/** Remove a sprite 
 *	@param sprite The sprite to Remove
 */
- (void)removeSprite:(KGCSprite *)sprite;

/** The image name of the current scene image */
@property (nonatomic, copy, readonly) NSString *imageName;

/** Change the scene image
 *	@param imageURL the url to set the new image
 */
- (void)setImageURL:(NSURL *)imageURL;

- (void)clearImage;

/** The required points (used by templates) */
@property (nonatomic) NSInteger requiredPoints;

/** The require confirmation state (used by templates) */
@property (nonatomic) BOOL requireConfirmation;

@property (nonatomic) BOOL autoFadeIn;
@property (nonatomic) BOOL autoFadeOut;
@property (nonatomic, getter = isDisableConfirmInteraction) BOOL disableConfirmInteraction;
@property (nonatomic) BOOL autoMoveBackWrongAnswers;
@property (nonatomic, copy) NSImage *thumbnailImage;

// Physics
@property (nonatomic, getter = isPhysicsEnabled) BOOL physicsEnabled;
@property (nonatomic) CGPoint gravity;
@property (nonatomic) CGFloat speed;
@property (nonatomic) CGFloat updateRate;
@property (nonatomic) NSInteger subSteps;

@end