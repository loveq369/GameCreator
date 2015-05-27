//
//	KGCResourceInfo.h
//	GameCreator
//
//	Created by Maarten Foukhar on 15-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KGCResourceInfoType)
{
		KGCResourceInfoTypeNone,
		KGCResourceInfoTypeImage,
		KGCResourceInfoTypeAudio,
		KGCResourceInfoTypeAll
};

@interface KGCResourceInfo : NSObject

- (instancetype)initWithName:(NSString *)name type:(KGCResourceInfoType)type resourceFileWrapper:(NSFileWrapper *)resourceFileWrapper;

- (void)prepareForRemoval;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSFileWrapper *fileWrapper;
@property (nonatomic, copy) NSString *md5String;
@property (nonatomic) NSTimeInterval duration; // Only audio (maybe video in the future)
//@property (nonatomic, strong) id content;
@property (nonatomic, readonly) KGCResourceInfoType type;

@end