# KissNSUserDefaults

Keep it simple, stupid!

`NSUSerDefaults` is boring and painful because that `NSUserDefaultsDidChangeNotification` contains no `userInfo`.

Directly hard code NSString as key is not a good programming practise. Make a `NSUserDefaults` category to  contain some properties may be a better way. And it's a bonus if we know which key has changed.

This is what `KissNSUserDefaults` project born to be. Demo tells all.