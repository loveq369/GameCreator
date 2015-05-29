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

- (void)setupWithSceneLayers:(NSArray *)sceneLayers
{
	_sceneLayers = sceneLayers;
	
	NSMutableArray *sceneObjects = [[NSMutableArray alloc] init];
	for (KGCSceneLayer *sceneLayer in [self sceneLayers])
	{
		[sceneObjects addObject:[sceneLayer sceneObject]];
	}
	_sceneObjects = [NSArray arrayWithArray:sceneObjects];
}

- (KGCResourceController *)resourceController
{
	return [[[self sceneObjects][0] document] resourceController];
}

- (void)update {};

- (void)setObject:(id)object forPropertyNamed:(NSString *)propertyName inArray:(NSArray *)objects
{
	for (id propertyObject in objects)
	{
		[propertyObject setValue:object forKey:propertyName];
	}
}

- (id)objectForPropertyNamed:(NSString *)propertyName inArray:(NSArray *)objects
{
	if ([objects count] == 1)
	{
		return [objects[0] valueForKey:propertyName];
	}
	
	id returnObject;
	for (id object in objects)
	{
		if (!returnObject)
		{
			returnObject = [object valueForKey:propertyName];
		}
		else
		{
			if (![returnObject isEqualTo:[object valueForKey:propertyName]])
			{
				return nil;
			}
		}
	}
	
	return returnObject;
}

- (void)setObjectValue:(id)objectValue inTextField:(NSTextField *)textField
{
	if (objectValue)
	{
		[textField setObjectValue:objectValue];
	}
	else
	{
		[textField setStringValue:@"--"];
	}
}

- (void)setObjectValue:(id)objectValue inCheckBox:(NSButton *)checkBox
{
	if (objectValue)
	{
		[checkBox setState:[objectValue integerValue]];
	}
	else
	{
		[checkBox setState:NSMixedState];
	}
}

@end