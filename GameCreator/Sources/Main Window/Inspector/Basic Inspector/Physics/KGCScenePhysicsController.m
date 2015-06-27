//
//  KGCScenePhysicsController.m
//  GameCreator
//
//  Created by Maarten Foukhar on 29-05-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCScenePhysicsController.h"
#import "KGCScene.h"

@interface KGCScenePhysicsController ()

@property (nonatomic, weak) IBOutlet NSButton *enablePhysicsButton;
@property (nonatomic, weak) IBOutlet NSTextField *gravityXField;
@property (nonatomic, weak) IBOutlet NSTextField *gravityYField;

@end

@implementation KGCScenePhysicsController

#pragma mark - Main Method

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSArray *sceneObjects = [self sceneObjects];
	NSNumber *physicsEnabled = [self objectForPropertyNamed:@"physicsEnabled" inArray:sceneObjects];
	[[self enablePhysicsButton] setState:[physicsEnabled integerValue]];
	
	[self changeEnablePhysics:[self enablePhysicsButton]];
	[self updatePosition:nil];
}

#pragma mark - Interaction Actions

- (IBAction)changeEnablePhysics:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"physicsEnabled" inArray:[self sceneObjects]];
	NSArray *textFields = @[[self gravityXField], [self gravityYField]];
	for (NSTextField *textField in textFields)
	{
		[textField setEnabled:[sender state]];
	}	
}

- (IBAction)changeGravityX:(id)sender
{
	[self setGravityX:[sender doubleValue]];
}

- (IBAction)changeGravityY:(id)sender
{
	[self setGravityY:[sender doubleValue]];
}

#pragma mark - Property Methods

- (NSPoint)gravityGlobalXPosition:(BOOL *)globalXPosition globalYPosition:(BOOL *)globalYPosition
{
	*globalXPosition = YES;
	*globalYPosition = YES;

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCScene *)sceneObjects[0] gravity];
	}
	
	BOOL firstCheck = YES;
	BOOL wrongX = NO;
	BOOL wrongY = NO;
	NSPoint point = NSZeroPoint;
	for (KGCScene *scene in sceneObjects)
	{
		if (firstCheck)
		{
			firstCheck = NO;
			point = [scene gravity];
		}
		else
		{
			NSPoint position = [scene gravity];
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

- (void)setGravityX:(CGFloat)x
{
	for (KGCScene *scene in [self sceneObjects])
	{
		NSPoint position = [scene gravity];
		position.x = x;
		[scene setGravity:position];
	}
}

- (void)setGravityY:(CGFloat)y
{
	for (KGCScene *scene in [self sceneObjects])
	{
		NSPoint position = [scene gravity];
		position.y = y;
		[scene setGravity:position];
	}
}

- (void)updatePosition:(NSNotification *)notification
{
	BOOL globalXPosition, globalYPosition;
	NSPoint position = [self gravityGlobalXPosition:&globalXPosition globalYPosition:&globalYPosition];
	
	NSTextField *gravityXField = [self gravityXField];
	if (globalXPosition)
	{
		[gravityXField setDoubleValue:position.x];
	}
	else
	{
		[gravityXField setStringValue:@"--"];
	}
	
	NSTextField *gravityYField = [self gravityYField];
	if (globalYPosition)
	{
		[gravityYField setDoubleValue:position.y];
	}
	else
	{
		[gravityYField setStringValue:@"--"];
	}
}


@end