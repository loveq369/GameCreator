//
//	KGCSceneTableCell.h
//	GameCreator
//
//	Created by Maarten Foukhar on 12-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KGCImageView.h"
#import "KGCBasicTableCell.h"

@interface KGCSceneTableCell : KGCBasicTableCell

@property (nonatomic, weak, readonly) KGCImageView *sceneImageView;
@property (nonatomic, weak, readonly) NSTextField *sceneTypeField;

@end