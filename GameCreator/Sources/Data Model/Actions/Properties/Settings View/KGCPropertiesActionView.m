//
//	KGCPropertiesActionView.m
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import "KGCPropertiesActionView.h"
#import "KGCPropertiesAction.h"

@interface KGCPropertiesActionView ()

@property (nonatomic, weak) IBOutlet NSButton *draggableCheckBox;

@end

@implementation KGCPropertiesActionView
{
	KGCPropertiesAction *_action;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer withSettingsObject:(id)object
{
	[super setupWithSceneLayer:sceneLayer withSettingsObject:object];
	
	_action = object;
	
	NSDictionary *properties = [_action properties];
	NSArray *allKeys = [properties allKeys];
	
	if ([allKeys containsObject:@"Draggable"])
	{
		[[self draggableCheckBox] setState:[[_action properties][@"Draggable"] integerValue]];
	}
	else
	{
		[[self draggableCheckBox] setState:NSOffState];
	}
}

- (IBAction)setDraggable:(id)sender
{
	[_action properties][@"Draggable"] = @([sender state]);
}

@end