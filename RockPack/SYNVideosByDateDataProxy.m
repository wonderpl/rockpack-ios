//
//  SYNVideosByDateDataProxy.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideosByDateDataProxy.h"

@implementation SYNVideosByDateDataProxy

-(NSString*)dataType;
{
    return kDataProxyTypeVideos;
}

- (NSArray *) descriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"dateAdded"
                                                                   ascending: NO];
    return @[sortDescriptor];
}

@end
