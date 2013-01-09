# KissNSUserDefaults

Keep it simple, stupid!

Directly hard code to access keys of `NSUSerDefaults` is very boring, and painful because `NSUserDefaultsDidChangeNotification` contains no `userInfo`.

Make a `NSUserDefaults` category to access keys via properties is a better way. And it's a bonus if we know which key has been changed.

This is what `KissNSUserDefaults` project borns to be. What you need to do is to delcare properties in header and `@dynamic` all in implementation. Run `+kiss_setup` in `+load` will generate all accessors for you. 

## Usage

Add `NSUserDefaults+KissNSUserDefaults.h` and `NSUserDefaults+KissNSUserDefaults.m` to your project. Make your own `NSUserDefaults` category, import `NSUserDefaults+KissNSUserDefaults.h` and run `+kiss_setup` in your category's `+load`. 

Check `NSUserDefaults+KissDemo.(h|m)` in demo project for details. And you can add an observer for `KissNSUserDefaultsDidChangeNotification` to listen changes.

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

* GitHub: <https://github.com/cxa>
* Twitter: [@_cxa](https://twitter.com/_cxa)
* Apps available in App Store: <http://lazyapps.com>

## License

Under the MIT license. See the LICENSE file for more information.