//
//	KGCResourceController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 15-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "KGCResourceController.h"

@implementation KGCResourceController
{
	NSFileWrapper *_imageFileWrapper;
	NSMutableDictionary *_imageInfoObjects;
	
	NSFileWrapper *_audioFileWrapper;
	NSMutableDictionary *_audioInfoObjects;
}

#pragma mark - Iniitial Methods

- (instancetype)initWithImageFileWrapper:(NSFileWrapper *)imageFileWrapper audioFileWrapper:(NSFileWrapper *)audioFileWrapper
{
	self = [super init];
	
	if (self)
	{
		_imageFileWrapper = imageFileWrapper;
		_imageInfoObjects = [[NSMutableDictionary alloc] init];
		
		NSMutableDictionary *imageFileWrappers = [[imageFileWrapper fileWrappers] mutableCopy];
		if (![[imageFileWrappers allKeys] containsObject:@"ImageInfo.json"])
		{
			NSData *data = [NSJSONSerialization dataWithJSONObject:@[] options:NSJSONWritingPrettyPrinted error:nil];
			NSFileWrapper *imageInfoFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
			[imageInfoFileWrapper setPreferredFilename:@"ImageInfo.json"];
			[_imageFileWrapper addFileWrapper:imageInfoFileWrapper];
		}
		
		for (NSFileWrapper *imageWrapper in [imageFileWrappers allValues])
		{
			NSString *name = [imageWrapper preferredFilename];
			
			if ([name isEqualToString:@"ImageInfo.json"])
			{
				continue;
			}
			
			KGCResourceInfo *resourceInfo = [[KGCResourceInfo alloc] initWithName:name type:KGCResourceInfoTypeImage resourceFileWrapper:_imageFileWrapper];
			[resourceInfo setFileWrapper:imageWrapper];
			_imageInfoObjects[name] = resourceInfo;
		}
		
		_audioFileWrapper = audioFileWrapper;
		_audioInfoObjects = [[NSMutableDictionary alloc] init];
		
		NSMutableDictionary *audioFileWrappers = [[audioFileWrapper fileWrappers] mutableCopy];
		if (![[audioFileWrappers allKeys] containsObject:@"AudioInfo.json"])
		{
			NSData *data = [NSJSONSerialization dataWithJSONObject:@[] options:NSJSONWritingPrettyPrinted error:nil];
			NSFileWrapper *audioInfoFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
			[audioInfoFileWrapper setPreferredFilename:@"AudioInfo.json"];
			[_audioFileWrapper addFileWrapper:audioInfoFileWrapper];
		}
		
		for (NSFileWrapper *audioWrapper in [audioFileWrappers allValues])
		{
			NSString *name = [audioWrapper preferredFilename];
			
			if ([name isEqualToString:@"AudioInfo.json"])
			{
				continue;
			}
		
			KGCResourceInfo *resourceInfo = [[KGCResourceInfo alloc] initWithName:name type:KGCResourceInfoTypeAudio resourceFileWrapper:_audioFileWrapper];
			[resourceInfo setFileWrapper:audioWrapper];
			_audioInfoObjects[name] = resourceInfo;
		}
	}
		
	return self;
}

#pragma mark - Main Methods

- (NSString *)resourceNameForURL:(NSURL *)url type:(KGCResourceInfoType)type
{
	NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initWithURL:url options:NSFileWrapperReadingImmediate error:nil];
	[fileWrapper setPreferredFilename:[url lastPathComponent]];
	return [self resourceNameForFileWrapper:fileWrapper type:type];
}

- (NSString *)resourceNameForData:(NSData *)data md5String:(NSString *)md5String proposedName:(NSString *)proposedName type:(KGCResourceInfoType)type
{
	NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
	[fileWrapper setPreferredFilename:proposedName];
	return [self resourceNameForFileWrapper:fileWrapper md5String:md5String type:type];
}

- (NSString *)resourceNameForFileWrapper:(NSFileWrapper *)fileWrapper type:(KGCResourceInfoType)type
{
	return [self resourceNameForFileWrapper:fileWrapper md5String:nil type:type];
}

