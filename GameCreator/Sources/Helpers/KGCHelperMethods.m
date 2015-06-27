//
//	KGCHelperMethods.m
//	GameCreator
//
//	Created by Maarten Foukhar on 04-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCHelperMethods.h"

struct Pixel
{
    unsigned char r, g, b, a;
};

@implementation KGCHelperMethods

+ (NSString *)uniqueNameWithProposedName:(NSString *)proposedName atPath:(NSString *)path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *newPath = [path stringByAppendingPathComponent:proposedName];
	
	if (![fileManager fileExistsAtPath:newPath])
	{
		return newPath;
	}

	NSString *extension = [proposedName pathExtension];
	NSString *baseName = [proposedName stringByDeletingPathExtension];
	
	for (NSUInteger i = 0; i < NSUIntegerMax; i ++)
	{
		NSString *newName = [baseName stringByAppendingFormat:@"-%lu.%@", i + 1, extension];
		newPath = [path stringByAppendingPathComponent:newName];
		
		if (![fileManager fileExistsAtPath:newPath])
		{
			return newPath;
		}
	}

	return nil;
}

+ (NSString *)uniqueNameWithProposedName:(NSString *)proposedName inDictionary:(NSDictionary *)dictionary
{
	NSArray *allKeys = [dictionary allKeys];
	if (![allKeys containsObject:proposedName])
	{
		return proposedName;
	}
	
	NSUInteger appendNumber = 1;
	NSString *dotString = (![[proposedName pathExtension] isEqualToString:@""]) ? @"." : @"";
	NSString *newName = [NSString stringWithFormat:@"%@ %i%@%@", [proposedName stringByDeletingPathExtension], (int)appendNumber, dotString, [proposedName pathExtension]];
	while ([allKeys containsObject:newName])
	{
		appendNumber += 1;
		newName = [NSString stringWithFormat:@"%@ %i%@%@", [proposedName stringByDeletingPathExtension], (int)appendNumber, dotString, [proposedName pathExtension]];
	}
	
	return newName;
}

+ (NSString *)uniqueNameWithProposedName:(NSString *)proposedName inArray:(NSArray *)array
{
	if (![array containsObject:proposedName])
	{
		return proposedName;
	}
	
	NSUInteger appendNumber = 1;
	NSString *dotString = (![[proposedName pathExtension] isEqualToString:@""]) ? @"." : @"";
	NSString *newName = [NSString stringWithFormat:@"%@ %i%@%@", [proposedName stringByDeletingPathExtension], (int)appendNumber, dotString, [proposedName pathExtension]];
	while ([array containsObject:newName])
	{
		appendNumber += 1;
		newName = [NSString stringWithFormat:@"%@ %i%@%@", [proposedName stringByDeletingPathExtension], (int)appendNumber, dotString, [proposedName pathExtension]];
	}
	
	return newName;
}

+ (void)updateUUIDsInDictionary:(NSMutableDictionary *)dictionary imageMappings:(NSDictionary *)imageMappings audioMappings:(NSDictionary *)audioMappings
{
	NSMutableDictionary *uuidMappings = [[NSMutableDictionary alloc] init];
	[self updateUUIDsInObject:dictionary uuidMappings:uuidMappings imageMappings:imageMappings audioMappings:audioMappings];
	[self updateUUIDReferencesInObject:dictionary parentObject:nil uuidMappings:uuidMappings];
}

