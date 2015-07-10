//
//  KGCNoInteractionSoundInspectorViewController.m
//  GameCreator
//
//  Created by Maarten Foukhar on 07-07-15.
//  Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import "KGCNoInteractionSoundInspectorViewController.h"
#import "KGCSceneObject.h"

@interface KGCNoInteractionSoundInspectorViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *noInteractionDelayField;
@property (nonatomic, strong) IBOutlet NSView *noInteractionSettingsView;

@end

@implementation KGCNoInteractionSoundInspectorViewController
{
	NSNib *_nib;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
	{
		_nib = [[NSNib alloc] initWithNibNamed:@"KGCNoInteractionDelayView" bundle:nil];
		[_nib instantiateWithOwner:self topLevelObjects:nil];
	}
	
	return self;
}

#pragma mark - Interface Actions

- (IBAction)changeNoInteractionDelay:(id)sender
{
	[self setObject:[sender objectValue] forPropertyNamed:@"noInteractionDelay" inArray:[self sceneObjects]];
}

#pragma mark - TableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[super tableViewSelectionDidChange:notification];

	NSString *currentSoundKey = [self currentSoundKey];
	if ([currentSoundKey isEqualToString:@"NoInteractionSounds"])
	{
		NSNumber *noInteractionDelay = [self noInteractionDelay];
		[self setObjectValue:noInteractionDelay inTextField:[self noInteractionDelayField]];
	}
}

#pragma mark - Subclass Methods

- (NSView *)viewForSoundSet:(NSDictionary *)soundSet
{
	if ([soundSet[@"Key"] isEqualToString:@"NoInteractionSounds"])
	{
		return [self noInteractionSettingsView];
	}
	
	return nil;
}

#pragma mark - Convenient Methods

- (void)setCurrentNoInteractionDelay:(NSTimeInterval)delay
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	
	if (selectedRow == -1)
	{
		return;
	}
	
	NSDictionary *soundDictionary = [self sounds][selectedRow];
	for (KGCSceneObject *sceneObject in [self sceneObjects])
	{
		for (NSMutableDictionary *otherSoundDictionary in [sceneObject soundDictionariesForKey:[self currentSoundKey]])
		{
			if ([otherSoundDictionary[@"_id"] isEqualToString:soundDictionary[@"_id"]])
			{
				otherSoundDictionary[@"NoInteractionDelay"] = @(delay);
				[sceneObject updateDictionary];
			}
		}
	}
}

- (NSNumber *)noInteractionDelay
{
	NSInteger selectedRow = [[self soundTableView] selectedRow];
	
	if (selectedRow == -1)
	{
		return @(0);
	}
	
	NSDictionary *soundDictionary = [self sounds][selectedRow];
	NSTimeInterval interactionDelay = 0.0;
	BOOL firstCheck = YES;
	for (KGCSceneObject *sceneObject in [self sceneObjects])
	{
		for (NSMutableDictionary *dictionary in [sceneObject soundDictionariesForKey:[self currentSoundKey]])
		{
			if ([soundDictionary[@"_id"] isEqualToString:dictionary[@"_id"]])
			{
				if (firstCheck)
				{
					firstCheck = NO;
					interactionDelay = [dictionary[@"NoInteractionDelay"] doubleValue];
				}
				else
				{
					NSTimeInterval otherInteractionDelay = [dictionary[@"NoInteractionDelay"] doubleValue];
					if (otherInteractionDelay != interactionDelay)
					{
						return nil;
					}
				}
			}
		}
	}
	
	return @(interactionDelay);
}

@end