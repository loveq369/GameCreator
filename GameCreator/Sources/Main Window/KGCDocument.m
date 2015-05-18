//
//	KGCDocument.m
//	GameCreator
//
//	Created by Maarten Foukhar on 14-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDocument.h"
#import "KGCSceneContentView.h"
#import "KGCInspectorController.h"
#import "KGCBasicInspector.h"
#import "KGCDADInspector.h"
#import "KGCHelperMethods.h"
#import "KGCSceneTableCell.h"
#import "KGCResourceController.h"
#import "KGCTableView.h"
#import "KGCScene.h"
#import "KGCGameSet.h"
#import "KGCGame.h"
#import "KGCShadowAnimation.h"
#import "KGCSoundEffectTableCellView.h"

@interface KGCDocument () <KGCTableViewMenuDelegate, KGCBasicTableCellDelegate, KGCDataObjectDelegate>

@property (nonatomic, weak) IBOutlet KGCTableView *sceneTableView;
@property (nonatomic, weak) IBOutlet KGCSceneContentView *sceneView;
@property (nonatomic, weak) IBOutlet KGCInspectorController *inspectorController;

@property (nonatomic, weak) IBOutlet NSPopUpButton *gamesPopUpButton;
@property (nonatomic, weak) IBOutlet NSPanel *gamesManagePanel;
@property (nonatomic, weak) IBOutlet NSTableView *gamesManageTableView;
@property (nonatomic, weak) IBOutlet NSPopUpButton *gameManageFirstScenePopUp;
@property (nonatomic, weak) IBOutlet NSPopUpButton *gameManageFirstGamePopUp;

@property (nonatomic, weak) IBOutlet NSPopUpButton *editModePopUp;
@property (nonatomic, weak) IBOutlet NSButton *previewButton;
@property (nonatomic, weak) IBOutlet NSButton *addSceneButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *addScenePopUpButton;

@property (nonatomic, strong) IBOutlet NSPanel *soundEffectPanel;
@property (nonatomic, weak) IBOutlet NSTableView *soundEffectTableView;

@property (nonatomic) KGCDocumentEditMode editMode;
@property (nonatomic) BOOL previewInitialMode;
@property (nonatomic, strong) KGCGameSet *gameSet;

@end

struct Pixel
{
    unsigned char r, g, b, a;
};

@implementation KGCDocument
{
	NSFileWrapper *_fileWrapper;
	KGCResourceController *_resourceController;
	
	KGCGame *_currentGame;
	
	NSString *_copySceneKey;
	NSMutableArray *_firstScenes;
}

#pragma mark - Initial Methods

- (instancetype)initWithType:(NSString *)typeName error:(NSError **)outError
{
	self = [super initWithType:typeName error:outError];
	
	if (self)
	{
		// Create the main structure
		NSMutableDictionary *folders = [[NSMutableDictionary alloc] init];
		
		NSMutableDictionary *sceneDictionary = [[NSMutableDictionary alloc] init];
		NSFileWrapper *sceneFolder = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:sceneDictionary];
		folders[@"Scenes"] = sceneFolder;
		
		NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
		NSFileWrapper *imageFolder = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:imageDictionary];
		folders[@"Images"] = imageFolder;
		
		NSMutableDictionary *audioDictionary = [[NSMutableDictionary alloc] init];
		NSFileWrapper *audioFolder = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:audioDictionary];
		folders[@"Audio"] = audioFolder;
		
		_fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:folders];
		
		// Create the resource controller
		_resourceController = [[KGCResourceController alloc] initWithImageFileWrapper:imageFolder audioFileWrapper:audioFolder];
		
		// Create the game set with one game
		_gameSet = [KGCGameSet gameSetForDocument:self];
		
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		CGFloat width = [standardUserDefaults doubleForKey:@"KGCDocumentWidth"];
		CGFloat height = [standardUserDefaults doubleForKey:@"KGCDocumentHeight"];
		[_gameSet setScreenSize:NSMakeSize(width, height)];
		
		KGCGame *game = [KGCGame gameWithName:NSLocalizedString(@"Untitled Game", nil) document:self];
		[game setDelegate:self];
		[_gameSet addGame:game];
	}
	
	return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	
	// Setup the table view
	NSTableView *sceneTableView = [self sceneTableView];
	[sceneTableView reloadData];
	[sceneTableView scrollRowToVisible:0];
	[[sceneTableView window] makeFirstResponder:sceneTableView];
	
	[[self sceneView] setContentSize:[[self gameSet] screenSize]];
	
	// Setup the edit and preview mode
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger editMode = [standardUserDefaults integerForKey:@"KGCDocumentEditMode"];
	BOOL previewMode = [standardUserDefaults boolForKey:@"KGCDocumentInitialPreviewMode"];
	[self setEditMode:editMode];
	[self setPreviewInitialMode:previewMode];
	[[self editModePopUp] selectItemAtIndex:editMode];
	
	NSButton *previewButton = [self previewButton];
	[previewButton setEnabled:editMode == 1];
	[previewButton setState:editMode == 1 && previewMode];
	
	// Setup the games
	NSArray *games = [[self gameSet] games];
	_currentGame = games[0];
	
	[self updateGamesPopup];
}

#pragma mark - Main Methods

