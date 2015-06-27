//
//	KGCSceneContentView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 13-02-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSceneContentView.h"
#import "KGCHelperMethods.h"
#import "KGCImageLayer.h"
#import "KGCSpriteLayer.h"
#import "KGCAction.h"
#import "KGCEvent.h"
#import "KGCTemplateAction.h"
#import "KGCDocument.h"
#import "KGCResourceController.h"
#import "KGCScene.h"

@interface KGCSceneContentView () <NSDraggingDestination, KGCDataObjectDelegate>

@property (nonatomic, strong) KGCSceneLayer *contentLayer;
@property (nonatomic, weak) IBOutlet KGCDocument *document;

@end

@implementation KGCSceneContentView
{
	BOOL _shiftPressed;
	BOOL _mouseDragged;
	NSPoint _startDragLocation;
}

#pragma mark - Initial Methods

- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	if (self)
	{
		[self setup];
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	if (self)
	{
		[self setup];
	}
	
	return self;
}

- (void)setup
{
	_scale = 1.0;
	[self setWantsLayer:YES];
	
	_contentLayer = [KGCSceneLayer layer];
	[[self layer] addSublayer:_contentLayer];
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[self registerForDraggedTypes:@[NSFilenamesPboardType]];
	
	NSRect bounds = [self bounds];
	KGCImageLayer *contentLayer = [self contentLayer];
	[contentLayer setBounds:bounds];
	[contentLayer setPosition:CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0)];
	
	[[self layer] setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable | kCALayerMinXMargin | kCALayerMinYMargin];
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	
	NSRect bounds = [self bounds];
	KGCImageLayer *contentLayer = [self contentLayer];
	[contentLayer setPosition:CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0)];
}

