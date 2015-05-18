//
//	KGCCombinedAnimation.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCCombinedAnimation.h"
#import "KGCSceneLayer.h"
#import "KGCSceneObject.h"

@implementation KGCCombinedAnimation

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{	@"AnimationType" :	@"Combine",
				@"AnimationKeys" :	[[NSMutableArray alloc] init],
			};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Combine Animation", nil);
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
	NSArray *animations = [self animations];
	__block NSUInteger animationCount = [animations count];
	
	for (KGCAnimation *animation in animations)
	{
		[animation startAnimationOnLayer:layer animated:animated completion:^
		{
			animationCount -= 1;
			
			if (animationCount == 0)
			{
				if (completion)
				{
					completion();
				}
			}
		}];
	}
}

- (void)startBackAnimationOnLayer:(CALayer *)layer animated:(BOOL)animated completion:(void (^)(void))completion
{
	NSArray *animations = [self animations];
	__block NSUInteger animationCount = [animations count];
	
	for (KGCAnimation *animation in animations)
	{
		[animation startBackAnimationOnLayer:layer animated:animated completion:^
		{
			animationCount -= 1;
			
			if (animationCount == 0)
			{
				if (completion)
				{
					completion();
				}
			}
		}];
	}
}

- (BOOL)hasPreview
{
	return YES;
}

@end