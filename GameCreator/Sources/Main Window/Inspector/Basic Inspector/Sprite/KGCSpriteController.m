//
//	KGCSpriteController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCSpriteController.h"
#import "KGCFileDropView.h"
#import "KGCSprite.h"

@interface KGCSpriteController () <KGCFileDropViewDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *spriteNameField;
@property (nonatomic, weak) IBOutlet KGCFileDropView *spriteDropField;
@property (nonatomic, weak) IBOutlet NSImageView *spriteIconView;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImageNameLabel;
@property (nonatomic, weak) IBOutlet NSButton *spriteImageClearButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *spriteImageTypePopUp;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionXField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteImagePositionYField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteScaleField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteZOrderField;
@property (nonatomic, weak) IBOutlet NSTextField *spriteOpacityField;
@property (nonatomic, weak) IBOutlet NSSlider *spriteOpacitySlider;
@property (nonatomic, weak) IBOutlet NSButton *spriteDraggableCheckBox;
@property (nonatomic, weak) IBOutlet NSButton *spriteInteractionDisabledCheckBox;

@end

@implementation KGCSpriteController

#pragma mark - Initial Methods

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	[super setupWithSceneLayers:sceneLayers];
	
	NSTextField *spriteNameField = [self spriteNameField];
	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		[spriteNameField setStringValue:[(KGCSprite *)[self sceneObjects][0] name]];
		[spriteNameField setEnabled:YES];
	}
	else
	{
		[spriteNameField setStringValue:NSLocalizedString(@"<Multiple Items Selected>", nil)];
		[spriteNameField setEnabled:NO];
	}
	
	NSInteger lastSpriteImageType = [[NSUserDefaults standardUserDefaults] integerForKey:@"KGCInspectorLastSelectedSpriteImageType"];
	[[self spriteImageTypePopUp] selectItemAtIndex:lastSpriteImageType];
	
	NSString *imageName = [self imageName];
	[[self spriteImageNameLabel] setStringValue:imageName ? imageName : NSLocalizedString(@"None", nil)];
	[[self spriteImageClearButton] setHidden:imageName == nil];
	
	[self updatePosition:nil];
	
	BOOL normalEditMode = [[[self sceneObjects][0] document] editMode] == KGCDocumentEditModeNormal;
	
	NSArray *properties = @[normalEditMode ? @"scale" : @"initialScale", normalEditMode ? @"zOrder" : @"initialZOrder", normalEditMode ? @"alpha" : @"initialAlpha"];
	NSArray *textFields = @[[self spriteScaleField], [self spriteZOrderField], [self spriteOpacityField]];
	for (NSInteger i = 0; i < [properties count]; i ++)
	{
		NSString *propertyName = properties[i];
		NSTextField *textField = textFields[i];
		id object = [self objectForPropertyNamed:propertyName inArray:[self sceneObjects]];
		[self setObjectValue:object inTextField:textField];
	}
	
	if ([self spriteDraggableCheckBox] && [self spriteInteractionDisabledCheckBox])
	{
		properties = @[@"draggable", @"interactionDisabled"];
		NSArray *checkBoxes = @[[self spriteDraggableCheckBox], [self spriteInteractionDisabledCheckBox]];
		for (NSInteger i = 0; i < [properties count]; i ++)
		{
			NSString *propertyName = properties[i];
			NSButton *checkBox = checkBoxes[i];
			id object = [self objectForPropertyNamed:propertyName inArray:[self sceneObjects]];
			[self setObjectValue:object inCheckBox:checkBox];
		}
	}
	
	id object = [self objectForPropertyNamed:@"alpha" inArray:[self sceneObjects]];
	[[self spriteOpacitySlider] setDoubleValue:object ? [object doubleValue] * 100.0 : 0.0];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NSImage *pngIconImage = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
	[[self spriteIconView] setImage:pngIconImage];
	
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self selector:@selector(updatePosition:) name:@"KGCSpritePositionChanged" object:nil];
}

#pragma mark - Interface Methods

- (IBAction)changeSpriteIdentifier:(id)sender
{
	[(KGCSprite *)[self sceneObjects][0] setName:[sender stringValue]];
}

- (IBAction)removeSpriteImage:(id)sender
{
	BOOL normalImage = [[self spriteImageTypePopUp] indexOfSelectedItem] == 0;
	SEL selector = normalImage ? @selector(clearImage) : @selector(clearBackgroundImage);
	[[self sceneObjects] makeObjectsPerformSelector:selector];
	[[self spriteImageNameLabel] setStringValue:NSLocalizedString(@"None", nil)];
	[[self spriteImageClearButton] setHidden:YES];
}