- (void)setupWithScene:(KGCScene *)scene
{
	if (_scene)
	{
		[_scene setDelegate:nil];
	}

	_scene = scene;
	[scene setDelegate:self];
	
	KGCSceneLayer *contentLayer = [self contentLayer];
	[contentLayer setupWithSceneObject:scene];
	[[contentLayer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	
	NSString *imageName = [scene imageName];
	if (imageName)
	{
		KGCResourceController *resourceController = [[self document] resourceController];
		NSImage *backgroundImage = [resourceController imageNamed:imageName isTransparent:NO];
		
		[CATransaction begin];
		[CATransaction setAnimationDuration:0.0];
		[contentLayer setImage:backgroundImage];
		[CATransaction commit];
	}
	else
	{
		[contentLayer setImage:nil];
	}
	
	NSArray *sprites = [scene sprites];
	for (KGCSprite *sprite in sprites)
	{
		KGCSpriteLayer *spriteLayer = [KGCSpriteLayer layerWithSceneObject:sprite sceneContentView:self];
		[contentLayer addSublayer:spriteLayer];
	}
	
	[self updateLayerOrder];
}

#pragma mark - Main Methods

- (NSArray *)spriteLayers
{
	return [[self contentLayer] sublayers];
}

#pragma mark - Property Methods

#pragma mark General

- (void)setContentSize:(NSSize)contentSize
{
	_contentSize = contentSize;
	
	CGFloat scale = [self scale];
	
	NSRect frame = [self frame];
	frame.size.width = contentSize.width * scale;
	frame.size.height = contentSize.height *scale;
	[self setFrame:frame];
	
	NSRect bounds = [self bounds];
	KGCImageLayer *contentLayer = [self contentLayer];
	[contentLayer setBounds:bounds];
	[contentLayer setPosition:CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0)];
}

- (void)setScale:(CGFloat)scale
{
	[self setScale:scale animated:NO];
}

- (void)setScale:(CGFloat)scale animated:(BOOL)animated
{
	CALayer *sceneLayer = [self layer];
	
	[CATransaction begin];
	
	CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	[basicAnimation setFromValue:@(_scale)];
	[basicAnimation setToValue:@(scale)];
	[sceneLayer addAnimation:basicAnimation forKey:nil];
	[sceneLayer setValue:@(scale) forKeyPath:@"transform.scale"];

	[CATransaction commit];
	
	_scale = scale;
	
	[self setContentSize:[self contentSize]];
}

- (void)setPositionEditModeActive:(BOOL)positionEditModeActive
{
	_positionEditModeActive = positionEditModeActive;
	
	CALayer *contentLayer = [self contentLayer];
	[contentLayer setBorderWidth:positionEditModeActive ? 1.0 : 0.0];
	[contentLayer setBorderColor:[[NSColor redColor] CGColor]];
}

#pragma mark - DataObject Delegate Methods

- (void)dataObject:(KGCDataObject *)dataObject valueChangedForKey:(NSString *)key visualChange:(BOOL)visualChange
{
	if (visualChange)
	{	
		KGCScene *scene = [self scene];
		NSImage *image = [[[scene document] resourceController] imageNamed:[scene imageName] isTransparent:NO];
		KGCImageLayer *contentLayer = [self contentLayer];
		[contentLayer setContents:(id)[image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil]];
		[self updateThumbnailImage];
	}
}

- (void)dataObject:(KGCDataObject *)dataObject childObject:(KGCDataObject *)childObject valueChangedForKey:(NSString *)key visualChange:(BOOL)visualChange
{
	if (visualChange)
	{
		[self updateThumbnailImage];
		
		if ([key isEqualToString:@"zOrder"])
		{
			[self updateLayerOrder];
		}
	}
}

#pragma mark - Mouse Methods

- (void)mouseDown:(NSEvent *)theEvent
{
	_startDragLocation = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if (!_mouseDragged) {
		[self updateSelection:theEvent];
	}
	_mouseDragged = YES;

	NSPoint locationInWindow = [theEvent locationInWindow];

	CGFloat xDiff = locationInWindow.x - _startDragLocation.x;
	CGFloat yDiff = locationInWindow.y - _startDragLocation.y;
	
	_startDragLocation = locationInWindow;
	
	NSArray *selectedSpriteLayers = [self selectedSpriteLayers];
	for (KGCSpriteLayer *spriteLayer in selectedSpriteLayers)
	{
		CGPoint newPosition = [spriteLayer position];
		newPosition.x = round(newPosition.x + xDiff);
		newPosition.y = round(newPosition.y + yDiff);
		
		[spriteLayer setPosition:newPosition];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (!_mouseDragged)
	{
		[self updateSelection:theEvent];
	}
	else
	{
		[self updateThumbnailImage];
	}
	
	_mouseDragged = NO;
}

- (void)updateSelection:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSArray *sublayers = [[self contentLayer] sublayers];
	sublayers = [sublayers sortedArrayWithOptions:0 usingComparator:^ NSComparisonResult(KGCSpriteLayer *spriteLayer1, KGCSpriteLayer *spriteLayer2) {
		return [(KGCSprite *)[spriteLayer1 sceneObject] zOrder] < [(KGCSprite *)[spriteLayer2 sceneObject] zOrder];
	}];
	
	for (KGCSpriteLayer *spriteLayer in sublayers)
	{
		NSRect viewFrame = [spriteLayer frame];
		if (NSPointInRect(location, viewFrame))
		{
			if (!_shiftPressed)
			{
				for (KGCSpriteLayer *otherSpriteLayer in sublayers)
				{
					if (otherSpriteLayer != spriteLayer)
					{
						[otherSpriteLayer setSelected:NO];
					}
				}
			}
		
			[spriteLayer setSelected:YES];
			
			id <KGCSceneViewDelegate> delegate = [self delegate];
			if ([delegate respondsToSelector:@selector(sceneViewSpriteSelectionChanged:)])
			{
				[delegate sceneViewSpriteSelectionChanged:self];
			}
			
			return;
		}
	}
	
	for (KGCSpriteLayer *spriteLayer in sublayers)
	{
		[spriteLayer setSelected:NO];
	}
	
	id <KGCSceneViewDelegate> delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(sceneViewSpriteSelectionChanged:)])
	{
		[delegate sceneViewSpriteSelectionChanged:self];
	}
}

#pragma mark - Keyboard Methods

- (void)keyDown:(NSEvent *)theEvent
{
	if ([theEvent keyCode] == 51)
	{
		KGCImageLayer *contentLayer = [self contentLayer];
		NSArray *sublayers = [contentLayer sublayers];
		BOOL changed = NO;
		for (KGCSpriteLayer *spriteLayer in [sublayers copy])
		{
			if ([spriteLayer isSelected])
			{
				KGCSprite *sprite = (KGCSprite *)[spriteLayer sceneObject];
				[[self scene] removeSprite:sprite];
				[spriteLayer removeFromSuperlayer];
				changed = YES;
			}
		}
		
		if (changed)
		{
			[self updateThumbnailImage];
			
			id <KGCSceneViewDelegate> delegate = [self delegate];
			if ([delegate respondsToSelector:@selector(sceneViewSpriteSelectionChanged:)])
			{
				[delegate sceneViewSpriteSelectionChanged:self];
			}
		}
	}
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	_shiftPressed = ([theEvent modifierFlags] & NSShiftKeyMask) != 0;
}

