//
//  SYNChannelByTitleDataProxy.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelByTitleDataProxy.h"

@implementation SYNChannelByTitleDataProxy

-(NSString*)dataType;
{
    return kDataProxyTypeChannel;
}

- (NSArray *) descriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}

@end
