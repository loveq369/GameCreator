//
//	KGCShadowAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCShadowAnimation.h"

@implementation KGCShadowAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Shadow",
				@"Duration" :		@(0.25),
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Shadow Animation", nil);
}

#pragma mark - Main Methods

- (BOOL)hasPreview
{
	return NO;
}

#pragma mark - Property Methods

- (CGFloat)duration
{
	return [self doubleForKey:@"Duration"];
}

- (void)setDuration:(CGFloat)duration
{
	[self setDouble:duration forKey:@"Duration"];
}

- (BOOL)show
{
	return [self boolForKey:@"Show"];
}

- (void)setShow:(BOOL)show
{
	[self setBool:show forKey:@"Show"];
}

@end