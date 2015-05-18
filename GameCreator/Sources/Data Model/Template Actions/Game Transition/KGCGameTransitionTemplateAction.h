//
//	KGCGameTransitionTemplateAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 19-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCTemplateAction.h"

@interface KGCGameTransitionTemplateAction : KGCTemplateAction

@property (nonatomic, copy) NSString *gameIdentifier;
@property (nonatomic, copy) NSString *sceneName;

@end