- (void)reloadScenes
{
	[[self sceneTableView] reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[[self sceneTableView] selectedRow]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (NSArray *)sceneNames
{
	NSMutableArray *sceneNames = [[NSMutableArray alloc] init];
	for (KGCScene *scene in [_currentGame scenes])
	{
		[sceneNames addObject:[scene name]];
	}

	return [NSArray arrayWithArray:sceneNames];
}

- (NSFileWrapper *)mainFileWrapper
{
	return _fileWrapper;
}

- (NSFileWrapper *)sceneFileWrapper
{
	return [_fileWrapper fileWrappers][@"Scenes"];
}

- (NSFileWrapper *)imageFileWrapper
{
	return [_fileWrapper fileWrappers][@"Images"];
}

- (NSFileWrapper *)audioFileWrapper
{
	return [_fileWrapper fileWrappers][@"Audio"];
}

#pragma mark - Interface Actions

- (IBAction)addScene:(id)sender
{
	NSPopUpButton *addScenePopUpButton = [self addScenePopUpButton];
	if (sender == [self addSceneButton])
	{
		[addScenePopUpButton performClick:self];
	}
	else if (sender == addScenePopUpButton)
	{
		NSUInteger type = [addScenePopUpButton indexOfSelectedItem] -1;
		
		NSArray *scenes = [_currentGame scenes];
		NSMutableArray *sceneNames = [[NSMutableArray alloc] init];
		for (KGCScene *scene in scenes)
		{
			[sceneNames addObject:[scene name]];
		}

		NSString *identifier = NSLocalizedString(@"Untitled Scene", nil);
		identifier = [KGCHelperMethods uniqueNameWithProposedName:identifier inArray:sceneNames];
		
		KGCScene *newScene = [KGCScene sceneWithName:identifier templateType:type document:self];
		[_currentGame addScene:newScene];

		NSTableView *sceneTableView = [self sceneTableView];
		[sceneTableView reloadData];
		[sceneTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[sceneNames count]] byExtendingSelection:NO];
		[sceneTableView scrollRowToVisible:[sceneNames count]];
	}
}

- (IBAction)deleteScene:(id)sender
{
	NSUInteger selectedRow = [[self sceneTableView] selectedRow];
	
	if (selectedRow != -1)
	{
		NSArray *scenes = [_currentGame scenes];
		[_currentGame removeScene:scenes[selectedRow]];
		[[self sceneTableView] reloadData];
	}
}

- (IBAction)zoomIn:(id)sender
{
	KGCSceneContentView *sceneView = [self sceneView];
	[sceneView setScale:[sceneView scale] + 0.1 animated:YES];
}

- (IBAction)zoomOut:(id)sender
{
	KGCSceneContentView *sceneView = [self sceneView];
	[sceneView setScale:[sceneView scale] - 0.1 animated:YES];
}

- (IBAction)changeGame:(id)sender
{
	NSPopUpButton *gamesPopUpButton = [self gamesPopUpButton];
	if ([[gamesPopUpButton itemArray] count] == [gamesPopUpButton indexOfSelectedItem] + 1)
	{
		_firstScenes = [[NSMutableArray alloc] init];
		
		KGCGameSet *gameSet = [self gameSet];
		NSString *gameIdentifier = [gameSet firstGameIdentifier];
		NSString *sceneIdentifier = [gameSet firstSceneIdentifier];
		KGCGame *firstGame;
		
		NSInteger gameIndex = 0;
		NSPopUpButton *gameManageFirstGamePopUp = [self gameManageFirstGamePopUp];
		[gameManageFirstGamePopUp removeAllItems];
		for (KGCGame *game in [gameSet games])
		{
			[gameManageFirstGamePopUp addItemWithTitle:[game name]];
			
			if ([[game identifier] isEqualToString:gameIdentifier])
			{
				firstGame = game;
				gameIndex = [[gameSet games] indexOfObject:game];
			}
		}
		
		if (!firstGame)
		{
			firstGame = [gameSet games][0];
		}
		
		[gameManageFirstGamePopUp selectItemAtIndex:gameIndex];
	
		NSInteger sceneIndex = 0;
		NSPopUpButton *gameManageFirstScenePopUp = [self gameManageFirstScenePopUp];
		[gameManageFirstScenePopUp removeAllItems];
		for (KGCScene *scene in [firstGame scenes])
		{
			[gameManageFirstScenePopUp addItemWithTitle:[scene name]];
			
			if ([[scene identifier] isEqualToString:sceneIdentifier])
			{
				sceneIndex = [[firstGame scenes] indexOfObject:scene];
			}
		}
		
		[gameManageFirstScenePopUp selectItemAtIndex:sceneIndex];
	
		[[self windowForSheet] beginSheet:[self gamesManagePanel] completionHandler:^ (NSModalResponse returnCode)
		{
			[self updateGamesPopup];
		
			NSInteger index = [gamesPopUpButton indexOfItemWithTitle:[_currentGame name]];
			if (index == -1)
			{
				index = 0;
			}
			
			[gamesPopUpButton selectItemAtIndex:index];
		}];
	}
	else if (![[gamesPopUpButton title] isEqualToString:NSLocalizedString(@"None", nil)])
	{
		NSInteger index = [gamesPopUpButton indexOfSelectedItem];
		_currentGame = [[self gameSet] games][index];
		[[self sceneTableView] reloadData];
		[self tableViewSelectionDidChange:nil];
	}
}

- (IBAction)closeGameSheet:(id)sender
{
	[[self windowForSheet] endSheet:[self gamesManagePanel]];
}

- (IBAction)addGame:(id)sender
{
	KGCGameSet *gameSet = [self gameSet];
	NSInteger newIndex = [[gameSet games] count];
	
	KGCGame *newGame = [KGCGame gameWithName:NSLocalizedString(@"New Game", nil) document:self];
	[gameSet addGame:newGame];
	
	NSTableView *gamesManageTableView = [self gamesManageTableView];
	[gamesManageTableView reloadData];
	[gamesManageTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:YES];
	[gamesManageTableView editColumn:0 row:newIndex withEvent:nil select:YES];
}

- (IBAction)deleteGame:(id)sender
{
	NSTableView *gamesManageTableView = [self gamesManageTableView];
	NSInteger selectedRow = [gamesManageTableView selectedRow];
	
	if (selectedRow != -1)
	{
		KGCGameSet *gameSet = [self gameSet];
		KGCGame *game = [gameSet games][selectedRow];
		[gameSet removeGame:game];
		[gamesManageTableView reloadData];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)changeFirstScene:(id)sender
{
	NSInteger gameIndex = [[self gameManageFirstGamePopUp] indexOfSelectedItem];
	KGCGameSet *gameSet = [self gameSet];
	NSArray *games = [gameSet games];
	KGCGame *game = games[gameIndex];
	[gameSet setFirstGameIdentifier:[game identifier]];
	
	NSInteger index = [sender indexOfSelectedItem];
	KGCScene *scene = [game scenes][index];
	[gameSet setFirstSceneIdentifier:[scene identifier]];
}

- (IBAction)changeFirstGame:(id)sender
{
	NSInteger gameIndex = [sender indexOfSelectedItem];
	KGCGameSet *gameSet = [self gameSet];
	NSArray *games = [gameSet games];
	[gameSet setFirstGameIdentifier:[games[gameIndex] identifier]];
}

- (IBAction)changeEditMode:(id)sender
{
	NSInteger index = [sender indexOfSelectedItem];
	[self setEditMode:index];
	
	NSButton *previewButton = [self previewButton];
	[previewButton setEnabled:index == 1];
	[previewButton setState:index == 1 && [self previewInitialMode]];
	
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"KGCDocumentEditMode"];
	
	[[self inspectorController] update];
	[[[self sceneView] spriteLayers] makeObjectsPerformSelector:@selector(update)];
}

- (IBAction)changePreviewMode:(id)sender
{
	BOOL previewMode = [sender state];
	[self setPreviewInitialMode:previewMode];
	[[NSUserDefaults standardUserDefaults] setBool:previewMode forKey:@"KGCDocumentInitialPreviewMode"];

	[[[self sceneView] spriteLayers] makeObjectsPerformSelector:@selector(update)];
}

- (IBAction)openSoundEffects:(id)sender
{
	[[self windowForSheet] beginSheet:[self soundEffectPanel] completionHandler:nil];
}

- (IBAction)closeSoundEffects:(id)sender
{
	[[self soundEffectPanel] orderOut:nil];
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if (tableView == [self sceneTableView])
	{
		return [[_currentGame scenes] count];
	}
	else if (tableView == [self gamesManageTableView])
	{
		return [[[self gameSet] games] count];
	}
	else if (tableView == [self soundEffectTableView])
	{
		return [[self soundEffectKeys] count];
	}
	
	return 0;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSView *view;

	if (tableView == [self sceneTableView])
	{
		KGCScene *scene = [_currentGame scenes][row];
		NSArray *names = @[ NSLocalizedString(@"Basic Template", nil),	NSLocalizedString(@"Drag and Drop Template", nil), NSLocalizedString(@"Drag and Drop Shape Template", nil), NSLocalizedString(@"Menu Template", nil)];
		NSString *sceneType = names[[scene templateType]];
		
		KGCSceneTableCell *tableCellView = (KGCSceneTableCell *)[tableView makeViewWithIdentifier:@"TableCell" owner:nil];
		[tableCellView setTableView:tableView];
		[[tableCellView textField] setStringValue:[scene name]];
		[[tableCellView sceneTypeField] setStringValue:sceneType];
		[tableCellView setDelegate:self];
		[tableCellView setRow:row];
		
		NSMutableDictionary *sceneDictionary = [scene dictionary];
		NSImage *image;
		if ([[sceneDictionary allKeys] containsObject:@"ThumbnailImage"])
		{
			NSString *thumbnailImageString = sceneDictionary[@"ThumbnailImage"];
			NSData *data = [[NSData alloc] initWithBase64EncodedString:thumbnailImageString options:0];
			image = [[NSImage alloc] initWithData:data];
		}
		else
		{
			image = [NSImage imageNamed:@"ScreenTemplate"];
		}
		
		[[tableCellView sceneImageView] setImage:image];
		view = tableCellView;
	}
	else if (tableView == [self gamesManageTableView])
	{
		KGCGame *game = [[self gameSet] games][row];
	
		KGCBasicTableCell *tableCellView = (KGCBasicTableCell *)[tableView makeViewWithIdentifier:@"GameNameCell" owner:nil];
		[tableCellView setTableView:tableView];
		[tableCellView setDelegate:self];
		[[tableCellView textField] setStringValue:[game name]];
		view = tableCellView;
	}
	else if (tableView == [self soundEffectTableView])
	{
		KGCGameSet *gameSet = [self gameSet];
		
		KGCSoundEffectTableCellView *tableCellView = (KGCSoundEffectTableCellView *)[tableView makeViewWithIdentifier:@"SoundEffectCell" owner:nil];
		[[tableCellView textField] setStringValue:[self soundEffectTypeNames][row]];
		[tableCellView setupWithGameSet:gameSet soundEffectKey:[self soundEffectKeys][row]];
		view = tableCellView;
	}
	
	return view;
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *sceneTableView = [self sceneTableView];
	if ([notification object] != sceneTableView)
	{
		return;
	}

	NSInteger selectedRow = [sceneTableView selectedRow];
	
	if (selectedRow != -1)
	{
		KGCSceneContentView *sceneView = [self sceneView];
		[sceneView setupWithScene:[_currentGame scenes][selectedRow]];
		[[self inspectorController] setupWithSceneLayer:[sceneView contentLayer]];
	}
	else if (selectedRow == -1)
	{
		[[self sceneView] setupWithScene:nil];
		[[self inspectorController] setupWithSceneLayer:nil];
	}
}

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
	// Support for us being a dragging source
	return nil;
}

