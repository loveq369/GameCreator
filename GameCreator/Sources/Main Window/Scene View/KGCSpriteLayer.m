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

@interface KGCSpriteLayer () <KGCDataObjectDelegate>

@end

@implementation KGCSpriteLayer
{
	NSSize _imageSize;
	BOOL _keepPosition;
}

- (void)setupWithSceneObject:(KGCSceneObject *)sceneObject
{
	[super setupWithSceneObject:sceneObject];
	
	KGCSprite *sprite = [self sprite];
	[sprite setDelegate:self];
	
	NSString *imageName = [sprite imageName];
	if (imageName)
	{
		KGCResourceController *resourceController = [self resourceController];
		NSImage *image = [resourceController imageNamed:imageName];
		[self setContents:(id)[image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil]];
		[self setImage:image];
	}
	
	[self update];
}

#pragma mark - Main Methods

- (void)update
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
		
		[self updateBoundsWithScale:normalMode ? [sprite scale] : [sprite initialScale] notify:YES];
		[self setZPosition:normalMode ? [sprite zOrder] : [sprite initialScale]];
		[self setOpacity:normalMode ? [sprite alpha] : [sprite initialAlpha]];
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
	if ([key isEqualToString:@"ImageName"])
	{
		KGCSprite *sprite = [self sprite];
		KGCDocument *document = [sprite document];
		KGCDocumentEditMode editMode = [document editMode];
		BOOL normalMode = (editMode == KGCDocumentEditModeNormal) || ![document previewInitialMode];
		
		KGCResourceController *resourceController = [[sprite document] resourceController];
		NSImage *image = [resourceController imageNamed:[sprite imageName]];
		[self setContents:(id)[image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil]];
		[self setImage:image];
		[self updateBoundsWithScale:normalMode ? [sprite scale] : [sprite initialScale] notify:YES];
		
		return;
	}
	
	if (visualChange)
	{
		[self update];
	}	
}

#pragma mark - Convenient Methods

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