//
//	KGCScene.m
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCScene.h"
#import "KGCResourceController.h"
#import "KGCHelperMethods.h"
#import "KGCSprite.h"

@interface KGCScene ()

@end

@implementation KGCScene
{
	NSMutableArray *_sprites;
	NSMutableArray *_spriteDictionaries;
	NSMutableArray *_hintSounds;
}

#pragma mark - Initial Method

+ (KGCScene *)sceneWithName:(NSString *)name templateType:(KGCTemplateType)templateType document:(KGCDocument *)document
{
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	dictionary[@"_id"] = [[NSUUID UUID] UUIDString];
	dictionary[@"Name"] = name;
	dictionary[@"Sprites"] = [[NSMutableArray alloc] init];
	dictionary[@"TemplateType"] = @(templateType);
	
	KGCScene *scene = [[KGCScene alloc] initWithDictionary:dictionary document:document];
	[scene updateDictionary];

	return scene;
}

- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document
{
	self = [super initWithDictionary:dictionary document:document];
	
	if (self)
	{
		_sprites = [[NSMutableArray alloc] init];
		
		_spriteDictionaries = dictionary[@"Sprites"];
		for (NSMutableDictionary *spriteDictionary in _spriteDictionaries)
		{
			KGCSprite *sprite = [[KGCSprite alloc] initWithDictionary:spriteDictionary document:document];
			[sprite setParentObject:self];
			[_sprites addObject:sprite];
		}
		
		_hintSounds = dictionary[@"HintSounds"];
		if (!_hintSounds)
		{
			_hintSounds = [[NSMutableArray alloc] init];
			dictionary[@"HintSounds"] = _hintSounds;
		}
		
		NSFileWrapper *sceneFileWrapper = [document sceneFileWrapper];
		NSString *fileName = [[self identifier] stringByAppendingPathExtension:@"jpg"];
		NSDictionary *fileWrappers = [sceneFileWrapper fileWrappers];
		if ([[fileWrappers allKeys] containsObject:fileName])
		{
			NSData *data = [fileWrappers[fileName] regularFileContents];
			_thumbnailImage = [[NSImage alloc] initWithData:data];
		}
	}
	
	return self;
}

- (instancetype)initWithCopyData:(NSData *)copyData document:(KGCDocument *)document
{
	KGCResourceController *resourceController = [document resourceController];
	
	NSMutableDictionary *copyDictionary = [NSJSONSerialization JSONObjectWithData:copyData options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
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
			NSLog(@"%@ %@ %i", imageName, md5, (int)[data length]);
			
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
			NSLog(@"%@ %@ %i [2]", soundName, md5, (int)[data length]);
			
			if (data)
			{
				NSDictionary *soundDictionary = @{@"Name": soundName, @"MD5": md5, @"Data": [data base64EncodedStringWithOptions:0]};
				[soundDictionaries addObject:soundDictionary];
			}
		}
	}
	
	copyDictionary[@"Dictionary"] = dictionary;

	return [NSJSONSerialization dataWithJSONObject:copyDictionary options:NSJSONWritingPrettyPrinted error:nil];
}

#pragma mark - Main Methods

- (NSArray *)sprites
{
	return [NSArray arrayWithArray:_sprites];
}

- (void)addSprite:(KGCSprite *)sprite
{
	if (sprite)
	{
		[sprite setParentObject:self];
		[_sprites addObject:sprite];
		[_spriteDictionaries addObject:[sprite dictionary]];
		[self notifyDelegateAboutKeyChange:@"Sprites"];
		[self updateDictionary];
	}
}

- (void)removeSprite:(KGCSprite *)sprite
{
	if ([_sprites containsObject:sprite])
	{
		[_sprites removeObject:sprite];
		[_spriteDictionaries removeObject:[sprite dictionary]];
		[self notifyDelegateAboutKeyChange:@"Sprites"];
		[self updateDictionary];
	}
}

- (void)setTemplateType:(KGCTemplateType)templateType
{
	[self setUnsignedInteger:templateType forKey:@"TemplateType"];
}

- (KGCTemplateType)templateType
{
	return [self unsignedIntegerForKey:@"TemplateType"];
}

- (NSString *)imageName
{
	return [self objectForKey:@"ImageName"];
}