#pragma mark - Drag an Drop methods

- (BOOL)canBecomeKeyView
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return NSDragOperationEvery;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return NSDragOperationEvery;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pasteBoard = [sender draggingPasteboard];
	NSPoint location = [sender draggingLocation];
	location = [self convertPoint:location fromView:nil];
	
	KGCImageLayer *contentLayer = [self contentLayer];
	
	NSInteger highestZOrder = 0;
	NSArray *filePaths = [pasteBoard propertyListForType:NSFilenamesPboardType];
	if ([filePaths count] > 0)
	{
		for (KGCSpriteLayer *spriteLayer in [contentLayer sublayers])
		{
			KGCSprite *sprite = (KGCSprite *)[spriteLayer sceneObject];
		
			[spriteLayer setSelected:NO];
			
			NSInteger zOrder = [sprite zOrder];
			if (zOrder > highestZOrder)
			{
				highestZOrder = zOrder;
			}
		}
	}
	
	CGFloat xDiff = 0.0;
	CGFloat yDiff = 0.0;
	NSMutableArray *newLayers = [[NSMutableArray alloc] init];
	for (NSString *filePath in filePaths)
	{
		KGCResourceController *resourceController = [[self document] resourceController];
		NSString *resourceName = [resourceController resourceNameForURL:[NSURL fileURLWithPath:filePath] type:KGCResourceInfoTypeImage];
		
		NSMutableDictionary *spriteDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *positionDictionary = @{@"x" : @(location.x + xDiff), @"y" : @(location.y + yDiff)};
		spriteDictionary[@"Position"] = positionDictionary;
		spriteDictionary[@"ImageName"] = resourceName;
		spriteDictionary[@"zOrder"] = @(highestZOrder);
		spriteDictionary[@"_id"] = [[NSUUID UUID] UUIDString];
		spriteDictionary[@"Name"] = [resourceName stringByDeletingPathExtension];
		
		NSMutableArray *spriteNames = [[NSMutableArray alloc] init];
		for (KGCSpriteLayer *spriteLayer in [self spriteLayers])
		{
			KGCSprite *sprite = (KGCSprite *)[spriteLayer sceneObject];
			[spriteNames addObject:[sprite name]];
		}
		
		resourceName = [resourceName stringByDeletingPathExtension];
		resourceName = [KGCHelperMethods uniqueNameWithProposedName:resourceName inArray:spriteNames];
		
		KGCSprite *sprite = [[KGCSprite alloc] initWithDictionary:spriteDictionary document:[[self scene] document]];
		
		KGCSpriteLayer *newSpriteLayer = [KGCSpriteLayer layerWithSceneObject:sprite sceneContentView:self];
		[contentLayer addSublayer:newSpriteLayer];
		[newLayers addObject:newSpriteLayer];
		[[self scene] addSprite:sprite];
		
		xDiff += 20.0;
		yDiff += 20.0;
	}
	
	[self updateThumbnailImage];
	
	[newLayers makeObjectsPerformSelector:@selector(setSelected:) withObject:@(YES)];
	
	id <KGCSceneViewDelegate> delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(sceneViewSpriteSelectionChanged:)])
	{
		[delegate sceneViewSpriteSelectionChanged:self];
	}
}

#pragma mark - Copy Methods

- (IBAction)copy:(id)sender
{
	NSMutableArray *copyDictionaries = [[NSMutableArray alloc] init];
	for (KGCSpriteLayer *spriteLayer in [self selectedSpriteLayers])
	{
		KGCSprite *sprite = (KGCSprite *)[spriteLayer sceneObject];
		[copyDictionaries addObject:[sprite copyDictionary]];
	}
	
	NSDictionary *infoDictionary = @{@"Type": @"KGCSpritePasteBoard", @"SceneIdentifier": [[self scene] identifier], @"CopyDictionaries": copyDictionaries};
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary options:0 error:nil];
	
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard clearContents];
	NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
	[item setData:jsonData forType:@"public.json"];
	[pasteBoard writeObjects:@[item]];
}