#pragma mark - TableView Menu Delegate Methods

- (void)tableView:(KGCTableView *)tableView copy:(id)sender
{
	NSInteger row = [tableView selectedRow];
	
	if (row != -1)
	{
		NSData *jsonData;
		if (tableView == [self sceneTableView])
		{
			KGCScene *scene = [_currentGame scenes][row];
			jsonData = [scene copyData];
		}
		else if (tableView == [self gamesManageTableView])
		{
			KGCGame *game = [[self gameSet] games][row];
			jsonData = [game copyData];
		}
		
		NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
		[pasteBoard clearContents];
		NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
		[item setData:jsonData forType:@"public.json"];
		[pasteBoard writeObjects:@[item]];
	}
}

- (void)tableView:(KGCTableView *)tableView paste:(id)sender
{
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	NSData *data = [pasteBoard dataForType:@"public.json"];
	if (data)
	{
		if (tableView == [self sceneTableView])
		{
			KGCScene *scene = [[KGCScene alloc] initWithCopyData:data document:self];
			
			NSArray *scenes = [_currentGame scenes];
			NSMutableArray *sceneNames = [[NSMutableArray alloc] init];
			for (KGCScene *scene in scenes)
			{
				[sceneNames addObject:[scene name]];
			}

			NSString *identifier = [KGCHelperMethods uniqueNameWithProposedName:[scene name] inArray:sceneNames];
			[scene setName:identifier];
			[_currentGame addScene:scene];
			
			[tableView reloadData];
			[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[sceneNames count]] byExtendingSelection:NO];
			[tableView scrollRowToVisible:[sceneNames count]];
		}
		else if (tableView == [self gamesManageTableView])
		{
			KGCGame *game = [[KGCGame alloc] initWithCopyData:data document:self];
			
			NSArray *games = [[self gameSet] games];
			NSMutableArray *gameNames = [[NSMutableArray alloc] init];
			for (KGCGame *game in games)
			{
				[gameNames addObject:[game name]];
			}

			NSString *identifier = [KGCHelperMethods uniqueNameWithProposedName:[game name] inArray:gameNames];
			[game setName:identifier];
			[[self gameSet] addGame:game];
			
			[tableView reloadData];
			[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[gameNames count]] byExtendingSelection:NO];
			[tableView scrollRowToVisible:[gameNames count]];
		}
	}
}

