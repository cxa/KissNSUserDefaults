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
+ (void)kiss_getDynamicProperties:(NSDictionary **)outGetters types:(NSDictionary **)outTypes;

@end
