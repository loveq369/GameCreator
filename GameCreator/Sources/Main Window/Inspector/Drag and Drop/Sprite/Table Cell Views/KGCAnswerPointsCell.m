//
//	KGCAnswerPointsCell.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCAnswerPointsCell.h"

@implementation KGCAnswerPointsCell

- (IBAction)changePoints:(id)sender
{
	[self answerDictionary][@"AnswerPoints"] = @([sender doubleValue]);
}

@end