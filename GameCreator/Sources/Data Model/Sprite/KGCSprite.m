//
//	KGCSprite.m
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSprite.h"
#import "KGCResourceController.h"
#import "KGCAnswer.h"
#import "KGCScene.h"
#import "KGCGridAnswer.h"

@interface KGCSprite ()

@end

@implementation KGCSprite
{
	NSMutableArray *_answers;
	NSMutableArray *_answerDictionaries;
	
	NSMutableArray *_gridAnswers;
	NSMutableArray *_gridAnswerDictionaries;
}

#pragma mark - Initial Method

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document
{
	self = [super initWithDictionary:dictionary document:document];
	
	if (self)
	{
		// Setup the answers
		_answers = [[NSMutableArray alloc] init];
		_answerDictionaries = dictionary[@"Answers"];
		
		if (!_answerDictionaries)
		{
			_answerDictionaries = [[NSMutableArray alloc] init];
			 dictionary[@"Answers"] = _answerDictionaries;
		}
		
		for (NSMutableDictionary *answerDictionary in _answerDictionaries)
		{
			KGCAnswer *answer = [[KGCAnswer alloc] initWithDictionary:answerDictionary document:document];
			[answer setParentObject:self];
			[_answers addObject:answer];
		}
		
		// Setup the grid answers
		_gridAnswers = [[NSMutableArray alloc] init];
		_gridAnswerDictionaries = dictionary[@"GridAnswers"];
		
		if (!_gridAnswerDictionaries)
		{
			_gridAnswerDictionaries = [[NSMutableArray alloc] init];
			dictionary[@"GridAnswers"] = _gridAnswerDictionaries;
		}
		
		for (NSMutableDictionary *gridAnswerDictionary in _gridAnswerDictionaries)
		{
			KGCGridAnswer *gridAnswer = [[KGCGridAnswer alloc] initWithDictionary:gridAnswerDictionary document:document];
			[gridAnswer setParentObject:self];
			[_gridAnswers addObject:gridAnswer];
		}
		
//		NSMutableArray *sounds = [[NSMutableArray alloc] init];
//		
//		if ([[dictionary allKeys] containsObject:@"MouseEnterSounds"])
//		{
//			NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
//			newDictionary[@"Name"] = @"MouseEnterSounds";
//			newDictionary[@"Sounds"] = dictionary[@"MouseEnterSounds"];
//			[sounds addObject:newDictionary];
//			[dictionary removeObjectForKey:@"MouseEnterSounds"];
//			NSLog(@"Moving enter sounds...");
//		}
//		
//		if ([[dictionary allKeys] containsObject:@"MouseClickSounds"])
//		{
//			NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
//			newDictionary[@"Name"] = @"MouseClickSounds";
//			newDictionary[@"Sounds"] = dictionary[@"MouseClickSounds"];
//			[sounds addObject:newDictionary];
//			[dictionary removeObjectForKey:@"MouseClickSounds"];
//			NSLog(@"Moving click sounds...");
//		}
//		
//		if ([sounds count] > 0)
//		{
//			dictionary[@"SoundSets"] = sounds;
//			NSLog(@"Setting the new sounds");
//		}
		
//		[self updateDictionary];
	}
	
	return self;
}

- (void)setParentObject:(KGCDataObject *)parentObject
{
	[super setParentObject:parentObject];
	[self updateDictionary];
}

#pragma mark - Main Methods

- (void)setSpriteType:(NSInteger)spriteType
{
	[self setInteger:spriteType forKey:@"SpriteType"];
}

- (NSInteger)spriteType
{
	return [self integerForKey:@"SpriteType"];
}

- (void)setPosition:(NSPoint)position
{
	[self setPoint:position forKey:@"Position"];
}

- (NSPoint)position
{	
	return [self pointForKey:@"Position"];
}

- (void)setZOrder:(NSUInteger)zOrder
{
	[self setUnsignedInteger:zOrder forKey:@"zOrder"];
}

- (NSUInteger)zOrder
{
	return [self unsignedIntegerForKey:@"zOrder"];
}

- (void)setScale:(CGFloat)scale
{
	[self setDouble:scale forKey:@"Scale"];
}

- (CGFloat)scale
{
	if (![self hasObjectForKey:@"Scale"])
	{
		return 1.0;
	}
	
	return [self doubleForKey:@"Scale"];
}

- (void)setAlpha:(CGFloat)alpha
{
	[self setDouble:alpha forKey:@"Alpha"];
}