#pragma mark - DataObject Delegate Methods

- (void)dataObject:(KGCDataObject *)dataObject valueChangedForKey:(NSString *)key visualChange:(BOOL)visualChange
{
	[[self inspectorController] update];
	[self updateChangeCount:NSChangeDone];
}

- (void)dataObject:(KGCDataObject *)dataObject childObject:(KGCDataObject *)childObject valueChangedForKey:(NSString *)key visualChange:(BOOL)visualChange
{
	[[self inspectorController] update];
	[self updateChangeCount:NSChangeDone];
}

#pragma mark - BasicTableCell Delegate Methods

- (void)basicTableCell:(KGCBasicTableCell *)basicTableCell didChangeText:(NSString *)newText
{
	NSTableView *tableView = [basicTableCell tableView];
	NSInteger row = [tableView selectedRow];
	
	if (row == -1)
	{
		return;
	}
	
	if (tableView == [self sceneTableView])
	{
		KGCScene *scene = [_currentGame scenes][row];
		[scene setName:newText];
	}
	else if (tableView == [self gamesManageTableView])
	{
		KGCGame *game = [[self gameSet] games][row];
		[game setName:newText];
	}
}

#pragma mark - SceneView Delegate Methods

- (void)sceneViewSpriteSelectionChanged:(KGCSceneContentView *)sceneView
{
	NSArray *selectedSpriteLayers = [sceneView selectedSpriteLayers];
	KGCInspectorController *inspectorController = [self inspectorController];
	
	if ([selectedSpriteLayers count] > 0)
	{
		[inspectorController setupWithSceneLayer:selectedSpriteLayers[0]];
	}
	else
	{
		[inspectorController setupWithSceneLayer:[[self sceneView] contentLayer]];
	}
}

#pragma mark - Document Methods

+ (BOOL)autosavesInPlace
{
	return YES;
}

