//
//	KGCBackgroundMusicAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** An action that changes the background music */
@interface KGCBackgroundMusicAction : KGCAction

/** The name of the background music audio */
@property (nonatomic, copy) NSString *audioName;

- (void)setSoundAtURL:(NSURL *)url;

@end