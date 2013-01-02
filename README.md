# KissNSUserDefaults

Keep it simple, stupid!

Directly hard code to access keys of `NSUSerDefaults` is very boring, and painful because `NSUserDefaultsDidChangeNotification` contains no `userInfo`.

Make a `NSUserDefaults` category to contain properties is a better way. And it's a bonus if we know which key has changed.

This is what `KissNSUserDefaults` project borns to be. What you need to do is to delcare properties in header and `@dynamic` all in implementation. `-kiss_setup` will generate all accessors for you. Demo tells all.

## Usage

Drag `NSUserDefaults+KissNSUserDefaults.(h|m)` into your project. Make your own `NSUserDefaults` category, import `NSUserDefaults+KissNSUserDefaults.h` and run `-kiss_setup` in your category's `+load`. See `NSUserDefaults+KissDemo.(h|m)` in demo project for details. And you can add an observer for `KissNSUserDefaultsDidChangeNotification` to listen changes.

### `NSUserDefaults+KissDemo.h`

	#import "NSUserDefaults+KissNSUserDefaults.h"

	@interface NSUserDefaults (KissDemo)

	// KissNSUserDefaults currently supports NSObject, NSInteger, float and BOOL types
	@property (nonatomic, strong) NSString *string;
	@property (nonatomic) NSInteger integer;
	@property (nonatomic) CGFloat floatValue;
	@property (nonatomic) BOOL boolValue;

	@end
	
### `NSUserDefaults+KissDemo.m`

	#import "NSUserDefaults+KissDemo.h"

	@implementation NSUserDefaults (KissDemo)
	
	// KissNSUserDefaults will generate all accessors for you
	@dynamic string, integer, floatValue, boolValue;

	+ (void)load
	{
  	  [self kiss_setup];
	}

	@end
	

## License

The BSD 2-Clause License

* * * 

Copyright (c) 2013 CHEN Xian'an <xianan.chen@gmail.com>.  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.