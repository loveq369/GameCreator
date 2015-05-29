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
	
	[self updatePosition:nil];
	[self changeEnablePhysics:[self enablePhysicsButton]];
}

#pragma mark - Interaction Actions

- (IBAction)changeEnablePhysics:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"physicsEnabled" inArray:[self sceneObjects]];
	[[self useGravityButton] setEnabled:[sender state]];
	[[self velocityXField] setEnabled:[sender state]];
	[[self velocityYField] setEnabled:[sender state]];
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

@end