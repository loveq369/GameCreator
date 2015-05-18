//
//  KGCGridAnswer.m
//  GameCreator
//
//  Created by Maarten Foukhar on 31-03-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCGridAnswer.h"

@implementation KGCGridAnswer

+ (KGCGridAnswer *)gridAnswerWitDocument:(KGCDocument *)document
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	dictionary[@"_id"] = [[NSUUID UUID] UUIDString];
	
	KGCGridAnswer *gridAnswer = [[KGCGridAnswer alloc] initWithDictionary:dictionary document:document];

	return gridAnswer;
}

- (void)setRow:(NSUInteger)row
{
	[self setUnsignedInteger:row forKey:@"Row"];
}

- (NSUInteger)row
{
	return [self unsignedIntegerForKey:@"Row"];
}

- (void)setColumn:(NSUInteger)column
{
	[self setUnsignedInteger:column forKey:@"Column"];
}

- (NSUInteger)column
{
	return [self unsignedIntegerForKey:@"Column"];
}

- (void)setAllOtherRowsAndColumns:(BOOL)allOtherRowsAndColumns
{
	[self setBool:allOtherRowsAndColumns forKey:@"AllOtherRowsAndColumns"];
}

- (BOOL)allOtherRowsAndColumns
{
	return [self boolForKey:@"AllOtherRowsAndColumns"];
}

- (void)setPoints:(NSInteger)points
{
	[self setInteger:points forKey:@"Points"];
}

- (NSInteger)points
{
	return [self integerForKey:@"Points"];
}

- (NSString *)name
{
	if ([self allOtherRowsAndColumns])
	{
		NSString *pointsName = NSLocalizedString(@"Points", nil);
		return [NSString stringWithFormat:@"%@: %@: %i", [NSLocalizedString(@"all rows and columns", nil) capitalizedString], pointsName, (int)[self points]];
	}
	else
	{
		NSString *rowName = NSLocalizedString(@"Row", nil);
		NSString *columnName = NSLocalizedString(@"Column", nil);
		NSString *pointsName = NSLocalizedString(@"Points", nil);
		return [NSString stringWithFormat:@"%@: %i %@: %i %@: %i", rowName, (int)[self row], columnName, (int)[self column], pointsName, (int)[self points]];
	}
}

- (void)setName:(NSString *)name {}

- (void)setTargetSpriteDictionary:(NSDictionary *)targetSpriteDictionary
{
	[self setObject:targetSpriteDictionary forKey:@"TargetSpriteDictionary"];
}

- (NSDictionary *)targetSpriteDictionary
{
	return [self objectForKey:@"TargetSpriteDictionary"];
}

@end