//
//	KGCGame.h
//	GameCreator
//
//	Created by Maarten Foukhar on 26-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDataObject.h"

@class KGCScene;

@interface KGCGame : KGCDataObject

+ (KGCGame *)gameWithName:(NSString *)name document:(KGCDocument *)document;

- (NSArray *)scenes;
- (void)addScene:(KGCScene *)scene;
- (void)removeScene:(KGCScene *)scene;
- (void)insertScene:(KGCScene *)scene atIndex:(NSInteger)index;

- (void)imageNames:(NSMutableArray *)imageNames audioNames:(NSMutableArray *)audioNames sceneImageDictionary:(NSMutableDictionary *)sceneImageDictionary;

@end