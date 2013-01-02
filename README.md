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
		
## Creator

[CHEN Xian'an](http://cxa.im) [@_cxa](https://twitter.com)

## License

Under the MIT license. See the LICENSE file for more information.