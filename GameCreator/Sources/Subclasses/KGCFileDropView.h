//
//	KGCFileDropView.h
//	GameCreator
//
//	Created by Maarten Foukhar on 07-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KGCFileDropView;

@protocol KGCFileDropViewDelegate <NSObject>

- (void)fileDropView:(KGCFileDropView *)fileDropView droppedFileWithPaths:(NSArray *)filePaths;

@end

@interface KGCFileDropView : NSView

@property (nonatomic, weak) IBOutlet id <KGCFileDropViewDelegate> delegate;

@end