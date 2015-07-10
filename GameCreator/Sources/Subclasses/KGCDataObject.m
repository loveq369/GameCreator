//
//	KGCDataObject.m
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDataObject.h"
#import "KGCHelperMethods.h"

@implementation KGCDataObject

#pragma mark - Initial Methods

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document
{
	self = [super init];
	
	if (self)
	{
		_dictionary = dictionary;
		_document = document;
	}
	
	return self;
}

- (instancetype)initWithCopyData:(NSData *)copyData document:(KGCDocument *)document
{
	NSMutableDictionary *copyDictionary = [NSJSONSerialization JSONObjectWithData:copyData options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
	
	return [self initWithCopyDictionary:copyDictionary document:document];
}

- (instancetype)initWithCopyDictionary:(NSMutableDictionary *)copyDictionary document:(KGCDocument *)document
{
	KGCResourceController *resourceController = [document resourceController];
	
	NSMutableDictionary *dictionary = copyDictionary[@"Dictionary"];
	
	// Images
	NSMutableArray *imageDictionaries = copyDictionary[@"Images"];
	NSMutableDictionary *imageMappings = [[NSMutableDictionary alloc] init];
	for (NSDictionary *imageDictionary in imageDictionaries)
	{
		NSString *name = imageDictionary[@"Name"];
		NSString *md5 = imageDictionary[@"MD5"];
		NSData *data = [[NSData alloc] initWithBase64EncodedString:imageDictionary[@"Data"] options:0];
		NSString *finalName = [resourceController resourceNameForData:data md5String:md5 proposedName:name type:KGCResourceInfoTypeImage];
		if (![finalName isEqualToString:name])
		{
			imageMappings[name] = finalName;
		}
	}
	
	// Sounds
	NSMutableArray *soundDictionaries = copyDictionary[@"Sounds"];
	NSMutableDictionary *soundMappings = [[NSMutableDictionary alloc] init];
	for (NSDictionary *soundDictionary in soundDictionaries)
	{
		NSString *name = soundDictionary[@"Name"];
		NSString *md5 = soundDictionary[@"MD5"];
		NSData *data = [[NSData alloc] initWithBase64EncodedString:soundDictionary[@"Data"] options:0];
		NSString *finalName = [resourceController resourceNameForData:data md5String:md5 proposedName:name type:KGCResourceInfoTypeAudio];
		if (![finalName isEqualToString:name])
		{
			soundMappings[name] = finalName;
		}
	}
	
	[KGCHelperMethods updateUUIDsInDictionary:dictionary imageMappings:imageMappings audioMappings:soundMappings];
	
	return [self initWithDictionary:dictionary document:document];
}

- (NSData *)copyData
{
	return [NSJSONSerialization dataWithJSONObject:[self copyDictionary] options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSDictionary *)copyDictionary
{
	NSMutableDictionary *dictionary = [self dictionary];

	NSMutableDictionary *copyDictionary = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *imageNames = [[NSMutableArray alloc] init];
	NSMutableArray *soundNames = [[NSMutableArray alloc] init];
	[KGCHelperMethods getMediaFromDictionary:dictionary soundNames:soundNames imageNames:imageNames];
	
	KGCResourceController *resourceController = [[self document] resourceController];
	
	// Images
	NSMutableArray *imageDictionaries = [[NSMutableArray alloc] init];
	copyDictionary[@"Images"] = imageDictionaries;
	
	for (NSString *imageName in imageNames)
	{
		if (![imageName isEqualTo:@"None"])
		{
			NSString *md5 = [resourceController md5ForImageName:imageName];
			NSData *data = [resourceController imageDataForImageName:imageName];
			
			if (data)
			{
				NSDictionary *imageDictionary = @{@"Name": imageName, @"MD5": md5, @"Data": [data base64EncodedStringWithOptions:0]};
				[imageDictionaries addObject:imageDictionary];
			}
		}
	}
	
	// Sounds
	NSMutableArray *soundDictionaries = [[NSMutableArray alloc] init];
	copyDictionary[@"Sounds"] = soundDictionaries;
	
	for (NSString *soundName in soundNames)
	{
		if (![soundName isEqualTo:@"None"])
		{
			NSString *md5 = [resourceController md5ForAudioName:soundName];
			NSData *data = [resourceController audioDataForName:soundName];
			
			if (data)
			{
				NSDictionary *soundDictionary = @{@"Name": soundName, @"MD5": md5, @"Data": [data base64EncodedStringWithOptions:0]};
				[soundDictionaries addObject:soundDictionary];
			}
		}
	}
	
	copyDictionary[@"Dictionary"] = dictionary;

	return copyDictionary;
}

#pragma mark - Property Methods

- (void)setIdentifier:(NSString *)identifier
{
	[self setObject:[identifier copy] forKey:@"_id"];
}

- (NSString *)identifier
{
	return [self objectForKey:@"_id"];
}

- (void)setName:(NSString *)name
{
	[self setObject:[name copy] forKey:@"Name"];
}

- (NSString *)name
{
	return [self dictionary][@"Name"];
}

#pragma mark - Main Methods

- (void)notifyDelegateAboutKeyChange:(NSString *)key
{
	id <KGCDataObjectDelegate> delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(dataObject:valueChangedForKey:visualChange:)])
	{
		[delegate dataObject:self valueChangedForKey:key visualChange:[[self visualKeys] containsObject:key]];
	}
	
	KGCDataObject *parentObject = [self parentObject];
	if (parentObject)
	{
		[parentObject notifyDelegateAboutKeyChange:key inChildObject:self];
	}
}

