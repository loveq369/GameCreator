//
//	KGCSceneTableCell.m
//	GameCreator
//
//	Created by Maarten Foukhar on 12-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCSceneTableCell.h"
#import "KGCImageView.h"

@interface KGCSceneTableCell ()

@property (nonatomic, weak) IBOutlet KGCImageView *sceneImageView;
@property (nonatomic, weak) IBOutlet NSTextField *sceneTypeField;

@end

@implementation KGCSceneTableCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	CALayer *imageViewLayer = [[self sceneImageView] layer];
	[imageViewLayer setBorderColor:[[NSColor grayColor] CGColor]];
	[imageViewLayer setBorderWidth:1.0];
}

@end