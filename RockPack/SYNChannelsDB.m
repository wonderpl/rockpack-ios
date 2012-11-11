//
//  SYNChannelsDB.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelsDB.h"

@implementation SYNChannelsDB

// Singleton
+ (id) sharedChannelsDBManager
{
    static dispatch_once_t onceQueue;
    static SYNChannelsDB *channelsDBManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      channelsDBManager = [[self alloc] init];
                  });
    
    return channelsDBManager;
}

- (id) init
{
    if ((self = [super init]))
    {
        // Nasty, but only for demo
        NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"ChannelCover1",
                                   @"title" : @"NIKE",
                                   @"subtitle" : @"TENNIS",
                                   @"packItNumber" : @214,
                                   @"rockItNumber" : @453,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d2 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"ChannelCover2",
                                   @"title" : @"ABERCROMBIE & FITCH",
                                   @"subtitle" : @"LATEST FASHIONS",
                                   @"packItNumber" : @144,
                                   @"rockItNumber" : @273,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d3 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"ChannelCover3",
                                   @"title" : @"STAR WARS",
                                   @"subtitle" : @"THE EMPIRE STRIKES BACK",
                                   @"packItNumber" : @341,
                                   @"rockItNumber" : @886,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d4 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"CarlyRaeJepsen",
                                   @"thumbnail" : @"ChannelCover4",
                                   @"title" : @"TES",
                                   @"subtitle" : @"EDUCATION",
                                   @"packItNumber" : @553,
                                   @"rockItNumber" : @132,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d5 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"HotelTransylvania",
                                   @"thumbnail" : @"ChannelCover5",
                                   @"title" : @"KATY PERRY",
                                   @"subtitle" : @"SONGS",
                                   @"packItNumber" : @987,
                                   @"rockItNumber" : @613,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d6 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"JustinBieber",
                                   @"thumbnail" : @"ChannelCover6",
                                   @"title" : @"JLS",
                                   @"subtitle" : @"SONGS",
                                   @"packItNumber" : @921,
                                   @"rockItNumber" : @277,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d7 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"Madagascar3",
                                   @"thumbnail" : @"ChannelCover7",
                                   @"title" : @"THE HOBBIT",
                                   @"subtitle" : @"AN UNEXPECTED JOURNEY",
                                   @"packItNumber" : @158,
                                   @"rockItNumber" : @323,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d8 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"MonstersUniversity",
                                   @"thumbnail" : @"ChannelCover8",
                                   @"title" : @"HALO 4",
                                   @"subtitle" : @"TRAILERS",
                                   @"packItNumber" : @110,
                                   @"rockItNumber" : @245,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d9 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"NikeFootball",
                                   @"thumbnail" : @"ChannelCover9",
                                   @"title" : @"THE 'X' FACTOR",
                                   @"subtitle" : @"LATEST NEWS",
                                   @"packItNumber" : @883,
                                   @"rockItNumber" : @653,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @FALSE}];
        
        self.thumbnailDetailsArray = @[d1, d2, d3, d4, d5, d6, d7, d8, d9];
    }
    
    return self;
}

@end
