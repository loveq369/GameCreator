//
//	KGCAppDelegate.m
//	GameCreator
//
//	Created by Maarten Foukhar on 14-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCAppDelegate.h"

@interface KGCAppDelegate ()

@property (nonatomic, strong) IBOutlet NSPanel *createDocumentPanel;
@property (nonatomic, weak) IBOutlet NSTextField *widthField;
@property (nonatomic, weak) IBOutlet NSTextField *heightField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *templatePopUpButton;

@end

@implementation KGCAppDelegate

+ (void)initialize
{
	NSDictionary *defaults = @{	@"KGCDocumentWidth":				@(1024.0),
								@"KGCDocumentHeight":				@(768.0),
								@"KGCDocumentTemplate":				@(0),
								@"KGCDocumentEditMode":				@(0),
								@"KGCDocumentInitialPreviewMode":	@(NO)};
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	[[self widthField] setDoubleValue:[standardDefaults doubleForKey:@"KGCDocumentWidth"]];
	[[self heightField] setDoubleValue:[standardDefaults doubleForKey:@"KGCDocumentHeight"]];
	[[self templatePopUpButton] selectItemAtIndex:[standardDefaults integerForKey:@"KGCDocumentTemplate"]];
}

- (IBAction)createNewDocument:(id)sender
{
	[NSApp runModalForWindow:[self createDocumentPanel]];
}

- (IBAction)changeWidth:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setDouble:[sender doubleValue] forKey:@"KGCDocumentWidth"];
}

- (IBAction)changeHeight:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setDouble:[sender doubleValue] forKey:@"KGCDocumentHeight"];
}

- (IBAction)changeTemplate:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[sender integerValue] forKey:@"KGCDocumentTemplate"];
}

- (IBAction)create:(id)sender
{
	[NSApp stopModal];
	[[self createDocumentPanel] orderOut:nil];
	[[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:nil];
}

- (IBAction)cancel:(id)sender
{
	[NSApp stopModal];
	[[self createDocumentPanel] orderOut:nil];
}

@end