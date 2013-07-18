#import <SenTestingKit/SenTestingKit.h>

@interface MyLog : NSObject
+(void)log:(NSString *)string;
+(void)clear;
+(BOOL)is:(NSString *)compareString;
+(NSString *)logString;
@end

#define ASSERT_LOG_IS(STRING) STAssertTrue([MyLog is:STRING], @"LOG IS @\"%@\" INSTEAD",[MyLog logString])
#define CLEAR_LOG ([MyLog clear])
#define MyLog(STRING) [MyLog log:STRING]

@interface RSDeallocHandlerCommonTests : SenTestCase

@end
