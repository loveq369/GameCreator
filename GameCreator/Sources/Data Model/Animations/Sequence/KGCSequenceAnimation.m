//
//	KGCSequenceAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSequenceAnimation.h"
#import "KGCSceneObject.h"

@implementation KGCSequenceAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Sequence",
				@"AnimationKeys" :	[[NSMutableArray alloc] init],
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Sequence Animation", nil);
}

- (NSMutableArray *)animationKeys
{
	return [self objectForKey:@"AnimationKeys"];
}

- (NSArray *)animations
{
	NSArray *animations = [(KGCSceneObject *)[self parentObject] animations];
	NSMutableArray *filteredActions = [[NSMutableArray alloc] init];
	NSArray *animationKeys = [self animationKeys];
	
	for (KGCAnimation *animation in animations)
	{
		if ([animationKeys containsObject:[animation identifier]])
		{
			[filteredActions addObject:animation];
		}
	}
	
	return [NSArray arrayWithArray:filteredActions];
}

- (void)startAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion
{
	[self startAnimationAnimated:animated layer:layer animations:[self animations] index:0 completion:completion];
}

- (void)startAnimationAnimated:(BOOL)animated layer:(CALayer *)layer animations:(NSArray *)animations index:(NSUInteger)index completion:(void (^)(void))completion
{
	if (index == [animations count])
	{
		if (completion)
		{
			completion();
		}
		
		return;
	}
	
	KGCAnimation *animation = animations[index];
	[animation startAnimationOnLayer:layer animated:animated completion:^
	{
		[self startAnimationAnimated:animated layer:layer animations:animations index:index + 1 completion:completion];
	}];
}

- (void)startBackAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion
{
	[self starBackAnimationAnimated:animated layer:layer animations:[self animations] index:0 completion:completion];
}

- (void)starBackAnimationAnimated:(BOOL)animated layer:(CALayer *)layer animations:(NSArray *)animations index:(NSUInteger)index completion:(void (^)(void))completion
{
	if (index == [animations count])
	{
		if (completion)
		{
			completion();
		}
		
		return;
	}
	
	KGCAnimation *animation = animations[index];
	[animation startBackAnimationOnLayer:layer animated:animated completion:^
	{
		[self startAnimationAnimated:animated layer:layer animations:animations index:index + 1 completion:completion];
	}];
}

- (BOOL)hasPreview
{
	return YES;
}

@end