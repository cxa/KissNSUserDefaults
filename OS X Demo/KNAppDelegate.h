//
//  KNAppDelegate.h
//  OS X Demo
//
//  Created by Chen Xian'an on 1/9/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KNAppDelegate : NSObject <NSApplicationDelegate>

@property (unsafe_unretained) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *textField;

- (IBAction)buttonAction:(id)sender;
@end
