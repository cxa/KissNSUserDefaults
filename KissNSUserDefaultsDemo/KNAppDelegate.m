//
//  KNAppDelegate.m
//  KissNSUserDefaults
//
//  Created by Chen Xian'an on 1/1/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import "KNAppDelegate.h"
#import "KNDemoViewController.h"

@implementation KNAppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = [[KNDemoViewController alloc] init];
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
