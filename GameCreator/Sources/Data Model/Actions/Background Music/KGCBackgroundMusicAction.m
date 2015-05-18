//
//	KGCBackgroundMusicAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCBackgroundMusicAction.h"
#import "KGCSettingsViewManager.h"
#import "KGCSpriteLayer.h"
#import "KGCHelperMethods.h"
#import "KGCSceneContentView.h"

@implementation KGCBackgroundMusicAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"BackgroundMusic", @"AudioName" : @"None"};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Background Music Action", nil);
}

#pragma mark - Property Methods

- (NSString *)audioName
{
	return [self objectForKey:@"AudioName"];
}

- (void)setAudioName:(NSString *)audioName
{
	[self setObject:audioName forKey:@"AudioName"];
}

- (void)setSoundAtURL:(NSURL *)url
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:url type:KGCResourceInfoTypeAudio];
	[self setAudioName:resourceName];
}

@end