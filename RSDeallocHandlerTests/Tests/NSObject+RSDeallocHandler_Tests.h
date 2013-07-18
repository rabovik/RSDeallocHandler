#import <Foundation/Foundation.h>

#if DEBUG
@interface NSObject (RSDeallocHandler_Tests)

-(NSUInteger)rs_deallocHandlersCount;

@end
#endif