- (NSString *)windowNibName
{
	return @"KGCDocument";
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
	[self finalizeGameset];
	return _fileWrapper;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
	_fileWrapper = fileWrapper;
	
	NSDictionary *mainFolderDictionary = [fileWrapper fileWrappers];
	_resourceController = [[KGCResourceController alloc] initWithImageFileWrapper:mainFolderDictionary[@"Images"] audioFileWrapper:mainFolderDictionary[@"Audio"]];
	
	// Create the game set
	NSFileWrapper *gameSetFileWrapper = mainFolderDictionary[@"GameSet.json"];
	NSMutableDictionary	*gameDictionary = [NSJSONSerialization JSONObjectWithData:[gameSetFileWrapper regularFileContents] options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
	
	KGCGameSet *gameSet = [[KGCGameSet alloc] initWithDictionary:gameDictionary document:self];
	[gameSet setDelegate:self];
	[self setGameSet:gameSet];
	
	// Setup the games
	NSPopUpButton *gamesPopUpButton = [self gamesPopUpButton];
	[gamesPopUpButton removeAllItems];
	
	NSArray *games = [gameSet games];
	for (KGCGame *game in games)
	{
		[gamesPopUpButton addItemWithTitle:[game name]];
	}
	
	_currentGame = games[0];
	
	// Update the interface
	[[self sceneView] setContentSize:[gameSet screenSize]];
	
	NSTableView *sceneTableView = [self sceneTableView];
	[sceneTableView reloadData];
	[sceneTableView scrollRowToVisible:0];
	[[sceneTableView window] makeFirstResponder:sceneTableView];

	return YES;
}

//- (void)convertFileWrapper:(NSFileWrapper *)fileWrapper
//{
//	NSDictionary *fileWrappers = [fileWrapper fileWrappers];
//	NSFileWrapper *gameWrapper = fileWrappers[@"Game.json"];
//	NSMutableDictionary *gameDictionary = [NSJSONSerialization JSONObjectWithData:[gameWrapper regularFileContents] options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
//	gameDictionary[@"Name"] = @"Game";
//	NSArray *sceneNames = [gameDictionary[@"Scenes"] copy];
//	[gameDictionary[@"Scenes"] removeAllObjects];
//	
//	NSFileWrapper *sceneFolderFileWrapper = fileWrappers[@"Scenes"];
//	NSDictionary *sceneFileWrappers = [sceneFolderFileWrapper fileWrappers];
//	for (NSString *sceneName in sceneNames)
//	{
//		NSFileWrapper *sceneFileWrapper = sceneFileWrappers[sceneName];
//		NSMutableDictionary *sceneDictionary = [NSJSONSerialization JSONObjectWithData:[sceneFileWrapper regularFileContents] options:NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
//		sceneDictionary[@"TemplateType"] = @(0);
//		
//		NSString *sceneFileName = [sceneDictionary[@"_id"] stringByAppendingPathExtension:@"json"];
//		NSString *oldFileName = [sceneDictionary[@"Name"] stringByAppendingPathExtension:@"json"];
//		if (sceneFileWrappers[oldFileName])
//			[sceneFolderFileWrapper removeFileWrapper:sceneFileWrappers[oldFileName]];
//		NSData *sceneData = [NSJSONSerialization dataWithJSONObject:sceneDictionary options:NSJSONWritingPrettyPrinted error:nil];
//		NSFileWrapper *newSceneWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:sceneData];
//		[newSceneWrapper setPreferredFilename:sceneFileName];
//		[sceneFolderFileWrapper addFileWrapper:newSceneWrapper];
//		
//		[gameDictionary[@"Scenes"] addObject:sceneFileName];
//	}
//	
//	NSString *identifier = gameDictionary[@"_id"];
//	if (!identifier)
//	{
//		gameDictionary[@"_id"] = [[NSUUID UUID] UUIDString];
//		identifier = gameDictionary[@"_id"];
//	}
//	
//	[fileWrapper removeFileWrapper:fileWrappers[@"Game.json"]];
//	NSData *gameData = [NSJSONSerialization dataWithJSONObject:gameDictionary options:NSJSONWritingPrettyPrinted error:nil];
//	NSFileWrapper *newGameWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:gameData];
//	[newGameWrapper setPreferredFilename:[identifier stringByAppendingPathExtension:@"json"]];
//	[fileWrapper addFileWrapper:newGameWrapper];
//	
//	NSMutableDictionary *gameSetDictionary = [[NSMutableDictionary alloc] init];
//	gameSetDictionary[@"_id"] = [[NSUUID UUID] UUIDString];
//	gameSetDictionary[@"Name"] = @"GameSet";
//	gameSetDictionary[@"Games"] = [[NSMutableArray alloc] initWithObjects:[identifier stringByAppendingPathExtension:@"json"], nil];
//	gameSetDictionary[@"ScreenSize"] = @{@"width": @(1024), @"height": @(768)};
//	NSData *gameSetData = [NSJSONSerialization dataWithJSONObject:gameSetDictionary options:NSJSONWritingPrettyPrinted error:nil];
//	NSFileWrapper *gameSetWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:gameSetData];
//	[gameSetWrapper setPreferredFilename:@"GameSet.json"];
//	[fileWrapper addFileWrapper:gameSetWrapper];
//}

#pragma mark - Convenient Methods

- (void)finalizeGameset
{
	KGCGameSet *gameSet = [self gameSet];
	
	NSMutableArray *imageNames = [[NSMutableArray alloc] init];
	NSMutableArray *audioNames = [[NSMutableArray alloc] init];
	
	[gameSet imageNames:imageNames audioNames:audioNames];
	
	for (KGCGame *game in [gameSet games])
	{
		NSMutableArray *images = [[NSMutableArray alloc] init];
		NSMutableArray *audio = [[NSMutableArray alloc] init];
		[game imageNames:images audioNames:audio];
	
		for (KGCScene *scene in [game scenes])
		{
			for (KGCSprite *sprite in [scene sprites])
			{
				NSString *imageName = [sprite imageName];
				
				BOOL shadowAnimation = NO;
				for (KGCAnimation *animation in [sprite animations])
				{
					if ([animation isKindOfClass:[KGCShadowAnimation class]])
					{
						shadowAnimation = YES;
					}
				}
				
				if ([sprite isDraggable] || shadowAnimation)
				{
					NSImage *image = [[self resourceController] imageNamed:imageName];
					
					NSImage *shadowImage = [self shadowImageWithImage:image excludeImage:image blurRadius:2.0];
					NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[shadowImage TIFFRepresentation]];
					NSData *shadowData = [imageRep representationUsingType:NSPNGFileType properties:nil];
					NSFileWrapper *shadowFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:shadowData];
					
					NSImage *largeRadiusShadowImage = [self shadowImageWithImage:image excludeImage:image blurRadius:6.0];
					imageRep = [[NSBitmapImageRep alloc] initWithData:[largeRadiusShadowImage TIFFRepresentation]];
					shadowData = [imageRep representationUsingType:NSPNGFileType properties:nil];
					NSFileWrapper *largeRadiusShadowFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:shadowData];
					
					NSFileWrapper *redOutlineImageFileWrapper;
					
					if ([sprite isAnswerSprite])
					{
						NSImage *redOutlineImage = [self redOutlineImageWithImage:image excludeImage:image outlineSize:2.0];
						imageRep = [[NSBitmapImageRep alloc] initWithData:[redOutlineImage TIFFRepresentation]];
						shadowData = [imageRep representationUsingType:NSPNGFileType properties:nil];
						redOutlineImageFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:shadowData];
					}
					
					NSFileWrapper *imageFileWrapper = [_fileWrapper fileWrappers][@"Images"];
					
					NSString *newImageName = [NSString stringWithFormat:@"%@-shadow.%@", [imageName stringByDeletingPathExtension], [imageName pathExtension]];
					[imageFileWrapper removeFileWrapper:[imageFileWrapper fileWrappers][newImageName]];
					[shadowFileWrapper setPreferredFilename:newImageName];
					[images addObject:newImageName];
					[imageFileWrapper addFileWrapper:shadowFileWrapper];
					if (![imageNames containsObject:newImageName])
					{
						[imageNames addObject:newImageName];
					}
					
					newImageName = [NSString stringWithFormat:@"%@-shadowLargeRadius.%@", [imageName stringByDeletingPathExtension], [imageName pathExtension]];
					[imageFileWrapper removeFileWrapper:[imageFileWrapper fileWrappers][newImageName]];
					[largeRadiusShadowFileWrapper setPreferredFilename:newImageName];
					[images addObject:newImageName];
					[imageFileWrapper addFileWrapper:largeRadiusShadowFileWrapper];
					if (![imageNames containsObject:newImageName])
					{
						[imageNames addObject:newImageName];
					}
					
					if (redOutlineImageFileWrapper)
					{
						newImageName = [NSString stringWithFormat:@"%@-redOutline.%@", [imageName stringByDeletingPathExtension], [imageName pathExtension]];
						[imageFileWrapper removeFileWrapper:[imageFileWrapper fileWrappers][newImageName]];
						[redOutlineImageFileWrapper setPreferredFilename:newImageName];
						[images addObject:newImageName];
						[imageFileWrapper addFileWrapper:redOutlineImageFileWrapper];
						if (![imageNames containsObject:newImageName])
						{
							[imageNames addObject:newImageName];
						}
					}
				}
			}
		}
		
		
		
		[game dictionary][@"Images"] = images;
		[game dictionary][@"Audio"] = audio;
		[game updateDictionary];
	}
	
	[[self resourceController] updateImagesWithImageNames:imageNames];
	[[self resourceController] updateAudioWithAudioNames:audioNames];
	[gameSet updateDictionary];
}

