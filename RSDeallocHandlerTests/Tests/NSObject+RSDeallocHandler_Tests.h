#import <Foundation/Foundation.h>

#if RS_DEALLOC_HANDLER_TESTS_TARGET
@interface NSObject (RSDeallocHandler_Tests)

-(NSUInteger)rs_deallocHandlersCount;

@end
#endif