- (IBAction)paste:(id)sender
{
	CALayer *contentLayer = [self contentLayer];
	KGCScene *scene = [self scene];

	NSInteger highestZOrder = 0;
	for (KGCSpriteLayer *spriteLayer in [contentLayer sublayers])
	{
		KGCSprite *sprite = (KGCSprite *)[spriteLayer sceneObject];
	
		[spriteLayer setSelected:NO];
		
		NSInteger zOrder = [sprite zOrder];
		if (zOrder > highestZOrder)
		{
			highestZOrder = zOrder;
		}
	}

	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	NSData *data = [pasteBoard dataForType:@"public.json"];
	NSMutableDictionary *infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
	NSString *sceneIdentifier = infoDictionary[@"SceneIdentifier"];
	BOOL sameScene = [[scene identifier] isEqualToString:sceneIdentifier];
	
	NSMutableArray *copyDictionaries = infoDictionary[@"CopyDictionaries"];
	for (NSMutableDictionary *copyDictionary in copyDictionaries)
	{
		KGCSprite *sprite = [[KGCSprite alloc] initWithCopyDictionary:copyDictionary document:[self document]];
		highestZOrder += 1;
		[sprite setZOrder:highestZOrder];
		
		if (sameScene)
		{
			NSPoint spritePosition = [sprite position];
			spritePosition.x += 20.0;
			spritePosition.y -= 20.0;
			[sprite setPosition:spritePosition];
		}
		
		KGCSpriteLayer *newSpriteLayer = [KGCSpriteLayer layerWithSceneObject:sprite sceneContentView:self];
		[contentLayer addSublayer:newSpriteLayer];
		[newSpriteLayer setSelected:YES];
		[[self scene] addSprite:sprite];
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if (aSelector == @selector(copy:))
	{
		return [[self selectedSpriteLayers] count] > 0;
	}
	else if (aSelector == @selector(paste:))
	{
		NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
		NSData *data = [pasteBoard dataForType:@"public.json"];
		return data != nil;
	}
	
	return [super respondsToSelector:aSelector];
}

#pragma mark - Drawing Method

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

	NSRect bounds = [self bounds];

	NSBezierPath *path = [NSBezierPath bezierPathWithRect:bounds];
	NSBezierPath *clipPath = [NSBezierPath bezierPathWithRect:dirtyRect];
	[clipPath addClip];

	[[NSColor darkGrayColor] set];
	[path stroke];
	[[NSColor whiteColor] set];
	[path fill];
}

#pragma mark - Convenient Methods

- (NSArray *)selectedSpriteLayers
{
	NSMutableArray *selectedSpriteLayers = [[NSMutableArray alloc] init];
	
	for (KGCSpriteLayer *spriteLayer in [[self contentLayer] sublayers])
	{
		if ([spriteLayer isSelected])
		{
			[selectedSpriteLayers addObject:spriteLayer];
		}
	}
	
	return selectedSpriteLayers;
}

- (NSImage *)sceneCaptureImage
{
	CALayer *contentLayer = [self contentLayer];
	CGRect contentLayerBounds = [contentLayer bounds];
	
	if (!CGRectEqualToRect(contentLayerBounds, CGRectZero))
	{
		NSArray *sublayers = [contentLayer sublayers];
		for (CALayer *sublayer in sublayers)
		{
			[sublayer setBorderColor:[[NSColor clearColor] CGColor]];
		}

		NSImage *image = [[NSImage alloc] initWithSize:[contentLayer bounds].size];
		[image lockFocus];
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		[contentLayer renderInContext:ctx];
		[image unlockFocus];
		
		for (CALayer *sublayer in sublayers)
		{
			[sublayer setBorderColor:[[NSColor blueColor] CGColor]];
		}
	 
		return image;
	}
	
	return nil;
}

- (void)updateLayerOrder
{
	CALayer *contentLayer = [self contentLayer];
	NSArray *subLayers = [contentLayer sublayers];
	subLayers = [subLayers sortedArrayUsingComparator:^ NSComparisonResult(CALayer *layer1, CALayer *layer2)
	{
		return [layer1 zPosition] > [layer2 zPosition];
	}];
	[contentLayer setSublayers:subLayers];
}

- (void)updateThumbnailImage
{
	NSWindow *window = [self window];
	NSEvent *currentEvent = [window currentEvent];
	if ([currentEvent type] != NSLeftMouseDragged && [window isKeyWindow])
	{
		NSImage *sceneImage = [self sceneCaptureImage];
		
		if (sceneImage)
		{
			[sceneImage setSize:NSMakeSize(160.0, 120.0)];
			[[self scene] setThumbnailImage:sceneImage];
			[[self document] reloadScenes];
		}
	}
}

@end