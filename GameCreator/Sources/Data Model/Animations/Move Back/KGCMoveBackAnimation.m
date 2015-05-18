//
//	KGCMoveBackAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCMoveBackAnimation.h"

@implementation KGCMoveBackAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"AnimationType" :	@"MoveBack"};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Move Back Animation", nil);
}

@end