- (CGFloat)alpha
{
	if (![self hasObjectForKey:@"Alpha"])
	{
		return 1.0;
	}

	return [self doubleForKey:@"Alpha"];
}

- (void)setInitialPosition:(NSPoint)initialPosition
{
	NSPoint position = [self position];
	if (initialPosition.x == position.x && initialPosition.y == position.y)
	{
		[self setObject:nil forKey:@"InitialPosition"];
	}
	else
	{
		[self setPoint:initialPosition forKey:@"InitialPosition"];
	}
}

- (NSPoint)initialPosition
{
	if (![self hasObjectForKey:@"InitialPosition"])
	{
		return [self position];
	}
	
	return [self pointForKey:@"InitialPosition"];
}

- (void)setInitialZOrder:(NSUInteger)initialZOrder
{
	[self setUnsignedInteger:initialZOrder forKey:@"InitialZOrder"];
}

- (NSUInteger)initialZOrder
{
	if (![self hasObjectForKey:@"InitialZOrder"])
	{
		return [self zOrder];
	}
	
	return [self unsignedIntegerForKey:@"InitialZOrder"];
}

- (void)setInitialScale:(CGFloat)initialScale
{
	[self setDouble:initialScale forKey:@"InitialScale"];
}

- (CGFloat)initialScale
{
	if (![self hasObjectForKey:@"InitialScale"])
	{
		return [self scale];
	}
	
	return [self doubleForKey:@"InitialScale"];
}

- (void)setInitialAlpha:(CGFloat)initialAlpha
{
	[self setDouble:initialAlpha forKey:@"InitialAlpha"];
}

- (CGFloat)initialAlpha
{
	if (![self hasObjectForKey:@"InitialAlpha"])
	{
		return [self alpha];
	}

	return [self doubleForKey:@"InitialAlpha"];
}

- (NSString *)imageName
{
	return [self objectForKey:@"ImageName"];
}

- (void)setImageURL:(NSURL *)imageURL
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:imageURL type:KGCResourceInfoTypeImage];
	[self setObject:resourceName forKey:@"ImageName"];
}

- (NSString *)backgroundImageName
{
	NSDictionary *backgroundImageInfo = [self objectForKey:@"BackgroundImage"];

	if (backgroundImageInfo && [[backgroundImageInfo allKeys] containsObject:@"ImageName"])
	{
		return backgroundImageInfo[@"ImageName"];
	}
	
	return nil;
}

- (void)setBackgroundImageURL:(NSURL *)imageURL
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:imageURL type:KGCResourceInfoTypeImage];
	[self setObject:@{@"ImageName": resourceName} forKey:@"BackgroundImage"];
}

- (void)setDraggable:(BOOL)draggable
{
	[self setBool:draggable forKey:@"Draggable"];
}

- (BOOL)isDraggable
{	
	KGCTemplateType templateType = [(KGCScene *)[self parentObject] templateType];
	NSInteger spriteType = [self spriteType];
	if ((templateType == KGCTemplateTypeDragAndDrop || templateType == KGCTemplateTypeDragAndDropShape) && spriteType == 2)
	{
		return YES;
	}
	
	return [self doubleForKey:@"Draggable"];
}

- (void)setInteractionDisabled:(BOOL)interactionDisabled
{
	[self setBool:interactionDisabled forKey:@"InteractionDisabled"];
}

- (BOOL)isInteractionDisabled
{
	return [self boolForKey:@"InteractionDisabled"];
}

- (void)setMaxLinks:(NSUInteger)maxLinks
{
	[self setUnsignedInteger:maxLinks forKey:@"MaxLinks"];
}

- (NSUInteger)maxLinks
{
	return [self unsignedIntegerForKey:@"MaxLinks"];
}

- (void)setMaxGroupItems:(NSInteger)maxGroupItems
{	
	[self setInteger:maxGroupItems forKey:@"MaxGroupItems"];
}

- (NSInteger)maxGroupItems
{
	return [self integerForKey:@"MaxGroupItems"];
}

- (void)setGroupName:(NSString *)groupName
{
	[self setObject:groupName forKey:@"GroupName"];
}

- (NSString *)groupName
{
	return [self objectForKey:@"GroupName"];
}

- (void)setMaxAnswerCount:(NSInteger)maxAnswerCount
{
	[self setInteger:maxAnswerCount forKey:@"MaxAnswerCount"];
}

