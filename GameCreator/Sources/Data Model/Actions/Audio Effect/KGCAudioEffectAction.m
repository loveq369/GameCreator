//
//	KGCAudioEffectAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAudioEffectAction.h"
#import "KGCSettingsViewManager.h"
#import "KGCSpriteLayer.h"
#import "KGCHelperMethods.h"
#import "KGCSceneContentView.h"

@implementation KGCAudioEffectAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Audio", @"AudioName" : @"None", @"Duration": @(0.0)};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Audio Effect Action", nil);
}

#pragma mark - Property Methods

- (NSString *)audioEffectName
{
	return [self objectForKey:@"AudioName"];
}

- (void)setAudioEffectName:(NSString *)audioEffectName
{
	[self setObject:audioEffectName forKey:@"AudioName"];
}

- (BOOL)stopsOtherAudioEffects
{
	return [self boolForKey:@"StopOtherAudioEffects"];
}

- (void)setStopOtherAudioEffects:(BOOL)stopOtherAudioEffects
{
	[self setBool:stopOtherAudioEffects forKey:@"StopOtherAudioEffects"];
}

- (void)setSoundAtURL:(NSURL *)url
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:url type:KGCResourceInfoTypeAudio];
	[self setAudioEffectName:resourceName];
}

@end