//
//	KGCResourceController.h
//	GameCreator
//
//	Created by Maarten Foukhar on 15-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGCResourceInfo.h"

@interface KGCResourceController : NSObject

- (instancetype)initWithImageFileWrapper:(NSFileWrapper *)imageFileWrapper audioFileWrapper:(NSFileWrapper *)audioFileWrapper;

- (NSString *)resourceNameForURL:(NSURL *)url type:(KGCResourceInfoType)type;
- (NSString *)resourceNameForFileWrapper:(NSFileWrapper *)fileWrapper type:(KGCResourceInfoType)type;
- (NSString *)resourceNameForData:(NSData *)data md5String:(NSString *)md5String proposedName:(NSString *)proposedName type:(KGCResourceInfoType)type;

- (NSImage *)imageNamed:(NSString *)imageName isTransparent:(BOOL *)isTransparent;
- (NSData *)imageDataForImageName:(NSString *)imageName;
- (NSData *)audioDataForName:(NSString *)audioName;

- (NSString *)md5ForImageName:(NSString *)imageName;
- (NSString *)md5ForAudioName:(NSString *)audioName;

- (void)updateImagesWithImageNames:(NSArray *)imageNames;
- (void)updateAudioWithAudioNames:(NSArray *)audioNames;

- (NSArray *)ignoreFiles;

@end