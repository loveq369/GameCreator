//
//	KGCSettingsViewManager.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSettingsViewManager.h"
#import "KGCSettingsView.h"

@implementation KGCSettingsViewManager
{
	NSMutableDictionary *_views;
}

#pragma mark - Initial Methods

+ (KGCSettingsViewManager *)sharedManager
{
	static KGCSettingsViewManager *sharedManager = nil;
	static dispatch_once_t onceToken = 0;

				dispatch_once(&onceToken, ^
		{
					sharedManager = [[KGCSettingsViewManager alloc] init];
			});

			return sharedManager;
}

- (instancetype)init
{
	self = [super init];
	
	if (self)
	{
		_views = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

#pragma mark - Main Methods

- (KGCSettingsView *)viewForBundleName:(NSString *)bundleName
{
	KGCSettingsView *view = _views[bundleName];
	if (!view)
	{
		view = [self newViewForBundleName:bundleName];
		
		if (view)
		{
			_views[bundleName] = view;
		}
	}

	return view;
}

- (KGCSettingsView *)newViewForBundleName:(NSString *)bundleName
{
	if ([[NSBundle mainBundle] pathForResource:bundleName ofType:@"nib"])
	{
		NSNib *nib = [[NSNib alloc] initWithNibNamed:bundleName bundle:nil];
		
		if (nib)
		{
			NSArray *objects;
			[nib instantiateWithOwner:nil topLevelObjects:&objects];
			
			for (id object in objects)
			{
				if ([object isKindOfClass:[KGCSettingsView class]])
				{
					return object;
				}
			}
		}
	}
	
	return nil;
}

@end