//
//	KGCAnswer.m
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Maarten Foukhar. All rights reserved.
//

#import "KGCAnswer.h"

@implementation KGCAnswer

+ (KGCAnswer *)answerWithIdentifier:(NSString *)identifier document:(KGCDocument *)document
{
	NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
	newDictionary[@"AnswerIdentifier"] = identifier;
	newDictionary[@"AnswerPoints"] = @(0);
	newDictionary[@"AutoDropPosition"] = @(NO);
	newDictionary[@"DropPosition"] = @{@"x": @(0.0), @"y": @(0.0)};

	KGCAnswer *answer = [[KGCAnswer alloc] initWithDictionary:newDictionary document:document];
	return answer;
}

#pragma mark - Main Methods

- (void)setAnswerIdentifier:(NSString *)answerIdentifier
{
	[self setObject:[answerIdentifier copy] forKey:@"AnswerIdentifier"];
}

- (NSString *)answerIdentifier
{
	return [self objectForKey:@"AnswerIdentifier"];
}

- (void)setPoints:(NSInteger)points
{
	[self setInteger:points forKey:@"AnswerPoints"];
}

- (NSInteger)points
{
	return [self integerForKey:@"AnswerPoints"];
}

- (void)setAutoDropPositionEnabled:(BOOL)autoDropPositionEnabled
{
	[self setBool:autoDropPositionEnabled forKey:@"AutoDropPosition"];
}

- (BOOL)isAutoDropPositionEnabled
{	
	return [self boolForKey:@"AutoDropPosition"];
}

- (void)setDropPosition:(CGPoint)dropPosition
{
	[self setPoint:dropPosition forKey:@"DropPosition"];
}

- (CGPoint)dropPosition
{
	return [self pointForKey:@"DropPosition"];
}

@end