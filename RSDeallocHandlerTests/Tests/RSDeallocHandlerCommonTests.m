#import "RSDeallocHandlerCommonTests.h"

@implementation MyLog

static NSMutableString *_logString = nil;
+(void)log:(NSString *)string{
    if (!_logString) {
        _logString = [NSMutableString new];
    }
    [_logString appendString:string];
    NSLog(@"%@",string);
}
+(void)clear{
    _logString = [NSMutableString new];
}
+(BOOL)is:(NSString *)compareString{
    return [compareString isEqualToString:_logString];
}
+(NSString *)logString{
    return _logString;
}

@end

@implementation RSDeallocHandlerCommonTests

- (void)setUp{
    [super setUp];
    [MyLog clear];
}

- (void)testLog{
    MyLog(@"A");
    MyLog(@"B");
    MyLog(@"C");
    STAssertTrue([[MyLog logString] isEqualToString:@"ABC"], @"%@",[MyLog logString]);
}

-(void)testAssertLogIs{
    MyLog(@"A");
    MyLog(@"C");
    ASSERT_LOG_IS(@"AC");
}

@end
