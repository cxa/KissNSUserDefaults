# KissNSUserDefaults

Keep it simple, stupid!

Directly hard code to access keys of `NSUserDefaults` is very boring, and painful because `NSUserDefaultsDidChangeNotification` contains no user info.

if we can access keys via properties and listen to the specific `NSUserDefaults` key change, life must be more easier.

This is what `KissNSUserDefaults` project borns to be. What you need to do is to declare properties in header and `@dynamic` all in implementation. Run `+kiss_setup` or `+kiss_setupWithCustomKeys:` in `+load` will generate all accessors for you. 

## Usage

Add `NSUserDefaults+KissNSUserDefaults.h` and `NSUserDefaults+KissNSUserDefaults.m` to your project. Make your own `NSUserDefaults` category, import `NSUserDefaults+KissNSUserDefaults.h` and run `+kiss_setup` in your category's `+load`. If you need to transit old keys, or need to keep key and property in its own name, you can run `+kiss_setupWithCustomKeys:` with your own key-property pairs dictionary. And you can add an observer at somewhere for `KissNSUserDefaultsDidChangeNotification` which contains user info for key and value.

Check demo project for details.

### `NSUserDefaults+KissDemo.h`

    #import "NSUserDefaults+KissNSUserDefaults.h"
    
    extern NSString * const kMyCustomKey;
    
    @interface NSUserDefaults (KissDemo)
    
    @property (nonatomic, strong) NSString *string;
    @property (nonatomic) NSInteger integer;
    @property (nonatomic) float floatValue;
    @property (nonatomic) BOOL boolValue;
    @property (nonatomic) double doubleValue;
    
    @end
	
### `NSUserDefaults+KissDemo.m`

    #import "NSUserDefaults+KissDemo.h"
    
    NSString * const kMyCustomKey = @"im.cxa.myCustomKey";
    
    @implementation NSUserDefaults (KissDemo)
    @dynamic string, integer, floatValue, boolValue, doubleValue;
    
    + (void)load
    {
      // run [self kiss_setup] if you don't need custom keys
      [self kiss_setupWithCustomKeys:@{@"doubleValue" : kMyCustomKey}];
    }
    
    @end
		
## Creator

* GitHub: <https://github.com/cxa>
* Twitter: [@_cxa](https://twitter.com/_cxa)
* Apps available in App Store: <http://lazyapps.com>

## License

Under the MIT license. See the LICENSE file for more information.