- (void)setImageURL:(NSURL *)imageURL
{
	KGCResourceController *resourceController = [[self document] resourceController];
	NSString *resourceName = [resourceController resourceNameForURL:imageURL type:KGCResourceInfoTypeImage];
	[self setObject:resourceName forKey:@"ImageName"];
}

- (void)clearImage
{
	[self setObject:nil forKey:@"ImageName"];
}

- (void)setRequiredPoints:(NSInteger)requiredPoints
{
	[self setInteger:requiredPoints forKey:@"RequiredPoints"];
}

- (NSInteger)requiredPoints
{
	return [self integerForKey:@"RequiredPoints"]; 
}

- (void)setRequireConfirmation:(BOOL)requireConfirmation
{
	[self setBool:requireConfirmation forKey:@"RequireConfirmation"];
}

- (BOOL)requireConfirmation
{
	return [self boolForKey:@"RequireConfirmation"];
}

- (void)setAutoFadeIn:(BOOL)autoFadeIn
{
	[self setBool:autoFadeIn forKey:@"AutoFadeIn"];
}	

- (BOOL)autoFadeIn
{
	return [self boolForKey:@"AutoFadeIn"];
}

- (void)setAutoFadeOut:(BOOL)autoFadeOut
{
	[self setBool:autoFadeOut forKey:@"AutoFadeOut"];
}

- (BOOL)autoFadeOut
{
	return [self boolForKey:@"AutoFadeOut"];
}

- (BOOL)isDisableConfirmInteraction
{
	return [self boolForKey:@"DisableConfirmInteraction"];
}

- (void)setDisableConfirmInteraction:(BOOL)disableConfirmInteraction
{
	[self setBool:disableConfirmInteraction forKey:@"DisableConfirmInteraction"];
}

- (BOOL)autoMoveBackWrongAnswers
{
	return [self boolForKey:@"AutoMoveBackWrongAnswers"];
}

- (void)setAutoMoveBackWrongAnswers:(BOOL)autoMoveBackWrongAnswers
{
	[self setBool:autoMoveBackWrongAnswers forKey:@"AutoMoveBackWrongAnswers"];
}

- (BOOL)isPhysicsEnabled
{
	return [self boolForKey:@"PhysicsEnabled"];
}

- (void)setPhysicsEnabled:(BOOL)physicsEnabled
{
	[self setBool:physicsEnabled forKey:@"PhysicsEnabled"];
}

- (CGPoint)gravity
{
	return [self pointForKey:@"PhysicsGravity"];
}

- (void)setGravity:(CGPoint)gravity
{
	[self setPoint:gravity forKey:@"PhysicsGravity"];
}

- (void)setThumbnailImage:(NSImage *)thumbnailImage
{
	_thumbnailImage = thumbnailImage;

	NSSize imageSize = [thumbnailImage size];
	
	[thumbnailImage lockFocus] ;
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height)] ;
	[thumbnailImage unlockFocus];
	
	NSFileWrapper *sceneFileWrapper = [[self document] sceneFileWrapper];
	NSString *fileName = [[self identifier] stringByAppendingPathExtension:@"jpg"];
	NSDictionary *fileWrappers = [sceneFileWrapper fileWrappers];
	if ([[fileWrappers allKeys] containsObject:fileName])
	{
		[sceneFileWrapper removeFileWrapper:fileWrappers[fileName]];
	}
	
	NSData *data = [bitmapRep representationUsingType:NSJPEGFileType properties:@{}];
	NSFileWrapper *newFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
	[newFileWrapper setPreferredFilename:fileName];
	[sceneFileWrapper addFileWrapper:newFileWrapper];
}

#pragma mark - Class Methods

- (NSArray *)visualKeys
{
	return @[@"ImageName"];
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

	NSString *sceneFileName = [[self identifier] stringByAppendingPathExtension:@"json"];
	NSData *newData = [NSJSONSerialization dataWithJSONObject:[self dictionary] options:NSJSONWritingPrettyPrinted error:nil];
	NSFileWrapper *newFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:newData];
	[newFileWrapper setPreferredFilename:sceneFileName];
	
	NSFileWrapper *sceneFileWrapper = [[self document] sceneFileWrapper];
	[sceneFileWrapper removeFileWrapper:[sceneFileWrapper fileWrappers][sceneFileName]];
	[sceneFileWrapper addFileWrapper:newFileWrapper];
}

@end