- (NSImage *)redOutlineImageWithImage:(NSImage *)image excludeImage:(NSImage *)excludeImage outlineSize:(CGFloat)blurRadius
{
	NSSize imageSize = [image size];
	imageSize.width /= 2.0;
	imageSize.height /= 2.0;
	NSRect imageDrawRect = NSMakeRect(blurRadius, blurRadius, imageSize.width, imageSize.height);
	NSRect newRect = NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height);
	newRect = NSInsetRect(newRect, - blurRadius, - blurRadius);
	imageSize.width += blurRadius * 2.0;
	imageSize.height += blurRadius * 2.0;
	
	NSImage *newImage = [[NSImage alloc] initWithSize:newRect.size];
	
	for (NSUInteger i = 0; i < 10; i ++)
	{
		[newImage lockFocus];
		
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowColor:[[NSColor redColor] colorWithAlphaComponent:1.0]];
		[shadow setShadowBlurRadius:blurRadius];
		[shadow setShadowOffset:NSMakeSize(0.0, 0.0)];
		[shadow set];
		
		[image drawInRect:imageDrawRect];
		
		[newImage unlockFocus];
	}
	
//	[newImage lockFocus];
//	
//	NSSize originalImageSize = [image size];
//	[excludeImage drawInRect:imageDrawRect fromRect:NSMakeRect(0.0, 0.0, originalImageSize.width, originalImageSize.height) operation:NSCompositeDestinationOut fraction:1.0];
//	
//	[newImage unlockFocus];
	
	return newImage;
}

