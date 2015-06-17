//
//	KGCSpriteLayer.m
//	GameCreator
//
//	Created by Maarten Foukhar on 07-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSpriteLayer.h"
#import "KGCAction.h"
#import "KGCEvent.h"
#import "KGCTemplateAction.h"
#import "KGCAnimation.h"
#import "KGCSceneContentView.h"
#import "KGCHelperMethods.h"
#import "KGCResourceController.h"
#import "CALayer+Animation.h"

#define DEG2RAD (3.1415926/180.0)

@interface KGCSpriteLayer () <KGCDataObjectDelegate>

@end

@implementation KGCSpriteLayer
{
	NSSize _imageSize;
	BOOL _keepPosition;
	CGFloat _rotationDegrees;
}

- (void)setupWithSceneObject:(KGCSceneObject *)sceneObject
{
	[super setupWithSceneObject:sceneObject];
	
	KGCSprite *sprite = [self sprite];
	[sprite setDelegate:self];
	
	[self setImage:[self combinedImage]];
	
	[self updateAnimated:NO];
}

#pragma mark - Main Methods

- (void)update
{
	[self updateAnimated:YES];
}

- (void)updateAnimated:(BOOL)animated
{
	KGCSprite *sprite = [self sprite];
	if (sprite)
	{
		KGCDocument *document = [sprite document];
		KGCDocumentEditMode editMode = [document editMode];
		BOOL normalMode = (editMode == KGCDocumentEditModeNormal) || ![document previewInitialMode];
		
		NSPoint position = normalMode ? [sprite position] : [sprite initialPosition];
		if (!NSEqualPoints(position, [self position]))
		{
			[super setPosition:position];
		}
		
		[CATransaction begin];
		[CATransaction setAnimationDuration:animated ? 0.25 : 0.0];
		[self updateBoundsWithScale:normalMode ? [sprite scale] : [sprite initialScale] notify:YES];
		[self setZPosition:normalMode ? [sprite zOrder] : [sprite initialZOrder]];
		[self setOpacity:normalMode ? [sprite alpha] : [sprite initialAlpha]];
		[self addAnimationForRotationAngle:normalMode ? [sprite rotationDegrees] * DEG2RAD : [sprite initialRotationDegrees] * DEG2RAD withKey:@"Rotation"];
		[CATransaction commit];
	}
}

- (void)setSelected:(BOOL)selected
{
	_selected = selected;
	
	if (selected)
	{
		[CATransaction begin];
		[CATransaction setAnimationDuration:0.0];
		[self setBorderWidth:1.0];
		[self setBorderColor:[[NSColor blueColor] CGColor]];
		[CATransaction commit];
	}
	else if (!selected)
	{
		[CATransaction begin];
		[CATransaction setAnimationDuration:0.0];
		[self setBorderWidth:0.0];
		[CATransaction commit];
	}
}

- (void)setPosition:(CGPoint)position animated:(BOOL)animated
{
	[CATransaction begin];
	[CATransaction setAnimationDuration:animated ? 0.25 : 0.0];
	[super setPosition:position];
	[CATransaction commit];
	
	[[self sprite] setPosition:position];
}

- (void)setPosition:(CGPoint)position
{
	[self setPosition:position animated:NO];
}

#pragma mark - DataObject Delegate Methods

- (void)dataObject:(KGCDataObject *)dataObject valueChangedForKey:(NSString *)key visualChange:(BOOL)visualChange
{
	if ([key isEqualToString:@"ImageName"] || [key isEqualToString:@"BackgroundImage"])
	{
		KGCSprite *sprite = [self sprite];
		KGCDocument *document = [sprite document];
		KGCDocumentEditMode editMode = [document editMode];
		BOOL normalMode = (editMode == KGCDocumentEditModeNormal) || ![document previewInitialMode];
		
		[self setImage:[self combinedImage]];
		
		[self updateBoundsWithScale:normalMode ? [sprite scale] : [sprite initialScale] notify:YES];
		
		return;
	}
	
	if (visualChange)
	{
		[self update];
	}	
}

#pragma mark - Convenient Methods

- (NSImage *)combinedImage
{
	KGCResourceController *resourceController = [self resourceController];

	KGCSprite *sprite = [self sprite];
	NSImage *backgroundImage = [resourceController imageNamed:[sprite backgroundImageName]];
	NSImage *normalImage = [resourceController imageNamed:[sprite imageName]];
	
	NSImage *image;
	if (backgroundImage)
	{
		NSSize backgroundImageSize = [backgroundImage size];
		NSSize normalImageSize = [normalImage size];
		
		CGFloat width = backgroundImageSize.width > normalImageSize.width ? backgroundImageSize.width : normalImageSize.width;
		CGFloat height = backgroundImageSize.height > normalImageSize.height ? backgroundImageSize.height : normalImageSize.height;
		image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
		
		[image lockFocus];
		
		CGFloat x = backgroundImageSize.width > normalImageSize.width ? 0.0 : (normalImageSize.width - backgroundImageSize.width) / 2.0;
		CGFloat y = backgroundImageSize.height > normalImageSize.height ? 0.0 : (normalImageSize.height - backgroundImageSize.height) / 2.0;
		[backgroundImage drawInRect:NSMakeRect(x, y, backgroundImageSize.width, backgroundImageSize.height)];
		
		x = normalImageSize.width > backgroundImageSize.width ? 0.0 : (backgroundImageSize.width - normalImageSize.width) / 2.0;
		y = normalImageSize.height > backgroundImageSize.height ? 0.0 : (backgroundImageSize.height - normalImageSize.height) / 2.0;
		[normalImage drawInRect:NSMakeRect(x, y, normalImageSize.width, normalImageSize.height)];
		
		[image unlockFocus];
	}
	else
	{
		image = normalImage;
	}
	
	return image;
}

- (void)updateBoundsWithScale:(CGFloat)scale notify:(BOOL)notify
{
	CGRect realBounds = [self realBounds];
	realBounds.size.width *= scale;
	realBounds.size.height *= scale;
	[self setBounds:realBounds];
}

- (KGCSprite *)sprite
{
	return (KGCSprite *)[self sceneObject];
}

@end