//
//	KGCDocument.h
//	GameCreator
//
//	Created by Maarten Foukhar on 14-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGCResourceController.h"

@class KGCGameSet;

typedef NS_ENUM(NSUInteger, KGCDocumentEditMode) {
	KGCDocumentEditModeNormal,
	KGCDocumentEditModeInitial
};

@interface KGCDocument : NSDocument

- (void)reloadScenes;

@property (nonatomic, strong, readonly) KGCResourceController *resourceController;

@property (nonatomic, strong, readonly) KGCGameSet *gameSet;

- (NSArray *)sceneNames;

@property (nonatomic, readonly) KGCDocumentEditMode editMode;
@property (nonatomic, readonly) BOOL previewInitialMode;

- (NSFileWrapper *)mainFileWrapper;
- (NSFileWrapper *)sceneFileWrapper;
- (NSFileWrapper *)imageFileWrapper;
- (NSFileWrapper *)audioFileWrapper;

@end