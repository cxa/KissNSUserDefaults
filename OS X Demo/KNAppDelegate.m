//
//  KNAppDelegate.m
//  OS X Demo
//
//  Created by Chen Xian'an on 1/9/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import "KNAppDelegate.h"
#import "NSUserDefaults+KissNSUserDefaults.h"
#import "NSUserDefaults+KissDemo.h"

@implementation KNAppDelegate {
  id _observer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  __weak typeof(self) weakSelf = self;
  _observer = [[NSNotificationCenter defaultCenter] addObserverForName:KissNSUserDefaultsDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note){
    typeof(self) restrongSelf = weakSelf;
    if (!restrongSelf)
      return;
    
    [restrongSelf.textField  setStringValue:[NSString stringWithFormat:NSLocalizedString(@"KissNSUserDefaultsDidChangeNotification user info:\n%@", nil), [[note userInfo] description]]];
  }];
}

- (IBAction)buttonAction:(id)sender
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  switch ([sender tag]){
    case 0:
      ud.kiss_string = @"Bla bla...";
      break;
    case 1:
      ud.integer = 1024;
      break;
    case 2:
      ud.floatValue = 1.024;
      break;
    case 3:
      ud.boolValue = YES;
      break;
    default:
      break;
  }
}

@end
