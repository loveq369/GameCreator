//
//	KGCPathAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCPathAnimation.h"

@implementation KGCPathAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Path",
				@"Duration" :		@(0.25),
				@"Shape" :			@(KGCPathAnimatorShapeCircle)
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Shape Animation", nil);
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

- (KGCPathAnimatorShape)shape
{
	return [self integerForKey:@"Shape"];
}

- (void)setShape:(KGCPathAnimatorShape)shape
{
	[self setInteger:shape forKey:@"Shape"];
}

- (CGRect)shapeRect
{
	return [self rectForKey:@"Frame"];
}

- (void)setShapeRect:(NSRect)shapeRect
{
	[self setRect:shapeRect forKey:@"Frame"];
}

- (NSMutableArray *)shapePoints
{
	return [self objectForKey:@"ShapePoints"];
}

- (void)setDegrees:(CGFloat)degrees
{
	[self setDouble:degrees forKey:@"Degrees"];
}

- (CGFloat)degrees
{
	return [self doubleForKey:@"Degrees"];
}

- (void)setClockWise:(BOOL)clockWise
{
	[self setBool:clockWise forKey:@"ClockWise"];
}

- (BOOL)clockWise
{
	return [self boolForKey:@"ClockWise"];
}

@end