- (void)notifyDelegateAboutKeyChange:(NSString *)key inChildObject:(KGCDataObject *)childObject
{	
	id <KGCDataObjectDelegate> delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(dataObject:childObject:valueChangedForKey:visualChange:)])
	{
		[delegate dataObject:self childObject:childObject valueChangedForKey:key visualChange:[[childObject visualKeys] containsObject:key]];
	}
	
	KGCDataObject *parentObject = [self parentObject];
	if (parentObject)
	{
		[parentObject notifyDelegateAboutKeyChange:key inChildObject:self];
	}
}

- (NSArray *)visualKeys
{
	return @[];
}

- (void)updateDictionary
{
	KGCDataObject *parentObject = [self parentObject];
	if (parentObject)
	{
		[parentObject updateDictionary];
	}
}

#pragma mark - Object/key methods

- (void)setObject:(id)object forKey:(NSString *)key
{
	id currentObject = [self objectForKey:key];
	
	if (![currentObject isEqualTo:object])
	{
		if (object == nil)
		{
			[[self dictionary] removeObjectForKey:key];
		}
		else
		{
			[self dictionary][key] = object;
		}
	
		[self notifyDelegateAboutKeyChange:key];
		[self updateDictionary];
	}
}

- (void)setBool:(BOOL)boolValue forKey:(NSString *)key
{
	[self setObject:@(boolValue) forKey:key];
}

- (void)setDouble:(CGFloat)doubleValue forKey:(NSString *)key
{
	[self setObject:@(doubleValue) forKey:key];
}

- (void)setInteger:(NSInteger)integer forKey:(NSString *)key
{
	[self setObject:@(integer) forKey:key];
}

- (void)setUnsignedInteger:(NSUInteger)unsignedInteger forKey:(NSString *)key
{
	[self setObject:@(unsignedInteger) forKey:key];
}

- (void)setPosition:(NSPoint)position
{
	NSDictionary *positionDictionary = @{@"x": @(position.x), @"y": @(position.y)};
	[self setObject:positionDictionary forKey:@"Position"];
}

- (void)setPoint:(NSPoint)point forKey:(NSString *)key
{
	NSDictionary *pointDictionary = @{@"x": @(point.x), @"y": @(point.y)};
	[self setObject:pointDictionary forKey:key];
}

- (void)setSize:(NSSize)size forKey:(NSString *)key
{
	NSDictionary *sizeDictionary = @{@"width": @(size.width), @"height": @(size.height)};
	[self setObject:sizeDictionary forKey:key];
}

- (void)setRect:(NSRect)rect forKey:(NSString *)key
{
	NSDictionary *rectDictionary = @{@"x": @(rect.origin.x), @"y": @(rect.origin.y), @"width": @(rect.size.width), @"height": @(rect.size.height)};
	[self setObject:rectDictionary forKey:key];
}

- (id)objectForKey:(NSString *)key
{
	return [self dictionary][key];
}

- (CGFloat)doubleForKey:(NSString *)key
{
	return [[self objectForKey:key] doubleValue];
}

