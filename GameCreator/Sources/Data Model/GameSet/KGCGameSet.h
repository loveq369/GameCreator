//
//	KGCGameSet.h
//	GameCreator
//
//	Created by Maarten Foukhar on 29-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDataObject.h"

@class KGCGame;
@class KGCScene;

@interface KGCGameSet : KGCDataObject

+ (KGCGameSet *)gameSetForDocument:(KGCDocument *)document;

@property (nonatomic) NSSize screenSize;

- (NSArray *)scenes;

- (NSArray *)games;
- (void)addGame:(KGCGame *)game;
- (void)removeGame:(KGCGame *)game;

- (void)imageNames:(NSMutableArray *)imageNames audioNames:(NSMutableArray *)audioNames;

@property (nonatomic, copy) NSString *firstGameIdentifier;
@property (nonatomic, copy) NSString *firstSceneIdentifier;
@property (nonatomic, copy) NSString *lastSelectedGameIdentifier;
@property (nonatomic, copy) NSString *lastSelectedSceneIdentifier;

@end