//
//  NSObject+RSDeallocHandler.h
//
//  Created by Yan Rabovik on 17.01.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

@interface NSObject (RSDeallocHandler)

/// ----------------------------------------
#pragma mark - Adding Handlers
/// @name      Adding Handlers
/// ----------------------------------------

/**
 Adds dealloc handler to the receiver.
 
 @param handler The block object to be executed upon the `-dealloc` method of the receiver.
 @param owner If owner is not nil, then handler will be automatically removed from the receiver and deallocated when the owner object dies.
 @return Uniqie ID that can be used to remove the handler.
 @see -rs_removeDeallocHandler:
 */
-(NSString *)rs_addDeallocHandler:(dispatch_block_t)handler owner:(id)owner;

/// ----------------------------------------
#pragma mark - Removing Handlers
/// @name      Removing Handlers
/// ----------------------------------------

/**
 Removes the dealloc handler from the receiver.
 
 @param uid Unique ID of the handler to be removed.
 @see -rs_addDeallocHandler:owner:
 */
-(void)rs_removeDeallocHandler:(NSString *)uid;

@end
