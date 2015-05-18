//
//	KGCSoundTemplateAction.m
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSoundTemplateAction.h"
#import "KGCSceneContentView.h"
#import "KGCSceneLayer.h"

@implementation KGCSoundTemplateAction

#pragma mark - Creation Methods

+ (NSDictionary *)createDictionary
{
	return @{@"ActionType" : @"Sound", @"Loop" : @(NO)};
}

+ (NSString *)defaultName
{
	return NSLocalizedString(@"Sound Action", nil);
}

#pragma mark - Main Methods

- (void)setSoundAtURL:(NSURL *)url
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:url type:KGCResourceInfoTypeAudio];
	[self setSoundName:resourceName];
}

#pragma mark - Property Methods

- (NSString *)soundName
{
	return [self objectForKey:@"AudioName"];
}

- (void)setSoundName:(NSString *)soundName
{
	[self setObject:soundName forKey:@"AudioName"];
}

- (NSMutableArray *)soundNames
{
	return [self objectForKey:@"SoundNames"];
}

- (void)setSoundNames:(NSMutableArray *)soundNames
{
	[self setObject:soundNames forKey:@"SoundNames"];
}

- (BOOL)loops
{
	return [self boolForKey:@"Loop"];
}

- (void)setLoop:(BOOL)loop
{
	[self setBool:loop forKey:@"Loop"];
}

- (BOOL)stopOtherSounds
{
	return [self boolForKey:@"StopOtherSounds"];
}

- (void)setStopOtherSounds:(BOOL)stopOtherSounds
{
	[self setBool:stopOtherSounds forKey:@"StopOtherSounds"];
}

@end