- (NSInteger)maxAnswerCount
{
	return [self integerForKey:@"MaxAnswerCount"];
}

- (void)setMaxInstanceCount:(NSInteger)maxInstanceCount
{
	[self setInteger:maxInstanceCount forKey:@"MaxInstanceCount"];
}

- (NSInteger)maxInstanceCount
{
	if ([self hasObjectForKey:@"MaxInstanceCount"])
	{
		return [self integerForKey:@"MaxInstanceCount"];
	}
	
	return 1;
}

- (void)setDropGridSprite:(BOOL)dropGridSprite
{
	[self setBool:dropGridSprite forKey:@"DropGridSprite"];
}

- (BOOL)isDropGridSprite
{
	KGCTemplateType templateType = [(KGCScene *)[self parentObject] templateType];
	NSInteger spriteType = [self spriteType];
	if ((templateType == KGCTemplateTypeDragAndDropShape) && spriteType == 1)
	{
		return YES;
	}
	
	if ([self hasObjectForKey:@"DropGridSprite"])
	{
		return [self boolForKey:@"DropGridSprite"];
	}
	
	return NO;
}

- (void)setGridRows:(NSUInteger)gridRows
{
	[self setUnsignedInteger:gridRows forKey:@"GridRows"];
}

- (NSUInteger)gridRows
{
	return [self unsignedIntegerForKey:@"GridRows"];
}

- (void)setGridColumns:(NSUInteger)gridColumns
{
	[self setUnsignedInteger:gridColumns forKey:@"GridColumns"];
}

- (NSUInteger)gridColumns
{
	return [self unsignedIntegerForKey:@"GridColumns"];
}

- (void)setMaxShapes:(NSUInteger)maxShapes
{
	[self setUnsignedInteger:maxShapes forKey:@"MaxShapes"];
}

- (NSUInteger)maxShapes
{
	return [self unsignedIntegerForKey:@"MaxShapes"];
}

- (void)setGridSize:(NSSize)gridSize
{
	[self setSize:gridSize forKey:@"GridSize"];
}

- (NSSize)gridSize
{
	if ([self hasObjectForKey:@"GridSize"])
	{
		return [self sizeForKey:@"GridSize"];
	}
	
	return NSZeroSize;
}

- (void)setAnswerSprite:(BOOL)answerSprite
{
	[self setBool:answerSprite forKey:@"isAnswerSprite"];
}

- (BOOL)isAnswerSprite
{
	return [self spriteType] == 2 || [self boolForKey:@"isAnswerSprite"];
}

- (NSArray *)answers
{
	return [NSArray arrayWithArray:_answers];
}

- (void)addAnswer:(KGCAnswer *)answer
{
	[answer setParentObject:self];
	[_answers addObject:answer];
	[_answerDictionaries addObject:[answer dictionary]];
	[self notifyDelegateAboutKeyChange:@"Answers"];
	[self updateDictionary];
}

- (void)removeAnswer:(KGCAnswer *)answer
{
	if ([_answers containsObject:answer])
	{
		[_answers removeObject:answer];
		[_answerDictionaries removeObject:[answer dictionary]];
		[self notifyDelegateAboutKeyChange:@"Answers"];
		[self updateDictionary];
	}
}

- (NSArray *)gridAnswers
{
	return [NSArray arrayWithArray:_gridAnswers];
}

- (void)addGridAnswer:(KGCGridAnswer *)gridAnswer
{
	[gridAnswer setParentObject:self];
	[_gridAnswers addObject:gridAnswer];
	[_gridAnswerDictionaries addObject:[gridAnswer dictionary]];
	[self notifyDelegateAboutKeyChange:@"GridAnswers"];
	[self updateDictionary];
}

- (void)removeGridAnswer:(KGCGridAnswer *)gridAnswer
{
	if ([_gridAnswers containsObject:gridAnswer])
	{
		[_gridAnswers removeObject:gridAnswer];
		[_gridAnswerDictionaries removeObject:[gridAnswer dictionary]];
		[self notifyDelegateAboutKeyChange:@"GridAnswers"];
		[self updateDictionary];
	}
}

- (NSArray *)visualKeys
{
	return @[	@"zOrder", @"InitialZOrder", 
				@"Scale", @"InitialScale", 
				@"Alpha", @"InitialAlpha",
				@"Position", @"InitialPosition",
				@"BackgroundImage"];
}

@end