+ (void)updateUUIDsInObject:(id)object uuidMappings:(NSMutableDictionary *)uuidMappings imageMappings:(NSDictionary *)imageMappings audioMappings:(NSDictionary *)audioMappings
{
	NSArray *subArray;
	if ([object isKindOfClass:[NSDictionary class]])
	{
		for (NSString *key in [[object allKeys] copy])
		{
			if ([key isEqualToString:@"ImageName"])
			{
				if (imageMappings)
				{
					NSString *imageName = object[key];
					if ([[imageMappings allKeys] containsObject:imageName])
					{
						object[key] = imageMappings[imageName];
					}
				}
			}
			else if ([key isEqualToString:@"AudioName"])
			{
				if (audioMappings)
				{
					NSString *audioName = object[key];
					if ([[audioMappings allKeys] containsObject:audioName])
					{
						object[key] = audioMappings[audioName];
					}
				}
			}
		
			if ([key isEqualToString:@"_id"])
			{
				NSString *newUUID = [[NSUUID UUID] UUIDString];
				uuidMappings[object[@"_id"]] = newUUID;
				object[@"_id"] = newUUID;
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
	
	for (NSInteger i = 0; i < [subArray count]; i ++)
	{
		id subObject = subArray[i];
		[self updateUUIDsInObject:subObject uuidMappings:uuidMappings imageMappings:imageMappings audioMappings:audioMappings];
	}
}

+ (void)updateUUIDReferencesInObject:(id)object parentObject:(id)parentObject uuidMappings:(NSDictionary *)uuidMappings
{
	NSArray *subArray;
	if ([object isKindOfClass:[NSDictionary class]])
	{
		subArray = [object allValues];
	}
	else if ([object isKindOfClass:[NSArray class]])
	{
		subArray = object;
	}
	else if ([object isKindOfClass:[NSString class]])
	{
		if ([[uuidMappings allKeys] containsObject:object])
		{
			if ([parentObject isKindOfClass:[NSMutableDictionary class]])
			{
				NSArray *keys = [parentObject allKeysForObject:object];
				for (NSString *key in [keys copy])
				{
					parentObject[key] = uuidMappings[object];
				}
			}
			else if ([parentObject isKindOfClass:[NSMutableArray class]])
			{
				[parentObject replaceObjectAtIndex:[parentObject indexOfObject:object] withObject:uuidMappings[object]];
			}
		}
		
		return;
	}
	else
	{
		return;
	}
	
	for (NSInteger i = 0; i < [subArray count]; i ++)
	{
		id subObject = subArray[i];
		[self updateUUIDReferencesInObject:subObject parentObject:object uuidMappings:uuidMappings];
	}
}

+ (void)getMediaFromDictionary:(NSDictionary *)dictionary soundNames:(NSMutableArray *)soundNames imageNames:(NSMutableArray *)imageNames
{
	[self copySubObject:dictionary soundNames:soundNames imageNames:imageNames];
}

+ (void)copySubObject:(id)object soundNames:(NSMutableArray *)soundNames imageNames:(NSMutableArray *)imageNames
{
	NSArray *subArray;
	if ([object isKindOfClass:[NSDictionary class]])
	{
		for (NSString *key in [[object allKeys] copy])
		{
			if ([key isEqualToString:@"ImageName"])
			{
				if (imageNames)
				{
					[imageNames addObject:object[key]];
				}
			}
			else if ([key isEqualToString:@"AudioName"])
			{
				if (soundNames)
				{
					[soundNames addObject:object[key]];
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
		[self copySubObject:subObject soundNames:soundNames imageNames:imageNames];
	}
}

+ (BOOL)isImageTransparent:(NSImage *)image
{
	CGImageRef imageRef = [image CGImageForProposedRect:NULL context:NULL hints:nil];
	CGSize imageSize = CGSizeMake((double)CGImageGetWidth(imageRef), (double)CGImageGetHeight(imageRef));
	struct Pixel *pixels = (struct Pixel *) calloc(1, imageSize.width * imageSize.height * sizeof(struct Pixel));
	
	CGContextRef context = CGBitmapContextCreate(	(void *)pixels,
														 imageSize.width,
														 imageSize.height,
														 8,
														 imageSize.width * 4,
														 CGImageGetColorSpace(imageRef),
														 (CGBitmapInfo)kCGImageAlphaPremultipliedLast
													 );
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), imageRef);
	CGContextRelease(context);
	
	uint numberOfPixels = imageSize.width * imageSize.height;
	for (int i = 0; i < numberOfPixels; i ++)
	{
		struct Pixel pixel = pixels[i];
		if (pixel.a != 0)
		{
			free(pixels);
			return NO;
		}
	}
	
	free(pixels);
	return YES;
}

@end