- (IBAction)chooseSpriteImage:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:@[@"png"]];
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^ (NSModalResponse returnCode)
	{
		if (returnCode == NSOKButton)
		{
			[self setImageAtURL:[openPanel URL]];
			
			NSString *imageName = [self imageName];
			[[self spriteImageNameLabel] setStringValue:imageName ? imageName : NSLocalizedString(@"None", nil)];
			[[self spriteImageClearButton] setHidden:imageName == nil];
		}
	}];
}

- (IBAction)changeSpriteImageType:(id)sender
{
	NSUInteger index = [sender indexOfSelectedItem];
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"KGCInspectorLastSelectedSpriteImageType"];
	
	NSString *imageName = [self imageName];
	[[self spriteImageNameLabel] setStringValue:imageName ? imageName : NSLocalizedString(@"None", nil)];
	[[self spriteImageClearButton] setHidden:imageName == nil];
}

- (IBAction)changeSpritePosition:(id)sender
{
	if (sender == [self spriteImagePositionXField])
	{
		[self setPositionX:[sender doubleValue]];
	}
	else if (sender == [self spriteImagePositionYField])
	{
		[self setPositionY:[sender doubleValue]];
	}
}

- (IBAction)changeSpriteScale:(id)sender
{
	BOOL normalEditMode = [[[self sceneObjects][0] document] editMode] == KGCDocumentEditModeNormal;
	[self setObject:[sender objectValue] forPropertyNamed:normalEditMode ? @"scale" : @"initialScale" inArray:[self sceneObjects]];
}

- (IBAction)changeSpriteZOrder:(id)sender
{
	BOOL normalEditMode = [[[self sceneObjects][0] document] editMode] == KGCDocumentEditModeNormal;
	[self setObject:[sender objectValue] forPropertyNamed:normalEditMode ? @"zOrder" : @"initialZOrder" inArray:[self sceneObjects]];
}

- (IBAction)changeSpriteAlpha:(id)sender
{
	CGFloat alpha;
	if (sender == [self spriteOpacitySlider])
	{
		alpha = [[self spriteOpacitySlider] doubleValue];
		[[self spriteOpacityField] setStringValue:[NSString stringWithFormat:@"%.0f", alpha]];
	}
	else
	{
		alpha = [[self spriteOpacityField] doubleValue];
		[[self spriteOpacitySlider] setDoubleValue:alpha];
	}
	
	BOOL normalEditMode = [[[self sceneObjects][0] document] editMode] == KGCDocumentEditModeNormal;
	[self setObject:@(alpha / 100.0) forPropertyNamed:normalEditMode ? @"alpha" : @"initialAlpha" inArray:[self sceneObjects]];
}

- (IBAction)changeMaxLinks:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"maxLinks" inArray:[self sceneObjects]];
}

- (IBAction)changeDraggable:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"draggable" inArray:[self sceneObjects]];
}

- (IBAction)changeInteractionDisable:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"interactionDisabled" inArray:[self sceneObjects]];
}

#pragma mark - File Drop View Delegate Methods

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths
{
	if ([filePaths count] > 0)
	{
		NSURL *url = [[NSURL alloc] initFileURLWithPath:filePaths[0]];
		[self setImageAtURL:url];
		
		NSString *imageName = [self imageName];
		[[self spriteImageNameLabel] setStringValue:imageName ? imageName : NSLocalizedString(@"None", nil)];
	}
}

#pragma mark - Multi getter/setter methods

- (NSString *)imageName
{
	BOOL normalImage = [[self spriteImageTypePopUp] indexOfSelectedItem] == 0;
	NSString *propertyName = normalImage ? @"imageName" : @"backgroundImageName";

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [(KGCSprite *)sceneObjects[0] valueForKey:propertyName];
	}

	NSString *imageName;
	for (KGCSprite *sprite in sceneObjects)
	{
		if (!imageName)
		{
			imageName = [sprite valueForKey:propertyName];
		}
		
		if (![imageName isEqualToString:[sprite valueForKey:propertyName]])
		{
			return nil;
		}
	}
	
	return imageName;
}

- (void)setImageAtURL:(NSURL *)imageURL
{
	BOOL normalImage = [[self spriteImageTypePopUp] indexOfSelectedItem] == 0;
	SEL selector = normalImage ? @selector(setImageAtURL:) : @selector(setBackgroundImageURL:);
	[[self sceneObjects] makeObjectsPerformSelector:selector withObject:imageURL];
}

