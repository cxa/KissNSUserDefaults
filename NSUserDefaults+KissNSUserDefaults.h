//
//  NSUserDefaults+KissNSUserDefaults.h
//  KissNSUserDefaults
//
//  Created by Chen Xian'an on 1/1/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const KissNSUserDefaultsDidChangeNotification;
extern NSString * const KissNSUserDefaultsUserInfoKey;
extern NSString * const KissNSUserDefaultsUserInfoObjectValue;

@interface NSUserDefaults (KissNSUserDefaults)

+ (void)kiss_setup;
/**
 * propertyKeyPairs is a good place for you to transit old keys, or you just need to keep key and property in its own name
 */
+ (void)kiss_setupWithCustomKeys:(NSDictionary *)propertyKeyPairs;
+ (void)kiss_getDynamicProperties:(NSDictionary **)outGetters types:(NSDictionary **)outTypes;

@end
