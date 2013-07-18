//
//  NSObject+RSDeallocHandler.h
//
//  Created by Yan Rabovik on 17.01.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

@interface NSObject (RSDeallocHandler)

/**
 *  @param owner If owner is not nil, then handler will be automatically
 *  removed from the receiver and deallocated when the owner object dies
 *  @return uniqie ID that can be used to remove handler
 */
-(NSString *)rs_addDeallocHandler:(dispatch_block_t)handler owner:(id)owner;

/**
 *  @param uid Unique ID of the handler to remove
 */
-(void)rs_removeDeallocHandler:(NSString *)uid;

@end
