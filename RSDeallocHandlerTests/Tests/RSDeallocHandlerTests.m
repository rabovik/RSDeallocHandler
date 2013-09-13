#import <SenTestingKit/SenTestingKit.h>
#import "RSTestsLog.h"
#import "NSObject+RSDeallocHandler.h"
#import "NSObject+RSDeallocHandler_Tests.h"

@interface A : NSObject @end
@implementation A @end

@interface B : A @end
@implementation B @end

@interface C : B @end
@implementation C @end

@interface RSDeallocHandlerTests : SenTestCase @end

@implementation RSDeallocHandlerTests

#pragma mark - Setup

+(void)setUp{
    [super setUp];
    id b = [B new];
    [b rs_addDeallocHandler:^{} owner:nil];
    id a = [A new];
    [a rs_addDeallocHandler:^{} owner:nil];
}

-(void)setUp{
    [super setUp];
    [RSTestsLog clear];
}

#pragma mark - Dealloc Handler

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

-(void)testDeallocHandlerIsCalledOnceIfFirstInheritedClassSwizzledAndThenSuperclass{
    @autoreleasepool {
        id obj = [B new];
        [obj rs_addDeallocHandler:^{
            RSTestsLog(@"B");
        } owner:nil];
        obj = nil;
    }
    ASSERT_LOG_IS(@"B");
}

#pragma mark - KVO Auto Unregistering
/*
 We run `p RSDHTestsIncrementKVOLeakCounter()` on `NSKVODeallocateBreak` exception
 to make automatic tests of successfull KVO unregistering.
 */
static NSUInteger KVOLeakCounter = 0;
void RSDHTestsIncrementKVOLeakCounter(){
    ++KVOLeakCounter;
}

-(void)makeKVOLeak{
    id __attribute__((objc_precise_lifetime)) observer = [NSObject new];
    @autoreleasepool {
        id x = [C new];
        [x addObserver:observer forKeyPath:@"test" options:0 context:NULL];
    }
}

-(void)testKVOLeak{
    KVOLeakCounter = 0;
    [self makeKVOLeak];
    STAssertTrue(1 == KVOLeakCounter, @"Tests must be run with NSKVODeallocateBreak breakpoint.");
}

-(void)automaticUnregisterKVOOnDealloc{
    id __attribute__((objc_precise_lifetime)) observer = [NSObject new];
    @autoreleasepool {
        id x = [C new];
        [x addObserver:observer forKeyPath:@"test" options:0 context:NULL];
        __unsafe_unretained id unsafeX = x;
        [x rs_addDeallocHandler:^{
            [unsafeX removeObserver:observer forKeyPath:@"test"];
        } owner:nil];
    }
}

-(void)testNoKVOLeak{
    KVOLeakCounter = 0;
    [self automaticUnregisterKVOOnDealloc];
    STAssertTrue(0 == KVOLeakCounter, @"Automatic KVO unregistering does not work.");
}

@end