- (NSInteger)integerForKey:(NSString *)key
{
	return [[self objectForKey:key] integerValue];
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key
{
	return [[self objectForKey:key] unsignedIntegerValue];
}

- (NSPoint)pointForKey:(NSString *)key
{
	NSDictionary *pointDictionary = [self objectForKey:key];
	CGFloat x = [pointDictionary[@"x"] doubleValue];
	CGFloat y = [pointDictionary[@"y"] doubleValue];
	return NSMakePoint(x, y);
}

- (NSSize)sizeForKey:(NSString *)key
{
	NSDictionary *sizeDictionary = [self objectForKey:key];
	CGFloat width = [sizeDictionary[@"width"] doubleValue];
	CGFloat height = [sizeDictionary[@"height"] doubleValue];
	return NSMakeSize(width, height);
}

- (NSRect)rectForKey:(NSString *)key
{
	NSDictionary *rectDictionary = [self objectForKey:key];
	CGFloat x = [rectDictionary[@"x"] doubleValue];
	CGFloat y = [rectDictionary[@"y"] doubleValue];
	CGFloat width = [rectDictionary[@"width"] doubleValue];
	CGFloat height = [rectDictionary[@"height"] doubleValue];
	return NSMakeRect(x, y, width, height);
}

- (BOOL)boolForKey:(NSString *)key
{
	return [[self objectForKey:key] boolValue];
}

- (BOOL)hasObjectForKey:(NSString *)key
{
	return [[[self dictionary] allKeys] containsObject:key];
}

#pragma mark - Soundset Methods

- (void)setSoundPlayMode:(KGCSoundPlayMode)soundPlayMode forKey:(NSString *)key
{
	NSMutableDictionary *soundDictionary = [self _soundDictionaryForKey:key];
	soundDictionary[@"SoundPlayMode"] = @(soundPlayMode);
	[self notifyDelegateAboutKeyChange:key];
	[self updateDictionary];
}

- (KGCSoundPlayMode)soundPlayModeForKey:(NSString *)key
{
	NSMutableDictionary *soundDictionary = [self _soundDictionaryForKey:key];

	return [soundDictionary[@"SoundPlayMode"] integerValue];
}

- (NSArray *)soundsForKey:(NSString *)key
{
	NSMutableArray *soundDictionaries = [self _soundDictionariesForKey:key];
	
	if (soundDictionaries)
	{
		NSMutableArray *soundNames = [[NSMutableArray alloc] init];
		for (NSDictionary *soundDictionary in soundDictionaries)
		{
			[soundNames addObject:soundDictionary[@"AudioName"]];
		}
		
		return [NSArray arrayWithArray:soundNames];
	}
	
	return @[];
}

- (NSArray *)soundDictionariesForKey:(NSString *)key
{
	NSMutableArray *soundDictionaries = [self _soundDictionariesForKey:key];
	if (soundDictionaries)
	{
		return [NSArray arrayWithArray:soundDictionaries];
	}
	
	return nil;
}

- (NSMutableArray *)_soundDictionariesForKey:(NSString *)key
{
	NSMutableArray *soundSets = [self dictionary][@"SoundSets"];
	for (NSMutableDictionary *sound in soundSets)
	{
		if ([sound[@"Name"] isEqualToString:key])
		{
			return sound[@"Sounds"];
		}
	}
	
	return nil;
}

- (NSMutableDictionary *)_soundDictionaryForKey:(NSString *)key
{
	NSMutableArray *soundSets = [self dictionary][@"SoundSets"];
	for (NSMutableDictionary *sound in soundSets)
	{
		if ([sound[@"Name"] isEqualToString:key])
		{
			return sound;
		}
	}
	
	return nil;
}

- (void)addSoundAtURL:(NSURL *)soundURL forKey:(NSString *)key
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:soundURL type:KGCResourceInfoTypeAudio];
	
	NSMutableArray *soundDictionaries = [self _soundDictionariesForKey:key];
	if (!soundDictionaries)
	{
		NSMutableDictionary *soundDictionary = [[NSMutableDictionary alloc] init];
		soundDictionary[@"Name"] = key;
		soundDictionaries = [[NSMutableArray alloc] init];
		soundDictionary[@"Sounds"] = soundDictionaries;
		NSMutableArray *soundSets = [self dictionary][@"SoundSets"];
		if (!soundSets)
		{
			soundSets = [[NSMutableArray alloc] init];
			[self dictionary][@"SoundSets"] = soundSets;
		}
		[soundSets addObject:soundDictionary];
	}
	
	NSMutableDictionary *soundDictionary = [[NSMutableDictionary alloc] init];
	soundDictionary[@"AudioName"] = resourceName;
	soundDictionary[@"_id"] = [[NSUUID UUID] UUIDString];
	[soundDictionaries addObject:soundDictionary];
	
	[self notifyDelegateAboutKeyChange:key];
	[self updateDictionary];
}

- (void)removeSoundNamed:(NSString *)hintSoundName forKey:(NSString *)key
{
	NSMutableArray *soundDictionaries = [self _soundDictionariesForKey:key];
	for (NSDictionary *soundDictionary in [soundDictionaries copy])
	{
		if ([soundDictionary[@"AudioName"] isEqualToString:hintSoundName])
		{
			[soundDictionaries removeObject:soundDictionary];
		}	
	}
	
	[self notifyDelegateAboutKeyChange:key];
	[self updateDictionary];
}

- (void)setSoundAtURL:(NSURL *)soundURL forKey:(NSString *)key
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:soundURL type:KGCResourceInfoTypeAudio];
	
	NSMutableArray *soundDictionaries = [[NSMutableArray alloc] init];
	NSMutableDictionary *newSoundDictionary = [[NSMutableDictionary alloc] init];
	newSoundDictionary[@"AudioName"] = resourceName;
	newSoundDictionary[@"_id"] = [[NSUUID UUID] UUIDString];
	[soundDictionaries addObject:newSoundDictionary];
	
	NSMutableArray *soundSets = [self dictionary][@"SoundSets"];
	if (!soundSets)
	{
		soundSets = [[NSMutableArray alloc] init];
		[self dictionary][@"SoundSets"] = soundSets;
	}
	
	NSMutableDictionary *soundDictionary = [self _soundDictionaryForKey:key];
	if (soundDictionary)
	{
		[soundSets removeObject:soundDictionary];
	}
	
	soundDictionary = [[NSMutableDictionary alloc] init];
	soundDictionary[@"Name"] = key;
	soundDictionary[@"Sounds"] = soundDictionaries;
	
	[soundSets addObject:soundDictionary];
	
	[self notifyDelegateAboutKeyChange:key];
	[self updateDictionary];
}

@end