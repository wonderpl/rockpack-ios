//
//  SYNVideoSelection.m
//  rockpack
//
//  Created by Nick Banks on 18/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoSelection.h"

@interface SYNVideoSelection ()

@property (nonatomic, strong) NSMutableArray *videoSelectionArray;

@end


@implementation SYNVideoSelection

// Singleton
+ (NSMutableArray *) sharedVideoSelectionArray
{
    static dispatch_once_t onceQueue;
    static SYNVideoSelection *sharedVideoSelectionManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      sharedVideoSelectionManager = [[self alloc] init];
                  });
    
    return sharedVideoSelectionManager.videoSelectionArray;
}


- (id) init
{
    if ((self = [super init]))
    {
        self.videoSelectionArray = [[NSMutableArray alloc] initWithCapacity: 100];
    }
    
    return self;
}

@end