- (NSImage *)shadowImageWithImage:(NSImage *)image excludeImage:(NSImage *)excludeImage blurRadius:(CGFloat)blurRadius
{
	NSSize imageSize = [image size];
	imageSize.width /= 2.0;
	imageSize.height /= 2.0;
	NSRect imageDrawRect = NSMakeRect(blurRadius, blurRadius, imageSize.width, imageSize.height);
	NSRect newRect = NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height);
	newRect = NSInsetRect(newRect, - blurRadius, - blurRadius);
	imageSize.width += blurRadius * 2.0;
	imageSize.height += blurRadius * 2.0;
	
	NSImage *newImage = [[NSImage alloc] initWithSize:newRect.size];
	[newImage lockFocus];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
	[shadow setShadowBlurRadius:blurRadius];
	[shadow setShadowOffset:NSMakeSize(0.0, 0.0)];
	[shadow set];
	
	[image drawInRect:imageDrawRect];
	
	[newImage unlockFocus];
	
//	[newImage lockFocus];
//	
//	NSSize originalImageSize = [image size];
//	[excludeImage drawInRect:imageDrawRect fromRect:NSMakeRect(0.0, 0.0, originalImageSize.width, originalImageSize.height) operation:NSCompositeDestinationOut fraction:1.0];
//	
//	[newImage unlockFocus];
	
	return newImage;
}

