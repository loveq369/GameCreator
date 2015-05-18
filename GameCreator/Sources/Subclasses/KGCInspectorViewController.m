//
//	KGCInspectorViewController.m
//	GameCreator
//
//	Created by Maarten Foukhar on 22-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCInspectorViewController.h"
#import "KGCSceneLayer.h"
#import "KGCSceneObject.h"

@interface KGCInspectorViewController ()

@property (nonatomic, strong) IBOutlet NSView *view;

@end

@implementation KGCInspectorViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super init];
	
	if (self)
	{
		NSString *nibName = nibNameOrNil;
		if (!nibName)
		{
			nibName = NSStringFromClass([self class]);
		}
	
		NSNib *nib = [[NSNib alloc] initWithNibNamed:nibName bundle:nibBundleOrNil];
		[nib instantiateWithOwner:self topLevelObjects:nil];
	}
	
	return self;
}

- (void)setupWithSceneLayer:(KGCSceneLayer *)sceneLayer
{
	_sceneLayer = sceneLayer;
}

- (KGCSceneObject *)sceneObject
{
	return [[self sceneLayer] sceneObject];
}

- (KGCResourceController *)resourceController
{
	return [[[self sceneObject] document] resourceController];
}

- (void)update {};

@end