/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import <Foundation/Foundation.h>

@interface AUXWeakedHashTable : NSObject

- (instancetype)init;

- (void)addObject:(id)object;

- (void)removeAllObjects;

- (void)removeObject:(id)object;

- (BOOL)containsObject:(id)anObject;

- (NSArray *)allObjects;

@end