- (NSImage *)opaqueImageFromImage:(NSImage *)image
{
	NSSize imageSize = [image size];

	NSSize newImageSize = NSMakeSize(imageSize.width + 2.0, imageSize.height + 2.0);
	NSImage *newImage = [[NSImage alloc] initWithSize:newImageSize];
	[newImage lockFocus];
	[image drawInRect:NSMakeRect(1.0, 1.0, imageSize.width, imageSize.height)];
	[newImage unlockFocus];
	
	CGImageRef imageRef = [newImage CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
	
	struct Pixel *pixels = (struct Pixel *) calloc(1, newImageSize.width * newImageSize.height * sizeof(struct Pixel));
	CGContextRef context = CGBitmapContextCreate(	(void *)pixels,
													newImageSize.width,
													newImageSize.height,
													8,
													newImageSize.width * 4,
													CGImageGetColorSpace(imageRef),
													(CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                 );
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, newImageSize.width, newImageSize.height), imageRef);
	
	struct Pixel *pixels2 = (struct Pixel *) calloc(1, newImageSize.width * newImageSize.height * sizeof(struct Pixel));
	CGContextRef context2 = CGBitmapContextCreate(	(void *)pixels2,
													newImageSize.width,
													newImageSize.height,
													8,
													newImageSize.width * 4,
													CGImageGetColorSpace(imageRef),
													(CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                 );
	CGContextDrawImage(context2, CGRectMake(0.0, 0.0, newImageSize.width, newImageSize.height), imageRef);
	
	int leftPoint = newImageSize.width;
	int rightPoint = 0;
//	CGPoint **points = malloc(newImageSize.width * (newImageSize.height * sizeof(CGPoint *)));
//	for (int i = 0; i < newImageSize.width; i ++)
//	{
//		CGPoint *subPoints = malloc(newImageSize.height * sizeof(CGPoint));
//		for (int x = 0; x < newImageSize.height; x ++)
//		{
//			subPoints[x] = CGPointMake(-1.0, -1.0);
//		}
//		points[i] = subPoints;
//	}

	CGPoint *points = malloc(newImageSize.width * newImageSize.height * sizeof(CGPoint));
	
	uint numberOfPixels = newImageSize.width * newImageSize.height;
	for (int i = 0; i < numberOfPixels; i++)
	{
		BOOL isLeftPixelTransparent = pixels2[(int)(i - 1)].a == 0;
		BOOL isRightPixelTransparent = ((i < numberOfPixels - 1) && ((CGFloat)i / (newImageSize.width - 1) - (int)((CGFloat)i / (newImageSize.width - 1))) > 0) ? pixels2[(int)(i + 1)].a == 0 : YES;
		BOOL isTopPixelTransparent = i < newImageSize.width ? YES : pixels2[(int)(i - newImageSize.width)].a == 0;
		BOOL isBottomPixelTransparent = i < numberOfPixels - newImageSize.width ? pixels2[(int)(i + newImageSize.width)].a == 0 : YES;
		if (pixels[i].a == 0 && (!isLeftPixelTransparent || !isRightPixelTransparent || !isTopPixelTransparent || !isBottomPixelTransparent))
		{
			pixels[i].r = 255;
			pixels[i].b = 0;
			pixels[i].g = 0;
			pixels[i].a = 255;
			CGFloat x = i - ((int)(i / newImageSize.width) * newImageSize.width);
			CGFloat y = (newImageSize.height - 1) - (int)(i / newImageSize.width);
			
			if (x < leftPoint)
			{
				leftPoint = x;
				rightPoint = y;
			}
			
			//points[(int)x][(int)y] = CGPointMake(x, y);
			points[i] = CGPointMake(x, y);
		}
		else
		{
			points[i] = CGPointMake(-1, -1);
		}
	}
	
//	for (int i = 0; i < pointIndex; i ++)
//	{
//		NSLog(@"Point: %@", NSStringFromPoint(points[i]));
//	}
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(leftPoint, rightPoint)];
	
	CGPoint closestPoint = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
	CGPoint currentPoint = NSMakePoint(leftPoint, rightPoint);
	BOOL firstPoint = YES;
	BOOL foundPoint = YES;
//	NSLog(@"Starting...");
	while (foundPoint)
	{
		CGFloat aXdiff = 0.0;
		CGFloat aYDiff = 0.0;
	
		foundPoint = NO;
		int foundIndex = -1;
		for (int i = 0; i < numberOfPixels; i ++)
		{
			CGPoint point = points[i];
			if (point.x != -1.0 && point.y != -1.0)
			{
				if (firstPoint && point.y <= currentPoint.y)
				{
					continue;
				}
				
				CGFloat xDiff = fabs(currentPoint.x - point.x);
				CGFloat yDiff = fabs(currentPoint.y - point.y);
				
				if ((xDiff <= 6.0 && yDiff <= 6.0))
				{
					CGFloat oldXDiff = fabs(currentPoint.x - closestPoint.x);
					CGFloat oldYDiff = fabs(currentPoint.y - closestPoint.y);
					
					if (xDiff < oldXDiff && yDiff < oldYDiff)
					{
						aXdiff = xDiff;
						aYDiff = yDiff;
					
						closestPoint = point;
						foundIndex = i;
						foundPoint = YES;
					}
				}
			}
		}
		
		if (foundPoint)
		{
			if (foundIndex != -1)
			{
				points[foundIndex] = CGPointMake(- 1.0, - 1.0);
			}
			NSLog(@"Closest point: %@ [%f-%f]", NSStringFromPoint(closestPoint), aXdiff, aYDiff);
			currentPoint = closestPoint;
			[path lineToPoint:closestPoint];
			closestPoint = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
		}
		
		firstPoint = NO;
	}
	
//	CGFloat lastX = 0.0;
//	CGFloat lastY = 0.0;
//	for (int i = leftPoint + 1; i < newImageSize.width - leftPoint; i ++)
//	{
//		CGPoint *rowPoints = points[i];
//		CGFloat highestY = 0.0;
//		CGFloat x = 0.0;
//		for (int z = 0; z < newImageSize.height; z ++)
//		{
//			CGPoint columnPoint = rowPoints[z];
//			if (columnPoint.y > highestY)
//			{
//				highestY = columnPoint.y;
//				x = columnPoint.x;
//			}
//		}
//		
//		[path lineToPoint:NSMakePoint(x, highestY)];
//		lastX = x;
//		lastY = highestY;
//	}
//	
//	for (int i = lastX; i > leftPoint - 1; i --)
//	{
//		CGPoint *rowPoints = points[i];
//		CGFloat lowestY = newImageSize.height - 1;
//		CGFloat x = 0.0;
//		for (int z = 0; z < newImageSize.height; z ++)
//		{
//			CGPoint columnPoint = rowPoints[z];
//			if (columnPoint.y != -1 && columnPoint.y < lowestY)
//			{
//				lowestY = columnPoint.y;
//				x = columnPoint.x;
//			}
//		}
//		
//		[path lineToPoint:NSMakePoint(x, lowestY)];
//	}
	
	[path lineToPoint:NSMakePoint(leftPoint, rightPoint)];
	
	CGImageRef newCGImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGContextRelease(context2);
	
//	for (int i = 0; i < newImageSize.width; i ++)
//	{
//		free(points[i]);
//	}
	free(points);
	
	NSImage *finalImage = [[NSImage alloc] initWithCGImage:newCGImage size:newImageSize];
	CGImageRelease(newCGImage);
	
//	[finalImage lockFocus];
//	[[NSColor redColor] set];
//	[path stroke];
//	[finalImage unlockFocus];
	
	return finalImage;
}

- (void)updateGamesPopup
{
	NSPopUpButton *gamesPopUpButton = [self gamesPopUpButton];
	[gamesPopUpButton removeAllItems];
	
	NSArray *games = [[self gameSet] games];
	for (KGCGame *game in games)
	{
		[gamesPopUpButton addItemWithTitle:[game name]];
	}
	
	[[gamesPopUpButton menu] addItem:[NSMenuItem separatorItem]];
	[gamesPopUpButton addItemWithTitle:NSLocalizedString(@"Edit…", nil)];
}

- (NSArray *)soundEffectKeys
{
	return @[@"DraggableSpriteMouseClickSounds", @"DraggableSpriteMouseDragSounds", @"AchievementSounds"];
}

- (NSArray *)soundEffectTypeNames
{
	return @[NSLocalizedString(@"Draggable Sprite Mouse Click", nil), NSLocalizedString(@"Draggable Sprite Mouse Drag", nil), NSLocalizedString(@"Achievement", nil)];
}

@end