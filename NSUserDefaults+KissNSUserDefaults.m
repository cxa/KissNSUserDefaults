//
//  NSUserDefaults+KissNSUserDefaults.m
//  KissNSUserDefaults
//
//  Created by Chen Xian'an on 1/1/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import "NSUserDefaults+KissNSUserDefaults.h"
#import <objc/runtime.h>

NSString * const KissNSUserDefaultsDidChangeNotification = @"KissNSUserDefaultsDidChangeNotification";
NSString * const KissNSUserDefaultsUserInfoKey = @"KissNSUserDefaultsUserInfoKey";
NSString * const KissNSUserDefaultsUserInfoObjectValue = @"KissNSUserDefaultsUserInfoObjectValue";

#define POST_NOTE(key, value) [[NSNotificationCenter defaultCenter] postNotificationName:KissNSUserDefaultsDidChangeNotification object:nil userInfo:@{KissNSUserDefaultsUserInfoKey : key, KissNSUserDefaultsUserInfoObjectValue : value}]

#if defined(__LP64__) && __LP64__
#define NSINTEGER_TYPE @"q"
#else
#define NSINTEGER_TYPE @"i"
#endif

@implementation NSUserDefaults (KissNSUserDefaults)

/**
 Simply declare properties in your NSUserDefaults category's header, and @dynamic them in @implementation. Then run this in your NSUserDefaults category's `+(void)load`.
 */
+ (void)kiss_setup
{
  [self kiss_setupWithCustomKeys:nil];
}

+ (void)kiss_setupWithCustomKeys:(NSDictionary *)propertyKeyPairs
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    @autoreleasepool {
      NSDictionary *getters;
      NSDictionary *types;
      [self kiss_getDynamicProperties:&getters types:&types];
      [getters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSMutableString *mStr = [key mutableCopy];
        [mStr deleteCharactersInRange:NSMakeRange(0, 1)];
        NSString *setMethod = [NSString stringWithFormat:@"set%@", [[key substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
        [mStr insertString:setMethod atIndex:0];
        [mStr appendString:@":"];
        SEL sel = NSSelectorFromString(mStr);
        const char *methodType = [[NSString stringWithFormat:@"v@:%@", types[key]] UTF8String];
        NSString *type = types[key];
        NSString *userDefaultsKey = propertyKeyPairs && propertyKeyPairs[key] ? propertyKeyPairs[key] : key;
        IMP imp = NULL;
        if ([type isEqualToString:@"@"]){
          imp = imp_implementationWithBlock(^void(id sender, id value){
            [sender setObject:value forKey:userDefaultsKey];
            POST_NOTE(userDefaultsKey, value);
          });
        } else if ([type isEqualToString:@"c"]){
          imp = imp_implementationWithBlock(^void(id sender, BOOL value){
            [sender setBool:value forKey:userDefaultsKey];
            // NOTE: @YES != @(YES)
            POST_NOTE(userDefaultsKey, value ? @YES : @NO);
          });
        } else if ([type isEqualToString:@"d"]){
          imp = imp_implementationWithBlock(^void(id sender, double value){
            [sender setDouble:value forKey:userDefaultsKey];
            // NOTE: @YES != @(YES)
            POST_NOTE(userDefaultsKey, value ? @YES : @NO);
          });
        } else if ([type isEqualToString:@"f"]){
          imp = imp_implementationWithBlock(^void(id sender, float value){
            [sender setFloat:value forKey:userDefaultsKey];
            POST_NOTE(userDefaultsKey, @(value));
          });
        } else if ([type isEqualToString:NSINTEGER_TYPE]){
          imp = imp_implementationWithBlock(^void(id sender, NSInteger value){
            [sender setInteger:value forKey:userDefaultsKey];
            POST_NOTE(userDefaultsKey, @(value));
          });
        } else {
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        }
        
        if (imp)
          class_addMethod(self, sel, imp, methodType);
        
        sel = NSSelectorFromString(obj);
        methodType = [[NSString stringWithFormat:@"%@@:", types[key]] UTF8String];
        if ([type isEqualToString:@"@"]){
          imp = imp_implementationWithBlock(^id (id sender){
            return [sender objectForKey:userDefaultsKey];
          });
        } else if ([type isEqualToString:@"c"]){
          imp = imp_implementationWithBlock(^BOOL (id sender){
            return [sender boolForKey:userDefaultsKey];
          });
        } else if ([type isEqualToString:@"d"]){
          imp = imp_implementationWithBlock(^double (id sender){
            return [sender doubleForKey:userDefaultsKey];
          });
        } else if ([type isEqualToString:@"f"]){
          imp = imp_implementationWithBlock(^float (id sender){
            return [sender floatForKey:userDefaultsKey];
          });
        } else if ([type isEqualToString:NSINTEGER_TYPE]){
          imp = imp_implementationWithBlock(^NSInteger (id sender){
            return [sender integerForKey:userDefaultsKey];
          });
        } else {
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        }
        
        class_addMethod(self, sel, imp, methodType);
      }];
      
      [@[UIApplicationWillTerminateNotification, UIApplicationDidEnterBackgroundNotification] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [[NSNotificationCenter defaultCenter] addObserverForName:obj object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note){
          [[self standardUserDefaults] synchronize];
        }];
      }];
    }
  });
}

+ (void)kiss_getDynamicProperties:(NSDictionary **)outGetters
                            types:(NSDictionary **)outTypes
{
  NSMutableArray *properties = [@[] mutableCopy];
  NSMutableDictionary *getters = [@{} mutableCopy];
  NSMutableDictionary *types = [@{} mutableCopy];
  unsigned int outCount, i;
  objc_property_t *classProperties = class_copyPropertyList([self class], &outCount);
  for (i=0; i<outCount; i++){
    objc_property_t property = classProperties[i];
    const char *propName = property_getName(property);
    if (propName){
      const char *attr = property_getAttributes(property);
      if (strstr(attr, "D,")){
        NSString *propertyName = [NSString stringWithUTF8String:propName];
        [properties addObject:propertyName];
      }
      
      NSString *p = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
      char *strptr = NULL;
      if ((strptr = strstr(attr, ",G"))){
        NSString *g = [[NSString stringWithCString:strptr encoding:NSUTF8StringEncoding] substringFromIndex:2];
        getters[p] = g;
      } else {
        getters[p] = p;
      }
      
      types[p] = [[NSString stringWithCString:attr encoding:NSUTF8StringEncoding] substringWithRange:NSMakeRange(1, 1)];
    }
  }
  
  free(classProperties);
  *outGetters = [getters copy];
  *outTypes = [types copy];
}

@end
