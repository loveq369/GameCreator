//
//	KGCHelperMethods.h
//	GameCreator
//
//	Created by Maarten Foukhar on 04-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KGCHelperMethods : NSObject

+ (NSString *)uniqueNameWithProposedName:(NSString *)proposedName atPath:(NSString *)path;
+ (NSString *)uniqueNameWithProposedName:(NSString *)proposedName inDictionary:(NSDictionary *)dictionary;
+ (NSString *)uniqueNameWithProposedName:(NSString *)proposedName inArray:(NSArray *)array;

+ (void)getMediaFromDictionary:(NSDictionary *)dictionary soundNames:(NSMutableArray *)soundNames imageNames:(NSMutableArray *)imageNames;
+ (void)updateUUIDsInDictionary:(NSMutableDictionary *)dictionary imageMappings:(NSDictionary *)imageMappings audioMappings:(NSDictionary *)audioMappings;

@end