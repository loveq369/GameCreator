//
//	KGCGameSet.m
//	GameCreator
//
//	Created by Maarten Foukhar on 29-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCGameSet.h"
#import "KGCGame.h"
#import "KGCScene.h"

@implementation KGCGameSet
{
	NSMutableArray *_games;
	NSMutableArray *_gameInfoDictionaries;
}

#pragma mark - Initial Methods

+ (KGCGameSet *)gameSetForDocument:(KGCDocument *)document
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	dictionary[@"_id"] = [[NSUUID UUID] UUIDString];
	dictionary[@"Name"] = @"GameSet";
	dictionary[@"Games"] = [[NSMutableArray alloc] init];
	dictionary[@"ScreenSize"] = @{@"width": @(1024), @"height": @(768)};
	
	KGCGameSet *gameSet = [[KGCGameSet alloc] initWithDictionary:dictionary document:document];
	[gameSet updateDictionary];

	return gameSet;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document
{
	self = [super initWithDictionary:dictionary document:document];
	
	if (self)
	{
		_games = [[NSMutableArray alloc] init];
		
		NSFileWrapper *mainFileWrapper = [document mainFileWrapper];
		
		NSDictionary *gameFileWrappers = [mainFileWrapper fileWrappers];
		_gameInfoDictionaries = dictionary[@"Games"];
		for (NSDictionary *gameInfoDictionary in _gameInfoDictionaries)
		{
			NSString *gameFileName = gameInfoDictionary[@"FileName"];
			NSFileWrapper *gameFileWrapper = gameFileWrappers[gameFileName];
			NSMutableDictionary *gameDictionary = [NSJSONSerialization JSONObjectWithData:[gameFileWrapper regularFileContents] options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
			
			KGCGame *game = [[KGCGame alloc] initWithDictionary:gameDictionary document:document];
			[game setParentObject:self];
			[_games addObject:game];
		}
	}
	
	return self;
}

#pragma mark - Property Methods

- (void)setScreenSize:(NSSize)screenSize
{
	[self setSize:screenSize forKey:@"ScreenSize"];
}

- (NSSize)screenSize
{
	return [self sizeForKey:@"ScreenSize"];
}

#pragma mark - Main Methods

- (NSArray *)games
{
	return [NSArray arrayWithArray:_games];
}

- (void)addGame:(KGCGame *)game
{
	if (game)
	{
		[game setParentObject:self];
	
		[_games addObject:game];
		
		NSData *data = [NSJSONSerialization dataWithJSONObject:[game dictionary] options:NSJSONWritingPrettyPrinted error:nil];
		NSFileWrapper *gameFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
		NSString *gameFileName = [[game identifier] stringByAppendingPathExtension:@"json"];
		[gameFileWrapper setPreferredFilename:gameFileName];
		
		NSFileWrapper *mainFileWrapper = [[self document] mainFileWrapper];
		[mainFileWrapper addFileWrapper:gameFileWrapper];
		
		[_gameInfoDictionaries addObject:@{@"FileName": gameFileName, @"Name": [game name]}];

		[self notifyDelegateAboutKeyChange:@"Scenes"];
		[self updateDictionary];
	}
}

- (void)removeGame:(KGCGame *)game
{
	if ([_games containsObject:game])
	{
		NSString *gameFileName = [[game identifier] stringByAppendingPathExtension:@"json"];
		NSFileWrapper *mainFileWrapper = [[self document] mainFileWrapper];
		[mainFileWrapper removeFileWrapper:[mainFileWrapper fileWrappers][gameFileName]];
		
		for (NSDictionary *_gameInfoDictionary in [_gameInfoDictionaries copy])
		{
			NSString *fileName = _gameInfoDictionary[@"FileName"];
			if ([fileName isEqualToString:gameFileName])
			{
				[_gameInfoDictionaries removeObject:_gameInfoDictionary];
			}
		}
		
		[_games removeObject:game];
		[self notifyDelegateAboutKeyChange:@"Scenes"];
		[self updateDictionary];
	}
}

- (void)imageNames:(NSMutableArray *)imageNames audioNames:(NSMutableArray *)audioNames
{
	for (KGCGame *game in [self games])
	{
		for (KGCScene *scene in [game scenes])
		{
			[self resourceNamesInObject:[scene dictionary] imageNames:imageNames audioNames:audioNames];
		}
	}
}

- (void)setFirstSceneIdentifier:(NSString *)firstSceneIdentifier
{
	[self setObject:firstSceneIdentifier forKey:@"FirstSceneIdentifier"];
}

- (NSString *)firstSceneIdentifier
{
	return [self objectForKey:@"FirstSceneIdentifier"];
}

- (void)setFirstGameIdentifier:(NSString *)firstGameIdentifier
{
	[self setObject:firstGameIdentifier forKey:@"FirstGameIdentifier"];
}

- (NSString *)firstGameIdentifier
{
	return [self objectForKey:@"FirstGameIdentifier"];
}

- (NSArray *)scenes
{
	NSMutableArray *scenes = [[NSMutableArray alloc] init];
	for (KGCGame *game in [self games])
	{
		[scenes addObjectsFromArray:[game scenes]];
	}
	
	return [NSArray arrayWithArray:scenes];
}

#pragma mark - Convenient Methods

- (void)updateDictionary
{
	NSWindow *window = [[self document] windowForSheet];
	NSEvent *currentEvent = [window currentEvent];
	if ([currentEvent type] == NSLeftMouseDragged)
	{
		return;
	}

	NSString *gameSetFileName = [@"GameSet" stringByAppendingPathExtension:@"json"];
	NSData *newData = [NSJSONSerialization dataWithJSONObject:[self dictionary] options:NSJSONWritingPrettyPrinted error:nil];
	NSFileWrapper *newFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:newData];
	[newFileWrapper setPreferredFilename:gameSetFileName];
	
	NSFileWrapper *mainFileWrapper = [[self document] mainFileWrapper];
	[mainFileWrapper removeFileWrapper:[mainFileWrapper fileWrappers][gameSetFileName]];
	[mainFileWrapper addFileWrapper:newFileWrapper];
}

- (void)resourceNamesInObject:(id)object imageNames:(NSMutableArray *)imageNames audioNames:(NSMutableArray *)audioNames
{
	NSArray *subArray;
	if ([object isKindOfClass:[NSDictionary class]])
	{
		for (NSString *key in [[object allKeys] copy])
		{
			if ([key isEqualToString:@"ImageName"])
			{
				NSString *imageName = object[key];
				if (imageNames && ![imageNames containsObject:imageName])
				{
					[imageNames addObject:imageName];
				}
			}
			else if ([key isEqualToString:@"AudioName"])
			{
				NSString *audioName = object[key];
				if (audioNames && ![audioNames containsObject:audioName])
				{
					[audioNames addObject:audioName];
				}
			}
		}
	
		subArray = [object allValues];
	}
	else if ([object isKindOfClass:[NSArray class]])
	{
		subArray = object;
	}
	else
	{
		return;
	}
	
	for (id subObject in subArray)
	{
		[self resourceNamesInObject:subObject imageNames:imageNames audioNames:audioNames];
	}
}

@end