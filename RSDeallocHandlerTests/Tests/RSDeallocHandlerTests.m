#import <SenTestingKit/SenTestingKit.h>
#import "RSTestsLog.h"
#import "NSObject+RSDeallocHandler.h"
#import "NSObject+RSDeallocHandler_Tests.h"

@interface RSDeallocHandlerTests : SenTestCase @end

@implementation RSDeallocHandlerTests

-(void)setUp{
    [super setUp];
    [RSTestsLog clear];
}

-(void)testSingleDeallocHandler{
    @autoreleasepool {
        id obj = [NSObject new];
        [obj rs_addDeallocHandler:^{
            RSTestsLog(@"A");
        } owner:nil];
        obj = nil;
    }
    ASSERT_LOG_IS(@"A");
}

-(void)testMultipleDeallocHandlers{
    @autoreleasepool {
        id obj = [NSObject new];
        [obj rs_addDeallocHandler:^{
            RSTestsLog(@"A");
        } owner:nil];
        [obj rs_addDeallocHandler:^{
            RSTestsLog(@"B");
        } owner:nil];
        obj = nil;
    }
    ASSERT_LOG_IS(@"AB");
}

-(void)testRemoveDeallocHandler{
    @autoreleasepool {
        id obj = [NSObject new];
        NSString *uidA = [obj rs_addDeallocHandler:^{
            RSTestsLog(@"A");
        } owner:nil];
        [obj rs_addDeallocHandler:^{
            RSTestsLog(@"B");
        } owner:nil];
        [obj rs_removeDeallocHandler:uidA];
        obj = nil;
    }
    ASSERT_LOG_IS(@"B");
}

-(void)testHandlerDiesAfterOwnersDealloc{
    @autoreleasepool {
        id target = [NSObject new];
        @autoreleasepool {
            id owner = [NSObject new];
            [target rs_addDeallocHandler:^{
                RSTestsLog(@"A");
            } owner:owner];
            STAssertTrue(1 == [target rs_deallocHandlersCount], @"");
            owner = nil;
        }
        STAssertTrue(0 == [target rs_deallocHandlersCount], @"");
        target = nil;
    }
    ASSERT_LOG_IS(@"");
}

-(void)testOwnerIsCleanedUpWhenTargetDies{
    id owner = [NSObject new];
    @autoreleasepool {
        id target = [NSObject new];
        [target rs_addDeallocHandler:^{
            RSTestsLog(@"A");
        } owner:owner];
        STAssertTrue(1 == [owner rs_deallocHandlersCount], @"");
        target = nil;
    }
    STAssertTrue(0 == [owner rs_deallocHandlersCount], @"");
    ASSERT_LOG_IS(@"A");
}

-(void)testOwnerAndTargetCleanedUpAfterRemovingHandler{
    @autoreleasepool {
        id owner = [NSObject new];
        id target = [NSObject new];
        @autoreleasepool {
            NSString *uid = [target rs_addDeallocHandler:^{
                RSTestsLog(@"A");
            } owner:owner];
            [target rs_removeDeallocHandler:uid];
        }
        STAssertTrue(0 == [owner rs_deallocHandlersCount], @"");
        STAssertTrue(0 == [target rs_deallocHandlersCount], @"");
    }
    ASSERT_LOG_IS(@"");
}

@end
