//
//	KGCSettingsViewManager.h
//	GameCreator
//
//	Created by Maarten Foukhar on 09-03-15.
//	Copyright (c) 2015 Aliens Area Among Us. All rights reserved.
//

#import <AppKit/AppKit.h>

@class KGCSettingsView;

/** The settings view manager handles the shared objects between action objects (like views) */
@interface KGCSettingsViewManager : NSObject

/** The shared manager
 *	@return Returns the shared manager with creating it if needed
 */
+ (KGCSettingsViewManager *)sharedManager;

/** A settings view
 *	@param The bundle name to use to create or retrieve the action settings view
 *	@return Returns a existing or new view, you're repsonsible for setting it up
 */
- (KGCSettingsView *)viewForBundleName:(NSString *)bundleName;

/** A new settings view
 *	@param The bundle name to create the settings view
 *	@return Returns an new view, you're repsonsible for setting it up
 */
- (KGCSettingsView *)newViewForBundleName:(NSString *)bundleName;

@end