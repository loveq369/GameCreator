//
//	KGCAnswerCell.m
//	GameCreator
//
//	Created by Maarten Foukhar on 20-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCAnswerCell.h"

@interface KGCAnswerCell ()

@property (nonatomic, weak) IBOutlet NSButton *autoDropPositionButton;
@property (nonatomic, weak) IBOutlet NSTextField *dropPositionXField;
@property (nonatomic, weak) IBOutlet NSTextField *dropPositionYField;

@end

@implementation KGCAnswerCell

- (void)setAnswerDictionary:(NSMutableDictionary *)answerDictionary
{
	_answerDictionary = answerDictionary;
	
	NSDictionary *positionDictionary = answerDictionary[@"DropPosition"];
	NSTextField *dropPositionXField = [self dropPositionXField];
	[dropPositionXField setDoubleValue:[positionDictionary[@"x"] doubleValue]];
	NSTextField *dropPositionYField = [self dropPositionYField];
	[dropPositionYField setDoubleValue:[positionDictionary[@"y"] doubleValue]];
	
	BOOL autoDropEnabled = [answerDictionary[@"AutoDropPosition"] boolValue];
	[[self autoDropPositionButton] setState:autoDropEnabled];
	[dropPositionXField setEnabled:autoDropEnabled];
	[dropPositionYField setEnabled:autoDropEnabled];
}

- (IBAction)changeAutoDropPosition:(id)sender
{
	BOOL autoDropPosition = [sender state];
	[[self dropPositionXField] setEnabled:autoDropPosition];
	[[self dropPositionYField] setEnabled:autoDropPosition];
	[self answerDictionary][@"AutoDropPosition"] = @(autoDropPosition);
}

- (IBAction)changeDropPosition:(id)sender
{
	CGFloat x = [[self dropPositionXField] doubleValue];
	CGFloat y = [[self dropPositionYField] doubleValue];
	NSDictionary *positionDictionary = @{@"x" : @(x), @"y" : @(y)};
	[self answerDictionary][@"DropPosition"] = positionDictionary;
}

@end