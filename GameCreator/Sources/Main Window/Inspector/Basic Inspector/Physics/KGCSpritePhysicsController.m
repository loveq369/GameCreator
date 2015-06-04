//
//  KGCSpritePhysicsController.m
//  GameCreator
//
//  Created by Maarten Foukhar on 29-05-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSpritePhysicsController.h"
#import "KGCSprite.h"

@interface KGCSpritePhysicsController ()

@property (nonatomic, weak) IBOutlet NSButton *enablePhysicsButton;
@property (nonatomic, weak) IBOutlet NSButton *useGravityButton;
@property (nonatomic, weak) IBOutlet NSTextField *velocityXField;
@property (nonatomic, weak) IBOutlet NSTextField *velocityYField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *bodyTypePopUp;
@property (nonatomic, weak) IBOutlet NSTextField *densityField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *shapePopUp;
@property (nonatomic, weak) IBOutlet NSTextField *shapeTopInsetField;
@property (nonatomic, weak) IBOutlet NSTextField *shapeLeftInsetField;
@property (nonatomic, weak) IBOutlet NSTextField *shapeBottomInsetField;
@property (nonatomic, weak) IBOutlet NSTextField *shapeRightInsetField;

@end

@implementation KGCSpritePhysicsController

#pragma mark - Main Method

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSArray *sceneObjects = [self sceneObjects];
	
	NSNumber *physicsEnabled = [self objectForPropertyNamed:@"physicsEnabled" inArray:sceneObjects];
	[[self enablePhysicsButton] setState:[physicsEnabled integerValue]];
	
	NSNumber *gravityEnabled = [self objectForPropertyNamed:@"gravityEnabled" inArray:sceneObjects];
	[[self useGravityButton] setState:[gravityEnabled integerValue]];
	
	NSNumber *bodyType = [self objectForPropertyNamed:@"bodyType" inArray:sceneObjects];
	[[self bodyTypePopUp] selectItemAtIndex:[bodyType integerValue]];
	
	NSNumber *density = [self objectForPropertyNamed:@"density" inArray:sceneObjects];
	[[self densityField] setDoubleValue:[density doubleValue]];
	
	NSNumber *shape = [self objectForPropertyNamed:@"shape" inArray:sceneObjects];
	[[self shapePopUp] selectItemAtIndex:[shape integerValue]];
	
	[self updatePosition:nil];
	[self updateShapeInsets];
	[self changeEnablePhysics:[self enablePhysicsButton]];
}

#pragma mark - Interaction Actions

- (IBAction)changeEnablePhysics:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"physicsEnabled" inArray:[self sceneObjects]];
	[[self useGravityButton] setEnabled:[sender state]];
	[[self velocityXField] setEnabled:[sender state]];
	[[self velocityYField] setEnabled:[sender state]];
	[[self bodyTypePopUp] setEnabled:[sender state]];
}

- (IBAction)changeUseGravity:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"gravityEnabled" inArray:[self sceneObjects]];
}

- (IBAction)changeVelocityX:(id)sender
{
	[self setVelocityX:[sender doubleValue]];
}

- (IBAction)changeVelocityY:(id)sender
{
	[self setVelocityY:[sender doubleValue]];
}

- (IBAction)changeBodyType:(id)sender
{
	NSInteger bodyType = [sender indexOfSelectedItem];
	[self setObject:@(bodyType) forPropertyNamed:@"bodyType" inArray:[self sceneObjects]];
}

- (IBAction)changeDensity:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"density" inArray:[self sceneObjects]];
}

- (IBAction)changeShape:(id)sender
{
	NSInteger shape = [sender indexOfSelectedItem];
	[self setObject:@(shape) forPropertyNamed:@"shape" inArray:[self sceneObjects]];
}

- (IBAction)changeShapeTopInset:(id)sender
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		KGCShapeInsets insets = [sprite shapeInsets];
		insets.top = [sender doubleValue];
		[sprite setShapeInsets:insets];
	}
}

- (IBAction)changeShapeLeftInset:(id)sender
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		KGCShapeInsets insets = [sprite shapeInsets];
		insets.left = [sender doubleValue];
		[sprite setShapeInsets:insets];
	}
}

- (IBAction)changeShapeBottomInset:(id)sender
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		KGCShapeInsets insets = [sprite shapeInsets];
		insets.bottom = [sender doubleValue];
		[sprite setShapeInsets:insets];
	}
}

- (IBAction)changeShapeRightInset:(id)sender
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		KGCShapeInsets insets = [sprite shapeInsets];
		insets.right = [sender doubleValue];
		[sprite setShapeInsets:insets];
	}
}

#pragma mark - Property Methods

