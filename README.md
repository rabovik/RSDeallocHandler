
# RSDeallocHandler

**RSDeallocHandler** is a simple `NSObject` category for adding and removing block handlers for object's _dealloc_.

## Usage

#### Adding handler
```objective-c
[someObject rs_addDeallocHandler:^{
    NSLog(@"SomeObject deallocated.");
} owner:nil];
```

#### Removing handler
Handlers may be removed using the ID received on adding.
```objective-c
-(void)someMethod{
    _handlerID = [someObject rs_addDeallocHandler:^{} owner:nil];
}
-(void)dealloc{
    [someObject rs_removeDeallocHandler:_handlerID];
}

```

#### Automatic removing
If you specify the `owner` parameter then the handler will be automatically removed from the receiver and deallocated when the _owner_ object dies. So you do not need to manually remove the handler in `dealloc`.
```objective-c
[someObject rs_addDeallocHandler:^{} owner:self];
```

## CocoaPods
Add `RSDeallocHandler` to your _Podfile_.

## Requirements
* iOS 5.0+
* Mac OS X 10.7+
* ARC
* [RSSwizzle][RSSwizzle]

## Author
Yan Rabovik ([@rabovik][twitter] on twitter)

## License
MIT License.

## Changelog
* 1.1.0 Uses `-dealloc` swizzling via [RSSwizzle][RSSwizzle].
* 1.0.0 Uses [Associated Objects][AO].

[twitter]: https://twitter.com/rabovik
[RSSwizzle]: https://github.com/rabovik/RSSwizzle
[AO]: https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html#//apple_ref/doc/uid/TP40001418-CH1g-SW51