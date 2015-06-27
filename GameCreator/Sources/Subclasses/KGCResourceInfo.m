//
//	KGCResourceInfo.m
//	GameCreator
//
//	Created by Maarten Foukhar on 15-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCResourceInfo.h"

@implementation KGCResourceInfo
{
	NSString *_name;
	NSFileWrapper *_resourceFileWrapper;
	NSMutableArray *_infoDictionaries;
}

- (instancetype)initWithName:(NSString *)name type:(KGCResourceInfoType)type resourceFileWrapper:(NSFileWrapper *)resourceFileWrapper
{
	self = [super init];
	
	if (self)
	{
		_resourceFileWrapper = resourceFileWrapper;
		_name = name;
		_type = type;
		
		NSMutableDictionary *infoDictionary = [self infoDictionary];
		if (!infoDictionary)
		{
			NSMutableArray *infoDictionaries = [self infoDictionaries];
			NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
			infoDictionary[@"Name"] = name;
			[infoDictionaries addObject:infoDictionary];
			[self updateWithNewDictionaries:infoDictionaries];
		}
	}
	
	return self;
}

- (void)prepareForRemoval
{
	NSMutableArray *infoDictionaries = [self infoDictionaries];
	for (NSMutableDictionary *infoDictionary in [infoDictionaries copy])
	{
		if ([infoDictionary[@"Name"] isEqualToString:[self name]])
		{
			[infoDictionaries removeObject:infoDictionary];
		}
	}
	[self updateWithNewDictionaries:infoDictionaries];
}

- (void)setName:(NSString *)name
{
	[self setObject:name forKey:@"Name"];
}

- (NSString *)name
{
	return _name;
}

- (void)setMd5String:(NSString *)md5String
{
	[self setObject:md5String forKey:@"Checksum"];
}

- (NSString *)md5String
{
	return [self infoDictionary][@"Checksum"];
}

- (void)setDuration:(NSTimeInterval)duration
{
	[self setObject:@(duration) forKey:@"Length"];
}

- (NSTimeInterval)duration
{
	return [[self infoDictionary][@"Length"] doubleValue];
}

- (void)setTransparent:(BOOL)transparent
{
	[self setObject:@(transparent) forKey:@"Transparent"];
}

- (BOOL)isTransparent
{
	return [[self infoDictionary][@"Transparent"] boolValue];
}

- (NSMutableDictionary *)infoDictionary
{
	NSMutableArray *infoDictionaries = [self infoDictionaries];
	for (NSMutableDictionary *infoDictionary in infoDictionaries)
	{
		if ([infoDictionary[@"Name"] isEqualToString:[self name]])
		{
			return infoDictionary;
		}
	}
	
	return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
	NSMutableArray *infoDictionaries = [self infoDictionaries];
	for (NSMutableDictionary *infoDictionary in infoDictionaries)
	{
		if ([infoDictionary[@"Name"] isEqualToString:[self name]])
		{
			infoDictionary[key] = object;
		}
	}
	[self updateWithNewDictionaries:infoDictionaries];
}

- (NSMutableArray *)infoDictionaries
{
	NSString *infoName = [self type] == KGCResourceInfoTypeAudio ? @"AudioInfo.json" : @"ImageInfo.json";

	NSData *data = [[_resourceFileWrapper fileWrappers][infoName] regularFileContents];
	return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
}

- (void)updateWithNewDictionaries:(NSMutableArray *)newDictionaries
{
	NSString *infoName = [self type] == KGCResourceInfoTypeAudio ? @"AudioInfo.json" : @"ImageInfo.json";

	[_resourceFileWrapper removeFileWrapper:[_resourceFileWrapper fileWrappers][infoName]];
	NSData *data = [NSJSONSerialization dataWithJSONObject:newDictionaries options:NSJSONWritingPrettyPrinted error:nil];
	NSFileWrapper *newFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
	[newFileWrapper setPreferredFilename:infoName];
	[_resourceFileWrapper addFileWrapper:newFileWrapper];
}

@end