//
//	KGCGame.m
//	GameCreator
//
//	Created by Maarten Foukhar on 26-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCGame.h"
#import "KGCScene.h"

@implementation KGCGame
{
	NSMutableArray *_scenes;
	NSMutableArray *_sceneInfoDictionaries;
}

#pragma mark - Initial Methods

+ (KGCGame *)gameWithName:(NSString *)name document:(KGCDocument *)document
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	dictionary[@"_id"] = [[NSUUID UUID] UUIDString];
	dictionary[@"Name"] = name;
	dictionary[@"Scenes"] = [[NSMutableArray alloc] init];
	
	KGCGame *game = [[KGCGame alloc] initWithDictionary:dictionary document:document];
	[game updateDictionary];

	return game;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document
{
	self = [super initWithDictionary:dictionary document:document];
	
	if (self)
	{
		_scenes = [[NSMutableArray alloc] init];
		
		NSFileWrapper *scenesFileWrapper = [document sceneFileWrapper];
		NSDictionary *sceneFileWrappers = [scenesFileWrapper fileWrappers];
		_sceneInfoDictionaries = dictionary[@"Scenes"];
		for (NSMutableDictionary *sceneInfoDictionary in _sceneInfoDictionaries)
		{
			NSString *sceneFileName = sceneInfoDictionary[@"FileName"];
			NSFileWrapper *sceneFileWrapper = sceneFileWrappers[sceneFileName];
			NSMutableDictionary *sceneDictionary = [NSJSONSerialization JSONObjectWithData:[sceneFileWrapper regularFileContents] options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
			
			KGCScene *scene = [[KGCScene alloc] initWithDictionary:sceneDictionary document:document];
			[scene setParentObject:self];
			[_scenes addObject:scene];
		}
	}
	
	return self;
}

- (instancetype)initWithCopyData:(NSData *)copyData document:(KGCDocument *)document
{
	NSMutableDictionary *copyDictionary = [NSJSONSerialization JSONObjectWithData:copyData options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
	
	NSString *name = copyDictionary[@"Name"];
	self = [KGCGame gameWithName:name document:document];
	
	if (self)
	{
		NSMutableArray *scenes = copyDictionary[@"Scenes"];
		for (NSString *sceneBase64String in scenes)
		{
			NSData *sceneData = [[NSData alloc] initWithBase64EncodedString:sceneBase64String options:0];
			KGCScene *scene = [[KGCScene alloc] initWithCopyData:sceneData document:document];
			[self addScene:scene];
		}
	}

	return self;
}

- (NSData *)copyData
{
	NSMutableDictionary *copyDictionary = [[NSMutableDictionary alloc] init];
	copyDictionary[@"Name"] = [self name];
	
	NSMutableArray *scenes = [[NSMutableArray alloc] init];
	copyDictionary[@"Scenes"] = scenes;
	for (KGCScene *scene in _scenes)
	{
		[scenes addObject:[[scene copyData] base64EncodedStringWithOptions:0]];
	}
	
	return [NSJSONSerialization dataWithJSONObject:copyDictionary options:NSJSONWritingPrettyPrinted error:nil];
}

#pragma mark - Main Methods

- (NSArray *)scenes
{
	return [NSArray arrayWithArray:_scenes];
}

- (void)addScene:(KGCScene *)scene
{
	if (scene)
	{
		[scene setParentObject:self];
	
		[_scenes addObject:scene];
		
		NSData *data = [NSJSONSerialization dataWithJSONObject:[scene dictionary] options:NSJSONWritingPrettyPrinted error:nil];
		NSFileWrapper *sceneFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
		NSString *sceneFileName = [[scene identifier] stringByAppendingPathExtension:@"json"];
		[sceneFileWrapper setPreferredFilename:sceneFileName];
		
		NSFileWrapper *scenesFileWrapper = [[self document] sceneFileWrapper];
		[scenesFileWrapper addFileWrapper:sceneFileWrapper];
		
		NSMutableDictionary *sceneInfoDictionary = [@{@"FileName": sceneFileName, @"Name": [scene name]} mutableCopy];
		NSString *sceneImageName = [scene imageName];
		if (sceneImageName)
		{
			sceneInfoDictionary[@"BackgroundImage"] = sceneImageName;
		}
		
		[_sceneInfoDictionaries addObject:sceneInfoDictionary];

		[self notifyDelegateAboutKeyChange:@"Scenes"];
		[self updateDictionary];
	}
}

- (void)insertScene:(KGCScene *)scene atIndex:(NSInteger)index
{
	if (scene)
	{
		[scene setParentObject:self];
	
		[_scenes insertObject:scene atIndex:index];
		
		NSData *data = [NSJSONSerialization dataWithJSONObject:[scene dictionary] options:NSJSONWritingPrettyPrinted error:nil];
		NSFileWrapper *sceneFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
		NSString *sceneFileName = [[scene identifier] stringByAppendingPathExtension:@"json"];
		[sceneFileWrapper setPreferredFilename:sceneFileName];
		
		NSFileWrapper *scenesFileWrapper = [[self document] sceneFileWrapper];
		[scenesFileWrapper addFileWrapper:sceneFileWrapper];
		
		NSMutableDictionary *sceneInfoDictionary = [@{@"FileName": sceneFileName, @"Name": [scene name]} mutableCopy];
		NSString *sceneImageName = [scene imageName];
		if (sceneImageName)
		{
			sceneInfoDictionary[@"BackgroundImage"] = sceneImageName;
		}
		
		[_sceneInfoDictionaries insertObject:sceneInfoDictionary atIndex:index];

		[self notifyDelegateAboutKeyChange:@"Scenes"];
		[self updateDictionary];
	}
}

- (void)removeScene:(KGCScene *)scene
{
	if ([_scenes containsObject:scene])
	{
		NSString *sceneFileName = [[scene identifier] stringByAppendingPathExtension:@"json"];
		NSFileWrapper *scenesFileWrapper = [[self document] sceneFileWrapper];
		[scenesFileWrapper removeFileWrapper:[scenesFileWrapper fileWrappers][sceneFileName]];
		
		for (NSDictionary *_sceneInfoDictionary in [_sceneInfoDictionaries copy])
		{
			NSString *fileName = _sceneInfoDictionary[@"FileName"];
			if ([fileName isEqualToString:sceneFileName])
			{
				[_sceneInfoDictionaries removeObject:_sceneInfoDictionary];
			}
		}
		
		[_scenes removeObject:scene];
		[self notifyDelegateAboutKeyChange:@"Scenes"];
		[self updateDictionary];
	}
}

- (void)imageNames:(NSMutableArray *)imageNames audioNames:(NSMutableArray *)audioNames sceneImageDictionary:(NSMutableDictionary *)sceneImageDictionary
{
	for (KGCScene *scene in [self scenes])
	{
		NSMutableArray *sceneImageNames = [[NSMutableArray alloc] init];
		[self resourceNamesInObject:[scene dictionary] imageNames:sceneImageNames audioNames:audioNames];
		if (sceneImageDictionary)
		{
			sceneImageDictionary[[scene identifier]] = sceneImageNames;
		}
		[imageNames addObjectsFromArray:sceneImageNames];
	}
}

- (NSArray *)audioNames
{
	NSMutableArray *audioNames = [[NSMutableArray alloc] init];
	
	for (KGCScene *scene in [self scenes])
	{
		[self resourceNamesInObject:[scene dictionary] imageNames:nil audioNames:audioNames];
	}
	
	return [NSArray arrayWithArray:audioNames];
}

#pragma mark - Data Object Methods

- (void)notifyDelegateAboutKeyChange:(NSString *)key inChildObject:(KGCDataObject *)childObject
{
	[super notifyDelegateAboutKeyChange:key inChildObject:childObject];
	
	if ([childObject isKindOfClass:[KGCScene class]] && ([key isEqualToString:@"ImageName"] || [key isEqualToString:@"AutoFadeIn"] || [key isEqualToString:@"Name"] || [key isEqualToString:@"Group"]))
	{
		NSString *sceneFileName = [[childObject identifier] stringByAppendingPathExtension:@"json"];
		for (NSMutableDictionary *sceneInfoDictionary in [_sceneInfoDictionaries copy])
		{
			NSString *fileName = sceneInfoDictionary[@"FileName"];
			if ([fileName isEqualToString:sceneFileName])
			{
				if ([key isEqualToString:@"Name"])
				{
					[self setObject:[childObject name] forKey:@"Name"];
				}
				else if ([key isEqualToString:@"ImageName"])
				{
					NSString *imageName = [(KGCScene *)childObject imageName];
					[self setObject:imageName forKey:@"BackgroundImage"];
				}
				else if ([key isEqualToString:@"AutoFadeIn"])
				{
					BOOL autoFadeIn = [(KGCScene *)childObject autoFadeIn];
					[self setBool:autoFadeIn forKey:@"AutoFadeIn"];
				}
				else if ([key isEqualToString:@"Group"])
				{
					[self setObject:[(KGCScene *)childObject groupName] forKey:@"Group"];
				}
			}
		}
	}
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

	NSString *gameFileName = [[self identifier] stringByAppendingPathExtension:@"json"];
	NSData *newData = [NSJSONSerialization dataWithJSONObject:[self dictionary] options:NSJSONWritingPrettyPrinted error:nil];
	NSFileWrapper *newFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:newData];
	[newFileWrapper setPreferredFilename:gameFileName];
	
	NSFileWrapper *mainFileWrapper = [[self document] mainFileWrapper];
	[mainFileWrapper removeFileWrapper:[mainFileWrapper fileWrappers][gameFileName]];
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