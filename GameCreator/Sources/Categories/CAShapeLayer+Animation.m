//
//	CAShapeLayer+Animation.m
//	Animation Categories
//
//	Created by Maarten Foukhar on 17-11-14.
//	Copyright (c) 2014 Kiwi Fruitware. All rights reserved.
//

#import "CAShapeLayer+Animation.h"

@implementation CAShapeLayer (Animation)

- (void)addAnimationForPath:(KWBezierPath *)path withKey:(NSString *)key
{
	CGPathRef pathRef = [self pathRefFromPath:path];
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
	[basicAnimation setFromValue:(__bridge id)[self path]];
	[basicAnimation setToValue:(__bridge id)pathRef];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setPath:pathRef];
}

- (void)addAnimationForLineWidth:(CGFloat)lineWidth withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
	[basicAnimation setFromValue:@([self lineWidth])];
	[basicAnimation setToValue:@(lineWidth)];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setLineWidth:lineWidth];
}

- (void)addAnimationForLineCap:(NSString *)lineCap withKey:(NSString *)key
{
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"lineCap"];
	[basicAnimation setFromValue:[self lineCap]];
	[basicAnimation setToValue:lineCap];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setLineCap:lineCap];
}

- (void)addAnimationForStrokeColor:(KWColor *)strokeColor withKey:(NSString *)key
{
	CGColorRef newColor = strokeColor.CGColor;
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	[basicAnimation setFromValue:(id)[self strokeColor]];
	[basicAnimation setToValue:(__bridge id)newColor];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setStrokeColor:newColor];
}

- (void)addAnimationForFillColor:(KWColor *)fillColor withKey:(NSString *)key
{
	CGColorRef newColor = fillColor.CGColor;
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
	[basicAnimation setFromValue:(id)[self fillColor]];
	[basicAnimation setToValue:(__bridge id)newColor];
	[basicAnimation setRemovedOnCompletion:NO];
	[self addAnimation:basicAnimation forKey:key];
	[self setFillColor:newColor];
}

#pragma mark - Convenient Methods

- (CGPathRef)pathRefFromPath:(KWBezierPath *)path
{
	#if TARGET_OS_IPHONE
	return [path CGPath];
	#else
	int i;
	NSInteger numElements;

		// Need to begin a path here.
		CGPathRef					 immutablePath = NULL;

		// Then draw the path elements.
		numElements = [path elementCount];
		if (numElements > 0) {
				CGMutablePathRef		pathRef = CGPathCreateMutable();
				NSPoint						 points[3];
				BOOL								didClosePath = YES;

				for (i = 0; i < numElements; i++)
		{
						switch ([path elementAtIndex:i associatedPoints:points])
			{
								case NSMoveToBezierPathElement:
										CGPathMoveToPoint(pathRef, NULL, points[0].x, points[0].y);
										break;

								case NSLineToBezierPathElement:
										CGPathAddLineToPoint(pathRef, NULL, points[0].x, points[0].y);
										didClosePath = NO;
										break;

								case NSCurveToBezierPathElement:
										CGPathAddCurveToPoint(pathRef, NULL, points[0].x, points[0].y,
																				points[1].x, points[1].y,
																				points[2].x, points[2].y);
										didClosePath = NO;
										break;

								case NSClosePathBezierPathElement:
										CGPathCloseSubpath(pathRef);
										didClosePath = YES;
										break;
						}
				}

				// Be sure the path is closed or Quartz may not do valid hit detection.
				if (!didClosePath)
		{
						CGPathCloseSubpath(pathRef);
		}

				immutablePath = CGPathCreateCopy(pathRef);
				CGPathRelease(pathRef);
		}

		return immutablePath;
	#endif
}

@end