- (NSString *)resourceNameForFileWrapper:(NSFileWrapper *)fileWrapper md5String:(NSString *)md5String type:(KGCResourceInfoType)type
{
	NSData *data = [fileWrapper regularFileContents];
	if (!md5String)
	{
		md5String = [self md5ForData:data];
	}
	NSMutableArray *names = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *infoObjects = (type == KGCResourceInfoTypeImage) ? _imageInfoObjects : _audioInfoObjects;
	for (KGCResourceInfo *resourceInfo in [infoObjects allValues])
	{
		if ([md5String isEqualToString:[resourceInfo md5String]])
		{
			return [resourceInfo name];
		}
		else
		{
			[names addObject:[resourceInfo name]];
		}
	}
	
	NSString *name = [fileWrapper preferredFilename];
	NSUInteger appendNumber = 1;
	while ([names containsObject:name])
	{
		name = [NSString stringWithFormat:@"%@ %i.%@", [name stringByDeletingPathExtension], (int)appendNumber, [name pathExtension]];
		appendNumber += 1;
	}

	KGCResourceInfo *resourceInfo = [[KGCResourceInfo alloc] initWithName:name type:type resourceFileWrapper:type == KGCResourceInfoTypeImage ? _imageFileWrapper : _audioFileWrapper];
	[resourceInfo setFileWrapper:fileWrapper];
	[resourceInfo setMd5String:md5String];
	
	if (type == KGCResourceInfoTypeImage)
	{
		_imageInfoObjects[name] = resourceInfo;
		[_imageFileWrapper addFileWrapper:fileWrapper];
	}
	else if (type == KGCResourceInfoTypeAudio)
	{
		AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
		[resourceInfo setDuration:[audioPlayer duration]];
	
		_audioInfoObjects[name] = resourceInfo;
		[_audioFileWrapper addFileWrapper:fileWrapper];
	}
	
	return name;
}

- (NSImage *)imageNamed:(NSString *)imageName
{
	if ([[_imageInfoObjects allKeys] containsObject:imageName])
	{
		KGCResourceInfo *resourceInfo = _imageInfoObjects[imageName];
		return [[NSImage alloc] initWithData:[[resourceInfo fileWrapper] regularFileContents]];
	}

	return nil;
}

- (NSData *)imageDataForImageName:(NSString *)imageName
{
	if ([[_imageInfoObjects allKeys] containsObject:imageName])
	{
		KGCResourceInfo *resourceInfo = _imageInfoObjects[imageName];
		return [[resourceInfo fileWrapper] regularFileContents];
	}

	return nil;
}

- (NSData *)audioDataForName:(NSString *)audioName
{
	if ([[_audioInfoObjects allKeys] containsObject:audioName])
	{
		KGCResourceInfo *resourceInfo = _audioInfoObjects[audioName];
		return [[resourceInfo fileWrapper] regularFileContents];
	}

	return nil;
}

#pragma mark - Convenient Methods

- (KGCResourceInfo *)resourceInfoWithName:(NSString *)name
{
	NSMutableArray *infoObjects = [[NSMutableArray alloc] init];
	[infoObjects addObjectsFromArray:[_imageInfoObjects allValues]];
	[infoObjects addObjectsFromArray:[_audioInfoObjects allValues]];
	for (KGCResourceInfo *resourceInfo in infoObjects)
	{
		if ([name isEqualTo:[resourceInfo name]])
		{
			return resourceInfo;
		}
	}
	
	return nil;
}

- (NSString *)md5ForData:(NSData *)data
{
	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5([data bytes], (CC_LONG)[data length], md5Buffer);

	// Convert unsigned char buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i ++)
	{
		[output appendFormat:@"%02x",md5Buffer[i]];
	}
	
	return output;
}

- (NSString *)md5ForImageName:(NSString *)imageName
{
	NSString *md5 = [_imageInfoObjects[imageName] md5String];
	
	if (!md5)
	{
		NSLog(@"Should not come here: %@", imageName);
		NSData *data = [self imageDataForImageName:imageName];
		md5 = [self md5ForData:data];
		[_imageInfoObjects[imageName] setMd5String:md5];
	}

	return md5;
}

