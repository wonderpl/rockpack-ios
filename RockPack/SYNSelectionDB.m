//
//  SYNSelectionDB.m
//  rockpack
//
//  Created by Nick Banks on 21/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNSelectionDB.h"

@implementation SYNSelectionDB

// Singleton
+ (id) sharedSelectionDBManager
{
    static dispatch_once_t onceQueue;
    static SYNSelectionDB *selectionDBManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      selectionDBManager = [[self alloc] init];
                  });
    
    return selectionDBManager;
}

@end
