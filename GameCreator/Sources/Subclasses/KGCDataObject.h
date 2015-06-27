//
//	KGCDataObject.h
//	GameCreator
//
//	Created by Maarten Foukhar on 25-03-15.
//	Copyright (c) 2015 Kiwi Fruitware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGCDocument.h"

@class KGCDataObject;

/** A data object delegate gets informed about changes to the dictionary */
@protocol KGCDataObjectDelegate <NSObject>

/** Notify the delegate about a change for specific scene */
- (void)dataObject:(KGCDataObject *)dataObject valueChangedForKey:(NSString *)key visualChange:(BOOL)visualChange;

@optional;

/** Notify the delegate about changes to the data object children */
- (void)dataObject:(KGCDataObject *)dataObject childObject:(KGCDataObject *)childObject valueChangedForKey:(NSString *)key visualChange:(BOOL)visualChange;

@end

/** A data object that manages a mutable dictionary */
@interface KGCDataObject : NSObject

/** Create a new object
 *	@param dictionary The dictionary to create the object with
 *	@param document The document the object belongs to
 *	@return Returns an new object
 */
- (instancetype)initWithDictionary:(NSMutableDictionary *)dictionary document:(KGCDocument *)document;

- (instancetype)initWithCopyDictionary:(NSMutableDictionary *)copyDictionary document:(KGCDocument *)document;
- (instancetype)initWithCopyData:(NSData *)copyData document:(KGCDocument *)document;
- (NSData *)copyData;
- (NSDictionary *)copyDictionary;

/** The associated dictionary */
@property (nonatomic, strong, readonly) NSMutableDictionary *dictionary;

/** The document the object belongs to */
@property (nonatomic, weak, readonly) KGCDocument *document;

/** The data objects identifier */
@property (nonatomic, copy) NSString *identifier;

/** The data objects name */
@property (nonatomic, copy) NSString *name;

/** A parent object */
@property (nonatomic, weak) KGCDataObject *parentObject;

/** A data object delegate gets informed about changes to the dictionary */
@property (nonatomic, weak) id <KGCDataObjectDelegate> delegate;

/** A convenient method to notify the delegate (can be used by subclasses) - only when applicable
 *@param key The key that changed
 */
- (void)notifyDelegateAboutKeyChange:(NSString *)key;
- (void)notifyDelegateAboutKeyChange:(NSString *)key inChildObject:(KGCDataObject *)childObject;

/** Get the visual change keys of a data object
 *	@return Returns an array of string keys
 */
- (NSArray *)visualKeys;

- (void)updateDictionary;

- (void)setObject:(id)object forKey:(NSString *)key;
- (void)setBool:(BOOL)boolValue forKey:(NSString *)key;
- (void)setDouble:(CGFloat)doubleValue forKey:(NSString *)key;
- (void)setInteger:(NSInteger)integer forKey:(NSString *)key;
- (void)setUnsignedInteger:(NSUInteger)unsignedInteger forKey:(NSString *)key;
- (void)setPoint:(NSPoint)point forKey:(NSString *)key;
- (void)setSize:(NSSize)size forKey:(NSString *)key;
- (void)setRect:(NSRect)rect forKey:(NSString *)key;

- (id)objectForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (CGFloat)doubleForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (NSPoint)pointForKey:(NSString *)key;
- (NSSize)sizeForKey:(NSString *)key;
- (NSRect)rectForKey:(NSString *)key;


- (BOOL)hasObjectForKey:(NSString *)key;

- (NSArray *)soundsForKey:(NSString *)key;
- (NSArray *)soundDictionariesForKey:(NSString *)key;
- (void)addSoundAtURL:(NSURL *)soundURL forKey:(NSString *)key;
- (void)removeSoundNamed:(NSString *)hintSoundName forKey:(NSString *)key;
- (void)setSoundAtURL:(NSURL *)soundURL forKey:(NSString *)key;

@end