- (NSPoint)positionGlobalXPosition:(BOOL *)globalXPosition globalYPosition:(BOOL *)globalYPosition
{
	*globalXPosition = YES;
	*globalYPosition = YES;

	BOOL normalEditMode = [[[self sceneObjects][0] document] editMode] == KGCDocumentEditModeNormal;
	NSString *propertyName = normalEditMode ? @"position" : @"initialPosition";

	NSArray *sceneObjects = [self sceneObjects];
	if ([sceneObjects count] == 1)
	{
		return [[(KGCSprite *)sceneObjects[0] valueForKey:propertyName] pointValue];
	}
	
	BOOL firstCheck = YES;
	BOOL wrongX = NO;
	BOOL wrongY = NO;
	NSPoint point = NSZeroPoint;
	for (KGCSprite *sprite in sceneObjects)
	{
		if (firstCheck)
		{
			firstCheck = NO;
			point = [[sprite valueForKey:propertyName] pointValue];
		}
		else
		{
			NSPoint position = [[sprite valueForKey:propertyName] pointValue];
			if (!wrongX && (position.x != point.x))
			{
				wrongX = YES;
				*globalXPosition = NO;
			}
			if (!wrongY && (position.y != point.y))
			{
				wrongY = YES;
				*globalYPosition = NO;
			}
			
			if (wrongX && wrongY)
			{
				return NSZeroPoint;
			}
		}
	}
	
	return point;
}

- (void)setPositionX:(CGFloat)x
{
	BOOL normalEditMode = [[[self sceneObjects][0] document] editMode] == KGCDocumentEditModeNormal;
	NSString *propertyName = normalEditMode ? @"position" : @"initialPosition";

	for (KGCSprite *sprite in [self sceneObjects])
	{
		NSPoint position = [sprite position];
		position.x = x;
		[sprite setValue:[NSValue valueWithPoint:position] forKey:propertyName];
	}
}

- (void)setPositionY:(CGFloat)y
{
	BOOL normalEditMode = [[[self sceneObjects][0] document] editMode] == KGCDocumentEditModeNormal;
	NSString *propertyName = normalEditMode ? @"position" : @"initialPosition";

	for (KGCSprite *sprite in [self sceneObjects])
	{
		NSPoint position = [sprite position];
		position.y = y;
		[sprite setValue:[NSValue valueWithPoint:position] forKey:propertyName];
	}
}

#pragma mark - Convenient Methods

- (void)updatePosition:(NSNotification *)notification
{
	BOOL globalXPosition, globalYPosition;
	NSPoint position = [self positionGlobalXPosition:&globalXPosition globalYPosition:&globalYPosition];
	
	NSTextField *spriteImagePositionXField = [self spriteImagePositionXField];
	if (globalXPosition)
	{
		[spriteImagePositionXField setDoubleValue:position.x];
	}
	else
	{
		[spriteImagePositionXField setStringValue:@"--"];
	}
	
	NSTextField *spriteImagePositionYField = [self spriteImagePositionYField];
	if (globalYPosition)
	{
		[spriteImagePositionYField setDoubleValue:position.y];
	}
	else
	{
		[spriteImagePositionYField setStringValue:@"--"];
	}
}

// Is this needed

/*

- (void)updateVisualProperties
{
	KGCSprite *sprite = [self sprite];
	KGCDocumentEditMode editMode = [[sprite document] editMode];
	BOOL normalMode = (editMode == KGCDocumentEditModeNormal);
	
	CGPoint position = normalMode ? [sprite position] : [sprite initialPosition];
	[[self spriteImagePositionXField] setDoubleValue:position.x];
	[[self spriteImagePositionYField] setDoubleValue:position.y];
	
	[[self spriteScaleField] setDoubleValue:normalMode ? [sprite scale] : [sprite initialScale]];
	[[self spriteZOrderField] setIntegerValue:normalMode ? [sprite zOrder] : [sprite initialZOrder]];
	
	NSWindow *window = [[self view] window];
	NSEvent *currentEvent = [window currentEvent];
	if ([currentEvent type] != NSLeftMouseDragged && [window isKeyWindow])
	{
		CGFloat alpha = (normalMode ? [sprite alpha] : [sprite initialAlpha]) * 100.0;
		[[self spriteOpacityField] setDoubleValue:alpha];
		[[self spriteOpacitySlider] setDoubleValue:alpha];
	}
}

*/

@end