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
@property (nonatomic, copy) NSString *firstGameIdentifier;
@property (nonatomic, copy) NSString *firstSceneIdentifier;

- (NSArray *)scenes;

- (NSArray *)games;
- (void)addGame:(KGCGame *)game;
- (void)insertGame:(KGCGame *)game atIndex:(NSInteger)index;
- (void)removeGame:(KGCGame *)game;

- (void)imageNames:(NSMutableArray *)imageNames audioNames:(NSMutableArray *)audioNames;

@end