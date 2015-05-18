//
//	KGCSoundTemplateAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCTemplateAction.h"

@interface KGCSoundTemplateAction : KGCTemplateAction

@property (nonatomic, copy) NSString *soundName;
@property (nonatomic, getter = loops) BOOL loop;
@property (nonatomic) BOOL stopOtherSounds;

- (void)setSoundAtURL:(NSURL *)url;

@end