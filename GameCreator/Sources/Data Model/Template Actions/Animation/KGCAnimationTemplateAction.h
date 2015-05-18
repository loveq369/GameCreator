//
//	KGCAnimationTemplateAction.h
//	GameCreator
//
//	Created by Maarten Foukhar on 18-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCTemplateAction.h"

@interface KGCAnimationTemplateAction : KGCTemplateAction

@property (nonatomic, weak) NSString *animationKey;
@property (nonatomic, getter = isOrdered) BOOL ordered;

@end