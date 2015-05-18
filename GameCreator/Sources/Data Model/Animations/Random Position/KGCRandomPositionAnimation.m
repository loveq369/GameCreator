//
//	KGCRandomPositionAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCRandomPositionAnimation.h"

@implementation KGCRandomPositionAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :		@"Random Position",
				@"Duration" :			@(0.25),
				@"MinimumPosition" :	@{@"x": @(0.0), @"y": @(0.0)},
				@"MaximumPosition" :	@{@"x": @(0.0), @"y": @(0.0)}
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Random Position Animation", nil);
}

#pragma mark - Main Methods

- (BOOL)hasPreview
{
	return NO;
}

#pragma mark - Property Methods

- (void)setDuration:(CGFloat)duration
{
	[self setDouble:duration forKey:@"Duration"];
}

- (CGFloat)duration
{
	return [self doubleForKey:@"Duration"];
}

- (void)setMaximumPosition:(NSPoint)maximumPosition
{
	[self setPoint:maximumPosition forKey:@"MaximumPosition"];
}

- (NSPoint)maximumPosition
{
	return [self pointForKey:@"MaximumPosition"];
}

- (void)setMinimumPosition:(NSPoint)minimumPosition
{
	[self setPoint:minimumPosition forKey:@"MinimumPosition"];
}

- (NSPoint)minimumPosition
{
	return [self pointForKey:@"MinimumPosition"];
}

@end