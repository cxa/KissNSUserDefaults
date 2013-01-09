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
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    @autoreleasepool {
      NSDictionary *getters;
      NSDictionary *types;
      [self kiss_getDynamicProperties:&getters types:&types];
      [getters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSMutableString *ms = [key mutableCopy];
        [ms deleteCharactersInRange:NSMakeRange(0, 1)];
        NSString *setMethod = [NSString stringWithFormat:@"set%@", [[key substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
        [ms insertString:setMethod atIndex:0];
        [ms appendString:@":"];
        SEL _sel = NSSelectorFromString(ms);
        const char *_methodType = [[NSString stringWithFormat:@"v@:%@", types[key]] UTF8String];
        IMP _imp = NULL;
        NSString *type = types[key];
        if ([type isEqualToString:@"@"]){
          _imp = imp_implementationWithBlock(^void(id _self, id value){
            [_self setObject:value forKey:key];
            POST_NOTE(key, value);
          });
        } else if ([type isEqualToString:@"c"]){
          _imp = imp_implementationWithBlock(^void(id _self, BOOL value){
            [_self setBool:value forKey:key];
            // NOTE: @YES != @(YES)
            POST_NOTE(key, value ? @YES : @NO);
          });
        } else if ([type isEqualToString:@"d"]){
          _imp = imp_implementationWithBlock(^void(id _self, double value){
            [_self setDouble:value forKey:key];
            // NOTE: @YES != @(YES)
            POST_NOTE(key, value ? @YES : @NO);
          });
        } else if ([type isEqualToString:@"f"]){
          _imp = imp_implementationWithBlock(^void(id _self, float value){
            [_self setFloat:value forKey:key];
            POST_NOTE(key, @(value));
          });
        } else if ([type isEqualToString:NSINTEGER_TYPE]){
          _imp = imp_implementationWithBlock(^void(id _self, NSInteger value){
            [_self setInteger:value forKey:key];
            POST_NOTE(key, @(value));
          });
        } else {
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        }
        
        if (_imp)
          class_addMethod(self, _sel, _imp, _methodType);
        
        _sel = NSSelectorFromString(obj);
        _methodType = [[NSString stringWithFormat:@"%@@:", types[key]] UTF8String];
        if ([type isEqualToString:@"@"]){
          _imp = imp_implementationWithBlock(^id (id _self){
            return [_self objectForKey:key];
          });
        } else if ([type isEqualToString:@"c"]){
          _imp = imp_implementationWithBlock(^BOOL (id _self){
            return [_self boolForKey:key];
          });
        } else if ([type isEqualToString:@"d"]){
          _imp = imp_implementationWithBlock(^double (id _self){
            return [_self doubleForKey:key];
          });
        } else if ([type isEqualToString:@"f"]){
          _imp = imp_implementationWithBlock(^float (id _self){
            return [_self floatForKey:key];
          });
        } else if ([type isEqualToString:NSINTEGER_TYPE]){
          _imp = imp_implementationWithBlock(^NSInteger (id _self){
            return [_self integerForKey:key];
          });
        } else {
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        }
        
        class_addMethod(self, _sel, _imp, _methodType);
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
