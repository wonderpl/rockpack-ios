//
//  NSObject+Blocks.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  based on code by Zachary Waldowski on 4/12/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//  https://gist.github.com/955123

#import "NSObject+Blocks.h"

@implementation NSObject (Blocks)

- (void) delayedAddOperation: (NSOperation *) operation
{
    [[NSOperationQueue currentQueue] addOperation: operation];
}



- (void) performBlock: (void (^)(void)) block
           afterDelay: (NSTimeInterval) delay
{
    [self performSelector: @selector(delayedAddOperation:)
               withObject: [NSBlockOperation blockOperationWithBlock: block]
               afterDelay: delay];
}



- (void) performBlock: (void (^)(void)) block
           afterDelay: (NSTimeInterval) delay
cancelPreviousRequest: (BOOL) cancel
{
    if (cancel)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget: self];
    }
    
    [self performBlock: block
            afterDelay: delay];
}

@end
