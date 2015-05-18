//
//  KGCGridAnswer.h
//  GameCreator
//
//  Created by Maarten Foukhar on 31-03-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCDataObject.h"

@interface KGCGridAnswer : KGCDataObject

+ (KGCGridAnswer *)gridAnswerWitDocument:(KGCDocument *)document;

@property (nonatomic) NSUInteger row;
@property (nonatomic) NSUInteger column;
@property (nonatomic) BOOL allOtherRowsAndColumns;
@property (nonatomic) NSInteger points;
@property (nonatomic, strong) NSDictionary *targetSpriteDictionary;

@end