//
//	KGCDADSceneController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDADSceneController.h"
#import "KGCDADInspector.h"
#import "KGCSceneLayer.h"
#import "KGCSceneContentView.h"
#import "KGCScene.h"

@interface KGCDADSceneController ()

@property (nonatomic, weak) IBOutlet NSTextField *sceneRequiredPointsField;
@property (nonatomic, weak) IBOutlet NSButton *sceneRequireConfirmationButton;
@property (nonatomic, weak) IBOutlet NSButton *disableConfirmInteractionButton;
@property (nonatomic, weak) IBOutlet NSButton *autoMoveBackWrongAnswersButton;
@property (nonatomic, weak) IBOutlet NSButton *shouldHighlightSpriteButton;
@property (nonatomic, weak) IBOutlet NSTextField *groupNameField;

@end

@implementation KGCDADSceneController

#pragma mark - Initial Methods

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[[self autoMoveBackWrongAnswersButton] setState:NSOffState];
}

#pragma mark - Main Methods

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSNumber *requiredPoints = [self objectForPropertyNamed:@"requiredPoints" inArray:[self sceneObjects]];
	[self setObjectValue:requiredPoints inTextField:[self sceneRequiredPointsField]];
		
	NSArray *properties = @[@"requireConfirmation", @"disableConfirmInteraction", @"autoMoveBackWrongAnswers", @"shouldHighlightQuestionSprites"];
	NSArray *checkBoxes = @[[self sceneRequireConfirmationButton], [self disableConfirmInteractionButton], [self autoMoveBackWrongAnswersButton], [self shouldHighlightSpriteButton]];
	for (NSInteger i = 0; i < [properties count]; i ++)
	{
		NSString *propertyName = properties[i];
		NSButton *checkBox = checkBoxes[i];
		id object = [self objectForPropertyNamed:propertyName inArray:[self sceneObjects]];
		[self setObjectValue:object inCheckBox:checkBox];
	}
	
	NSString *groupName = [self objectForPropertyNamed:@"groupName" inArray:[self sceneObjects]];
	[self setObjectValue:groupName inTextField:[self groupNameField]];
}

#pragma mark - Interface Methods

- (IBAction)changeSceneRequiredPoints:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"requiredPoints" inArray:[self sceneObjects]];
}

- (IBAction)changeSceneRequireConfirmation:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"requireConfirmation" inArray:[self sceneObjects]];
}

- (IBAction)changeDisableConfirmInteraction:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"disableConfirmInteraction" inArray:[self sceneObjects]];
}

- (IBAction)changeAutoMoveBackAnswers:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"autoMoveBackWrongNaswers" inArray:[self sceneObjects]];
}

- (IBAction)changeShouldHighlightSprites:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"shouldHighlightQuestionSprites" inArray:[self sceneObjects]];
}

- (IBAction)changeGroupName:(id)sender
{
	[self setObject:[sender stringValue] forPropertyNamed:@"groupName" inArray:[self sceneObjects]];
}

@end