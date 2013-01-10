//
//  KNAppDelegate.m
//  KissNSUserDefaults
//
//  Created by Chen Xian'an on 1/1/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import "KNAppDelegate.h"
#import "NSUserDefaults+KissDemo.h"
#import "KNDemoViewController.h"

@implementation KNAppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [[NSUserDefaults standardUserDefaults] setDouble:10.24 forKey:kMyCustomKey];
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = [[KNDemoViewController alloc] init];
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