- (NSPoint)velocityGlobalXPosition:(BOOL *)globalXPosition globalYPosition:(BOOL *)globalYPosition
{
	*globalXPosition = YES;
	*globalYPosition = YES;

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCSprite *)sceneObjects[0] velocity];
	}
	
	BOOL firstCheck = YES;
	BOOL wrongX = NO;
	BOOL wrongY = NO;
	NSPoint point = NSZeroPoint;
	for (KGCSprite *sprite in sceneObjects)
	{
		if (firstCheck)
		{
			firstCheck = NO;
			point = [sprite velocity];
		}
		else
		{
			NSPoint position = [sprite velocity];
			if (!wrongX && (position.x != point.x))
			{
				wrongX = YES;
				*globalXPosition = NO;
			}
			if (!wrongY && (position.y != point.y))
			{
				wrongY = YES;
				*globalYPosition = NO;
			}
			
			if (wrongX && wrongY)
			{
				return NSZeroPoint;
			}
		}
	}
	
	return point;
}

- (void)setVelocityX:(CGFloat)x
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		NSPoint position = [sprite velocity];
		position.x = x;
		[sprite setVelocity:position];
	}
}

- (void)setVelocityY:(CGFloat)y
{
	for (KGCSprite *sprite in [self sceneObjects])
	{
		NSPoint position = [sprite velocity];
		position.y = y;
		[sprite setVelocity:position];
	}
}

- (void)updatePosition:(NSNotification *)notification
{
	BOOL globalXPosition, globalYPosition;
	NSPoint position = [self velocityGlobalXPosition:&globalXPosition globalYPosition:&globalYPosition];
	
	NSTextField *velocityXField = [self velocityXField];
	if (globalXPosition)
	{
		[velocityXField setDoubleValue:position.x];
	}
	else
	{
		[velocityXField setStringValue:@"--"];
	}
	
	NSTextField *velocityYField = [self velocityYField];
	if (globalYPosition)
	{
		[velocityYField setDoubleValue:position.y];
	}
	else
	{
		[velocityYField setStringValue:@"--"];
	}
}

- (void)updateShapeInsets
{
	BOOL globalTopInset, globalLeftInset, globalBottomInset, globalRightInset;
	KGCShapeInsets shapeInset = [self shapeInsetsGlobalTopInset:&globalTopInset globalLeftInset:&globalLeftInset globalBottomInset:&globalBottomInset globalRightInset:&globalRightInset];
	
	NSTextField *shapeTopInsetField = [self shapeTopInsetField];
	if (globalTopInset)
	{
		[shapeTopInsetField setDoubleValue:shapeInset.top];
	}
	else
	{
		[shapeTopInsetField setStringValue:@"--"];
	}
	
	NSTextField *shapeLeftInsetField = [self shapeLeftInsetField];
	if (globalLeftInset)
	{
		[shapeLeftInsetField setDoubleValue:shapeInset.left];
	}
	else
	{
		[shapeLeftInsetField setStringValue:@"--"];
	}
	
	NSTextField *shapeBottomInsetField = [self shapeBottomInsetField];
	if (globalBottomInset)
	{
		[shapeBottomInsetField setDoubleValue:shapeInset.bottom];
	}
	else
	{
		[shapeBottomInsetField setStringValue:@"--"];
	}
	
	NSTextField *shapeRightInsetField = [self shapeRightInsetField];
	if (globalRightInset)
	{
		[shapeRightInsetField setDoubleValue:shapeInset.right];
	}
	else
	{
		[shapeRightInsetField setStringValue:@"--"];
	}
}

- (KGCShapeInsets)shapeInsetsGlobalTopInset:(BOOL *)globalTopInset globalLeftInset:(BOOL *)globalLeftInset globalBottomInset:(BOOL *)globalBottomInset globalRightInset:(BOOL *)globalRightInset
{
	*globalTopInset = YES;
	*globalLeftInset = YES;
	*globalBottomInset = YES;
	*globalRightInset = YES;

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCSprite *)sceneObjects[0] shapeInsets];
	}
	
	BOOL firstCheck = YES;
	BOOL wrongTop = NO;
	BOOL wrongLeft = NO;
	BOOL wrongBottom = NO;
	BOOL wrongRight = NO;
	KGCShapeInsets shapeInset = KGCShapeInsetsMake(0.0, 0.0, 0.0, 0.0);
	for (KGCSprite *sprite in sceneObjects)
	{
		if (firstCheck)
		{
			firstCheck = NO;
			shapeInset = [sprite shapeInsets];
		}
		else
		{
			KGCShapeInsets otherShapeInset = [sprite shapeInsets];
			if (!wrongTop && (otherShapeInset.top != shapeInset.top))
			{
				wrongTop = YES;
				*globalTopInset = NO;
			}
			if (!wrongLeft && (otherShapeInset.left != shapeInset.left))
			{
				wrongLeft = YES;
				*globalLeftInset = NO;
			}
			if (!wrongBottom && (otherShapeInset.bottom != shapeInset.bottom))
			{
				wrongBottom = YES;
				*globalBottomInset = NO;
			}
			if (!wrongRight && (otherShapeInset.right != shapeInset.right))
			{
				wrongRight = YES;
				*globalRightInset = NO;
			}
			
			if (wrongTop && wrongLeft && wrongBottom && wrongRight)
			{
				return KGCShapeInsetsMake(0.0, 0.0, 0.0, 0.0);
			}
		}
	}
	
	return shapeInset;
}

@end