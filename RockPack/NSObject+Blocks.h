//
//  NSObject+Blocks.h
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//
//  based on code by Zachary Waldowski on 4/12/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSObject (Blocks)

+ (id) performBlock: (void (^)(void)) block
         afterDelay: (NSTimeInterval) delay;

+ (id) performBlock: (void (^)(id arg))block
         withObject: (id) anObject
         afterDelay: (NSTimeInterval) delay;

- (id) performBlock: (void (^)(void)) block
         afterDelay: (NSTimeInterval) delay;

- (id) performBlock: (void (^)(id arg))block withObject: (id) anObject
         afterDelay: (NSTimeInterval) delay;

+ (void) cancelBlock: (id) block;

@end
