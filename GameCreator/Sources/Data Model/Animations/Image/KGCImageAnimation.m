//
//	KGCImageAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCImageAnimation.h"

@implementation KGCImageAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"FrameDuration" :		@(0.1),
				@"Images" :				[[NSMutableArray alloc] init]
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Image Animation", nil);
}

#pragma mark - Property Methods

- (NSMutableArray *)spriteImageNames
{
	return [self objectForKey:@"Images"];
}

- (NSTimeInterval)frameDuration
{
	return [self doubleForKey:@"FrameDuration"];
}

- (void)setFrameDuration:(NSTimeInterval)frameDuration
{
	[self setDouble:frameDuration forKey:@"FrameDuration"];
}

@end