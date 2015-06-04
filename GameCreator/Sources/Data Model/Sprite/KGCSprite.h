//
//	KGCSprite.h
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSceneObject.h"

@class KGCAnswer;
@class KGCGridAnswer;

/** The sprite type (used by templates) */
//typedef NS_ENUM(NSUInteger, KGCSpriteType)
//{
//		KGCSpriteTypeDefault,
//		KGCSpriteTypeQuestion,
//		KGCSpriteTypeAnswer,
//    KGCSpriteTypeButton,
//};

typedef struct
{
	CGFloat top, left , bottom, right;
} KGCShapeInsets;

/** A sprite data object */
@interface KGCSprite : KGCSceneObject

/** The sprites type */
@property (nonatomic) NSInteger spriteType;

/** The sprites position */
@property (nonatomic) NSPoint position;

/** The sprites z-order (z-index) */
@property (nonatomic) NSUInteger zOrder;

/** The sprites scale */
@property (nonatomic) CGFloat scale;

/** The sprites alpha value */
@property (nonatomic) CGFloat alpha;

/** The sprites initial position */
@property (nonatomic) NSPoint initialPosition;

/** The sprites initial z-order (z-index) */
@property (nonatomic) NSUInteger initialZOrder;

/** The sprites initial scale */
@property (nonatomic) CGFloat initialScale;

/** The sprites initial alpha value */
@property (nonatomic) CGFloat initialAlpha;

/** The sprite image name */
@property (nonatomic, readonly) NSString *imageName;

/** Change the image of the sprite
 *	@param imageURL The image url to set a new image with
 */
- (void)setImageURL:(NSURL *)imageURL;

- (void)clearImage;

/** The sprite background image name */
@property (nonatomic, readonly) NSString *backgroundImageName;

/** Change the image of the sprite
 *	@param imageURL The image url to set a new image with
 */
- (void)setBackgroundImageURL:(NSURL *)imageURL;

- (void)clearBackgroundImage;

/** The draggability of the sprite */
@property (nonatomic, getter = isDraggable) BOOL draggable;

/** If the user interaction of the sprite it disable */
@property (nonatomic, getter = isInteractionDisabled) BOOL interactionDisabled;

/** The maximum number of links to a sprite */ 
@property (nonatomic) NSUInteger maxLinks;

/** The maximum number of group items linked to the sprite */
@property (nonatomic) NSInteger maxGroupItems;

/** The group name where the sprite belongs to */
@property (nonatomic, copy) NSString *groupName;

/** The maximum number of answer sprites that can be connected to a question sprite	(used by templates) */
@property (nonatomic) NSInteger maxAnswerCount;

/** The maximum number of instances of the sprite (used by templates) */
@property (nonatomic) NSInteger maxInstanceCount;



/** If the sprite is a drop grid sprite */
@property (nonatomic, getter = isDropGridSprite) BOOL dropGridSprite;

/** The number of grid rows */
@property (nonatomic) NSUInteger gridRows;

/** The number of grid columns */
@property (nonatomic) NSUInteger gridColumns;

/** The maximum number of shapes allowed in a grid */
@property (nonatomic) NSUInteger maxShapes;

/** The size of the sprite in rows and colums */
@property (nonatomic) NSSize gridSize;

@property (nonatomic, getter = isAnswerSprite) BOOL answerSprite;



/** The sprites answers
 *	@return Returns the sprites answer objects
 */
- (NSArray *)answers;

/** Add an answer to the sprite
 *	@param answer The answer object to add
 */
- (void)addAnswer:(KGCAnswer *)answer;

/** Remove an answer object 
 *	@param answer The answer object to remove
 */
- (void)removeAnswer:(KGCAnswer *)answer;



/** The sprites grid answers
 *	@return Returns the sprites answer objects
 */
- (NSArray *)gridAnswers;

/** Add a grid answer to the sprite
 *	@param gridAnswer The grid answer object to add
 */
- (void)addGridAnswer:(KGCGridAnswer *)gridAnswer;

/** Remove a grid answer object 
 *	@param grid The grid answer object to remove
 */
- (void)removeGridAnswer:(KGCGridAnswer *)gridAnswer;

// Physics
@property (nonatomic, getter = isPhysicsEnabled) BOOL physicsEnabled;
@property (nonatomic, getter = isGravityEnabled) BOOL gravityEnabled;
@property (nonatomic) CGPoint velocity;
@property (nonatomic) NSInteger bodyType;
@property (nonatomic) NSInteger density;
@property (nonatomic) NSInteger shape;
@property (nonatomic) KGCShapeInsets shapeInsets;

@property (nonatomic) CGFloat rotationDegrees;
@property (nonatomic) CGFloat initialRotationDegrees;

@end

KGCShapeInsets KGCShapeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);