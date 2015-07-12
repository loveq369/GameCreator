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

- (void)setParentObject:(KGCDataObject *)parentObject
{
	[super setParentObject:parentObject];
	
	NSString *sceneFileName = [[self identifier] stringByAppendingPathExtension:@"json"];
	for (NSDictionary *scene in [parentObject dictionary][@"Scenes"])
	{
		if ([scene[@"FileName"] isEqualToString:sceneFileName])
		{
			if (scene[@"Group"])
			{
				[self setGroupName:scene[@"Group"]];
			}
		}
	}
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

- (void)setShouldHighlightQuestionSprites:(BOOL)shouldHighlightQuestionsSprites
{
	[self setBool:shouldHighlightQuestionsSprites forKey:@"ShouldHighlightQuestionSprites"];
}

- (BOOL)shouldHighlightQuestionSprites
{
	return [self boolForKey:@"ShouldHighlightQuestionSprites"];
}

- (void)setGroupName:(NSString *)groupName
{
	[self setObject:groupName forKey:@"Group"];
}

- (NSString *)groupName
{
	return [self objectForKey:@"Group"];
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