- (NSString *)md5ForAudioName:(NSString *)audioName
{
	NSString *md5 = [_audioInfoObjects[audioName] md5String];
	
	if (!md5)
	{
		NSLog(@"Should not come here: %@", audioName);
		NSData *data = [self audioDataForName:audioName];
		md5 = [self md5ForData:data];
		[_audioInfoObjects[audioName] setMd5String:md5];
	}

	return md5;
}

- (void)updateInfoDictionary:(NSDictionary *)infoDictionary ofType:(KGCResourceInfoType)type
{
	
}

- (void)updateImagesWithImageNames:(NSArray *)imageNames
{
	NSMutableArray *imageNamesArray = [imageNames mutableCopy];
	for (NSString *resourceInfoKey in [_imageInfoObjects copy])
	{
		KGCResourceInfo *resourceInfo = _imageInfoObjects[resourceInfoKey];		
		if (![resourceInfo md5String])
		{
			NSString *md5String = [self md5ForData:[self imageDataForImageName:[resourceInfo name]]];
			[resourceInfo setMd5String:md5String];
		}
	
		NSString *name = [resourceInfo name];
		if (![imageNames containsObject:name])
		{
			[resourceInfo prepareForRemoval];
			[_imageFileWrapper removeFileWrapper:[resourceInfo fileWrapper]];
			[_imageInfoObjects removeObjectForKey:resourceInfoKey];
		}
		else
		{
			[imageNamesArray removeObject:name];
		}
	}
	
	if ([imageNamesArray count] > 0)
	{
		//tmp
		for (NSString *name in imageNamesArray)
		{
			KGCResourceInfo *resourceInfo = [[KGCResourceInfo alloc] initWithName:name type:KGCResourceInfoTypeImage resourceFileWrapper:_imageFileWrapper];
			[resourceInfo setFileWrapper:[_imageFileWrapper fileWrappers][name]];
			_imageInfoObjects[name] = resourceInfo;
		}
	
		NSLog(@"WARNING: Orphan image name: %@", imageNamesArray);
	}
}

- (void)updateAudioWithAudioNames:(NSArray *)audioNames
{
	NSMutableArray *audioNamesArray = [audioNames mutableCopy];
	for (NSString *resourceInfoKey in [_audioInfoObjects copy])
	{
		KGCResourceInfo *resourceInfo = _audioInfoObjects[resourceInfoKey];
	
		NSString *name = [resourceInfo name];
		
		//tmp
		if ([resourceInfo duration] == 0.0)
		{
			AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:[self audioDataForName:[resourceInfo name]] error:nil];
			[resourceInfo setDuration:[audioPlayer duration]];
			NSLog(@"New duration: %f for %@", [audioPlayer duration], name);
		}
		
		if (![resourceInfo md5String])
		{
			NSString *md5String = [self md5ForData:[self audioDataForName:name]];
			[resourceInfo setMd5String:md5String];
		}
		
		if (![audioNamesArray containsObject:name])
		{
			[resourceInfo prepareForRemoval];
			[_audioFileWrapper removeFileWrapper:[resourceInfo fileWrapper]];
			[_audioInfoObjects removeObjectForKey:resourceInfoKey];
		}
		else
		{
			[audioNamesArray removeObject:name];
		}
	}
	
	if ([audioNamesArray count] > 0)
	{
		//tmp
		for (NSString *name in audioNamesArray)
		{
			KGCResourceInfo *resourceInfo = [[KGCResourceInfo alloc] initWithName:name type:KGCResourceInfoTypeImage resourceFileWrapper:_audioFileWrapper];
			[resourceInfo setFileWrapper:[_audioFileWrapper fileWrappers][name]];
			_audioInfoObjects[name] = resourceInfo;
		}
	
		NSLog(@"WARNING: Orphan audio name: %@", audioNamesArray);
	}
}

@end