//
//  NSObject+RSDeallocHandler.m
//
//  Created by Yan Rabovik on 17.01.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "NSObject+RSDeallocHandler.h"
#import <objc/runtime.h>

#ifdef RS_DEALLOC_HANDLER_TESTS_TARGET
#import "NSObject+RSDeallocHandler_Tests.h"
#endif

#pragma mark - Helpers -

@interface __RSBlockWrapper : NSObject

-(id)initWithBlock:(dispatch_block_t)block;
-(void)runBlock;

@property (nonatomic,readonly) dispatch_block_t block;
@property (nonatomic,readonly) NSString *uid;

@end

@implementation __RSBlockWrapper{
    NSString *_uid;
}

-(id)initWithBlock:(dispatch_block_t)block{
    self = [super init];
	if (nil == self) return nil;
    
    _uid = nil;
	_block = [block copy];
    
	return self;
}

-(NSString *)uid{
    if (nil == _uid) {
        _uid = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    return _uid;
}

-(void)runBlock{
    if (_block) _block();
}

@end

@interface __RSBlockWrappersArray : NSObject

-(__RSBlockWrapper *)addWrapperWithBlock:(dispatch_block_t)block;
-(void)removeWrapper:(NSString *)uid;
-(void)runAllBlocks;
-(NSUInteger)count;

@end

@implementation __RSBlockWrappersArray{
    NSMutableArray *_wrappers;
}

- (id)init{
	self = [super init];
	if (nil == self) return nil;
    
	_wrappers = [NSMutableArray arrayWithCapacity:1];
    
	return self;
}

-(__RSBlockWrapper *)addWrapperWithBlock:(dispatch_block_t)block{
    __RSBlockWrapper *wrapper = [[__RSBlockWrapper alloc] initWithBlock:block];
    [_wrappers addObject:wrapper];
    return wrapper;
}

-(void)removeWrapper:(NSString *)uid{
    __RSBlockWrapper *wrapperToRemove = nil;
    for (__RSBlockWrapper *blockWrapper in _wrappers) {
        if ([blockWrapper.uid isEqualToString:uid]) {
            wrapperToRemove = blockWrapper;
            break;
        }
    }
    if (wrapperToRemove) [_wrappers removeObject:wrapperToRemove];
}

-(NSUInteger)count{
    return [_wrappers count];
}

-(void)runAllBlocks{
    NSArray *wrappersToRun = nil;
    wrappersToRun = [NSArray arrayWithArray:_wrappers];
    for (__RSBlockWrapper *blockWrapper in wrappersToRun) {
        [blockWrapper runBlock];
    }
}

@end

@interface __RSDeallocHandlers : __RSBlockWrappersArray
@end
@implementation __RSDeallocHandlers
-(void)dealloc{
    [self runAllBlocks];
}
@end

#pragma mark - RSDeallocHandler -

@implementation NSObject (RSDeallocHandler)

static int associatedKey;

-(NSString *)rs_addDeallocHandler:(dispatch_block_t)handler owner:(id)owner{
    @synchronized(self){
        __RSDeallocHandlers *handlers = objc_getAssociatedObject(self, &associatedKey);
        
        if(nil == handlers){
            handlers = [__RSDeallocHandlers new];
            objc_setAssociatedObject(self,
                                     &associatedKey,
                                     handlers,
                                     OBJC_ASSOCIATION_RETAIN);
        }
        
        __RSBlockWrapper *wrapper = [handlers addWrapperWithBlock:handler];
        if (nil != owner) {
            NSString *wrapperUID = wrapper.uid;
            __typeof(self) __weak weakSelf = self;
            id __weak weakOwner = owner;
            
            // If owner deallocs we need to clean self from its handler
            NSString *ownerDeallocUID = [owner rs_addDeallocHandler:^{
                [weakSelf rs_removeDeallocHandler:wrapperUID];
            } owner:nil];
            
            // If wrapper deallocs it means that:
            // - either handler was removed from event;
            // - or self was dealloced.
            // In both cases we need to clean owner from our dealloc handlers
            [wrapper rs_addDeallocHandler:^{
                [weakOwner rs_removeDeallocHandler:ownerDeallocUID];
            } owner:nil];
        }
        
        return wrapper.uid;
    }
}

-(void)rs_removeDeallocHandler:(NSString *)uid{
    @synchronized(self){
        __RSDeallocHandlers *handlers = objc_getAssociatedObject(self, &associatedKey);
        [handlers removeWrapper:uid];
    }
}

@end

#ifdef RS_DEALLOC_HANDLER_TESTS_TARGET
@implementation NSObject (RSDeallocHandler_Tests)

-(NSUInteger)rs_deallocHandlersCount{
    __RSDeallocHandlers *handlers = objc_getAssociatedObject(self, &associatedKey);
    return [handlers count];
}

@end
#endif
