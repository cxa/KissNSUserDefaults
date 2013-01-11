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

#define SETTER_IMP(type, setter, userDefaultsKey, boxedValue)     \
imp_implementationWithBlock(^void(id sender, type value){         \
[sender setter:value forKey:userDefaultsKey];                     \
[[NSNotificationCenter defaultCenter] postNotificationName:KissNSUserDefaultsDidChangeNotification object:nil userInfo:@{KissNSUserDefaultsUserInfoKey : userDefaultsKey, KissNSUserDefaultsUserInfoObjectValue : boxedValue}] ; \
})

#define GETTER_IMP(type, getter, userDefaultsKey)      \
imp_implementationWithBlock(^type (id sender){         \
return [sender getter:userDefaultsKey];                \
})

#define POST_NOTE(key, value)

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
      NSDictionary *properties;
      NSDictionary *types;
      [self kiss_getDynamicProperties:&properties types:&types];
      [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSMutableString *mStr = [key mutableCopy];
        [mStr deleteCharactersInRange:NSMakeRange(0, 1)];
        NSString *setMethod = [NSString stringWithFormat:@"set%@", [[key substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
        [mStr insertString:setMethod atIndex:0];
        [mStr appendString:@":"];
        NSString *type = types[key];
        NSString *userDefaultsKey = propertyKeyPairs && propertyKeyPairs[key] ? propertyKeyPairs[key] : key;
        IMP imp = NULL;
        if ([type isEqualToString:@"@"])
          imp = SETTER_IMP(id, setObject, userDefaultsKey, value);
        else if ([type isEqualToString:@"c"])
          imp = SETTER_IMP(BOOL, setBool, userDefaultsKey, (value ? @YES : @NO));
        else if ([type isEqualToString:@"d"])
          imp = SETTER_IMP(double, setDouble, userDefaultsKey, @(value));
        else if ([type isEqualToString:@"f"])
          imp = SETTER_IMP(float, setFloat, userDefaultsKey, @(value));
        else if ([type isEqualToString:NSINTEGER_TYPE])
          imp = SETTER_IMP(NSInteger, setInteger, userDefaultsKey, @(value));
        else
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        
        SEL sel = NSSelectorFromString(mStr);
        const char *methodType = [[NSString stringWithFormat:@"v@:%@", types[key]] UTF8String];
        class_addMethod(self, sel, imp, methodType);
        
        if ([type isEqualToString:@"@"])
          imp = GETTER_IMP(id, objectForKey, userDefaultsKey);
        else if ([type isEqualToString:@"c"])
          imp = GETTER_IMP(BOOL, boolForKey, userDefaultsKey);
        else if ([type isEqualToString:@"d"])
          imp = GETTER_IMP(double, doubleForKey, userDefaultsKey);
        else if ([type isEqualToString:@"f"])
          imp = GETTER_IMP(float, floatForKey, userDefaultsKey);
        else if ([type isEqualToString:NSINTEGER_TYPE])
          imp = GETTER_IMP(NSInteger, integerForKey, userDefaultsKey);
        else
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        
        sel = NSSelectorFromString(obj);
        methodType = [[NSString stringWithFormat:@"%@@:", types[key]] UTF8String];
        class_addMethod(self, sel, imp, methodType);
      }];
#if TARGET_OS_IPHONE
      NSArray *notes = @[UIApplicationWillTerminateNotification, UIApplicationDidEnterBackgroundNotification];
#else
      NSArray *notes = @[NSApplicationWillTerminateNotification, NSApplicationWillResignActiveNotification];
#endif
      [notes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [[NSNotificationCenter defaultCenter] addObserverForName:obj object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note){
          [[self standardUserDefaults] synchronize];
        }];
      }];
    }
  });
}

+ (void)kiss_getDynamicProperties:(NSDictionary **)outProperties
                            types:(NSDictionary **)outTypes
{
  NSMutableDictionary *properties = [@{} mutableCopy];
  NSMutableDictionary *types = [@{} mutableCopy];
  unsigned int outCount, i;
  objc_property_t *classProperties = class_copyPropertyList([self class], &outCount);
  for (i=0; i<outCount; i++){
    objc_property_t property = classProperties[i];
    const char *propChar = property_getName(property);
    if (propChar){
      const char *attr = property_getAttributes(property);
      if (strstr(attr, "D,")){ // only interests in dynamic property
        NSString *propName = [NSString stringWithUTF8String:propChar];
        char *getterPtr = NULL;
        if ((getterPtr = strstr(attr, ",G"))){ // if it is a custom getter
          NSString *getterName = [[NSString stringWithUTF8String:getterPtr] substringFromIndex:2];
          properties[propName] = getterName;
        } else {
          properties[propName] = propName;
        }
        
        types[propName] = [[NSString stringWithUTF8String:attr] substringWithRange:NSMakeRange(1, 1)];
      }
    }
  }
  
  free(classProperties);
  *outProperties = [properties copy];
  *outTypes = [types copy];
}

@end
