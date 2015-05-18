//
//	KGCAudioEffectAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCAction.h"

/** An action that plays an audio effect */
@interface KGCAudioEffectAction : KGCAction

/** The audio effect name */
@property (nonatomic, copy) NSString *audioEffectName;

/** Stop other audio effects */
@property (nonatomic, getter = stopsOtherAudioEffects) BOOL stopOtherAudioEffects;

- (void)setSoundAtURL:(NSURL *)url;

@end