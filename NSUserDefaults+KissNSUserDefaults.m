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

#define SETTER_IMP(type, setter, userDefaultsKey, boxedValue)  \
imp_implementationWithBlock(^void(id sender, type value){      \
  if (boxedValue){                                             \
    [sender setter:value forKey:userDefaultsKey];         \
  } else {                                                     \
    [sender removeObjectForKey:userDefaultsKey];               \
  }                                                            \
  [[NSNotificationCenter defaultCenter] postNotificationName:KissNSUserDefaultsDidChangeNotification object:nil userInfo:@{KissNSUserDefaultsUserInfoKey : userDefaultsKey, KissNSUserDefaultsUserInfoObjectValue : boxedValue ?: [NSNull null]}] ;\
})

#define GETTER_IMP(type, getter, userDefaultsKey)      \
imp_implementationWithBlock(^type (id sender){         \
return [sender getter:userDefaultsKey];                \
})

#if defined(__LP64__) && __LP64__
#define KISS_NSINTEGER_TYPE @"q"
#else
#define KISS_NSINTEGER_TYPE @"i"
#endif

#if !defined(OBJC_HIDE_64) && TARGET_OS_IPHONE && __LP64__
#define KISS_BOOL_TYPE @"B"
#else
#define KISS_BOOL_TYPE @"c"
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
      NSDictionary *setters;
      NSDictionary *types;
      [self kiss_getDynamicGetters:&getters setters:&setters types:&types];
      for (id key in getters){
        NSString *getterName = getters[key];
        NSString *setterName = setters[key];
        if (!setterName){
          NSMutableString *mStr = [key mutableCopy];
          [mStr deleteCharactersInRange:NSMakeRange(0, 1)];
          NSString *part = [NSString stringWithFormat:@"set%@", [[key substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
          [mStr insertString:part atIndex:0];
          [mStr appendString:@":"];
          setterName = mStr;
        }
        
        NSString *type = types[key];
        NSString *userDefaultsKey = propertyKeyPairs && propertyKeyPairs[key] ? propertyKeyPairs[key] : key;
        IMP imp = NULL;
        if ([type isEqualToString:@"@"])
          imp = SETTER_IMP(id, setObject, userDefaultsKey, value);
        else if ([type isEqualToString:KISS_BOOL_TYPE])
          imp = SETTER_IMP(BOOL, setBool, userDefaultsKey, (value ? @YES : @NO));
        else if ([type isEqualToString:@"d"])
          imp = SETTER_IMP(double, setDouble, userDefaultsKey, @(value));
        else if ([type isEqualToString:@"f"])
          imp = SETTER_IMP(float, setFloat, userDefaultsKey, @(value));
        else if ([type isEqualToString:KISS_NSINTEGER_TYPE])
          imp = SETTER_IMP(NSInteger, setInteger, userDefaultsKey, @(value));
        else
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        
        SEL sel = NSSelectorFromString(setterName);
        const char *methodType = [[NSString stringWithFormat:@"v@:%@", types[key]] UTF8String];
        class_addMethod(self, sel, imp, methodType);
        
        if ([type isEqualToString:@"@"])
          imp = GETTER_IMP(id, objectForKey, userDefaultsKey);
        else if ([type isEqualToString:KISS_BOOL_TYPE])
          imp = GETTER_IMP(BOOL, boolForKey, userDefaultsKey);
        else if ([type isEqualToString:@"d"])
          imp = GETTER_IMP(double, doubleForKey, userDefaultsKey);
        else if ([type isEqualToString:@"f"])
          imp = GETTER_IMP(float, floatForKey, userDefaultsKey);
        else if ([type isEqualToString:KISS_NSINTEGER_TYPE])
          imp = GETTER_IMP(NSInteger, integerForKey, userDefaultsKey);
        else
          @throw [NSException exceptionWithName:@"KissNSUserDefaults" reason:[NSString stringWithFormat:@"type %@ hasn't implemented yet", type] userInfo:nil];
        
        sel = NSSelectorFromString(getterName);
        methodType = [[NSString stringWithFormat:@"%@@:", types[key]] UTF8String];
        class_addMethod(self, sel, imp, methodType);
      }
#if TARGET_OS_IPHONE
#ifdef UIKIT_EXTERN
      NSArray *notes = @[UIApplicationWillTerminateNotification, UIApplicationDidEnterBackgroundNotification];
#define hasNotes
#endif
#else
#ifdef _APPKITDEFINES_H
      NSArray *notes = @[NSApplicationWillTerminateNotification, NSApplicationWillResignActiveNotification];
#define hasNotes
#endif
#endif
#ifdef hasNotes
      [notes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [[NSNotificationCenter defaultCenter] addObserverForName:obj object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note){
          [[self standardUserDefaults] synchronize];
        }];
      }];
#endif
    }
  });
}

+ (NSString *)kiss_getAccessorName:(NSString *)accessor
{
  NSRange r = NSMakeRange(2, [accessor length]-2);
  if ((r = [accessor rangeOfString:@"," options:0 range:r]).location != NSNotFound)
    return [accessor substringWithRange:NSMakeRange(2, r.location-2)];
  
  return [accessor substringFromIndex:2];
}

+ (void)kiss_getDynamicGetters:(NSDictionary **)outGetters
                       setters:(NSDictionary **)outSetters
                         types:(NSDictionary **)outTypes
{
  NSMutableDictionary *getters = [NSMutableDictionary dictionary];
  NSMutableDictionary *setters = [NSMutableDictionary dictionary];
  NSMutableDictionary *types = [NSMutableDictionary dictionary];
  unsigned int outCount, i;
  objc_property_t *classProperties = class_copyPropertyList([self class], &outCount);
  for (i=0; i<outCount; i++){
    objc_property_t property = classProperties[i];
    const char *propChar = property_getName(property);
    if (propChar){
      const char *attr = property_getAttributes(property);
      if (strstr(attr, "D,")){ // only interests in dynamic property
        NSString *propName = [NSString stringWithUTF8String:propChar];
        char *subAttr = NULL;
        if ((subAttr = strstr(attr, ",G"))) // handle custom getter
          getters[propName] = [self kiss_getAccessorName:[NSString stringWithUTF8String:subAttr]];
        else
          getters[propName] = propName;
        
        if ((subAttr = strstr(attr, ",S"))) // handle custom setter
          setters[propName] = [self kiss_getAccessorName:[NSString stringWithUTF8String:subAttr]];
        
        types[propName] = [[NSString stringWithUTF8String:attr] substringWithRange:NSMakeRange(1, 1)];
      }
    }
  }
  
  free(classProperties);
  *outGetters = getters;
  *outSetters = [setters count] ? setters : nil;
  *outTypes = types;
}

@end
