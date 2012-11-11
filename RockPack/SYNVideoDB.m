//
//  SYNVideoDB.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoDB.h"

@interface SYNVideoDB ()

@property (nonatomic, strong) NSArray *thumbnailDetailsArray;

@end

@implementation SYNVideoDB

// Singleton
+ (id) sharedVideoDBManager
{
    static dispatch_once_t onceQueue;
    static SYNVideoDB *videoDBManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      videoDBManager = [[self alloc] init];
                  });
    
    return videoDBManager;
}

- (id) init
{
    if ((self = [super init]))
    {
        // Nasty, but only for demo
        NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"Adidas",
                                   @"thumbnail" : @"Adidas",
                                   @"title" : @"ADIDAS | TEAM GB",
                                   @"subtitle" : @"DON'T STOP ME NOW",
                                   @"packItNumber" : @214,
                                   @"rockItNumber" : @453,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
    
        NSMutableDictionary *d2 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"AngryBirds",
                                   @"thumbnail" : @"AngryBirds",
                                   @"title" : @"ANGRY BIRDS: STAR WARS",
                                   @"packItNumber" : @144,
                                   @"rockItNumber" : @273,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d3 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"CallOfDuty",
                                   @"thumbnail" : @"CallOfDuty",
                                   @"title" : @"CALL OF DUTY: BLACK OPS 2",
                                   @"subtitle" : @"TRAILER",
                                   @"packItNumber" : @341,
                                   @"rockItNumber" : @886,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d4 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"CarlyRaeJepsen",
                                   @"thumbnail" : @"CarlyRaeJepsen",
                                   @"title" : @"CARLY RAE JEPSEN",
                                   @"subtitle" : @"CALL ME MAYBE",
                                   @"packItNumber" : @553,
                                   @"rockItNumber" : @132,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d5 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"HotelTransylvania",
                                   @"thumbnail" : @"HotelTransylvania",
                                   @"title" : @"HOTEL TRANSYLVANIA",
                                   @"subtitle" : @"TRAILER",
                                   @"packItNumber" : @987,
                                   @"rockItNumber" : @613,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d6 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"JustinBieber",
                                   @"thumbnail" : @"JustinBieber",
                                   @"title" : @"JUSTIN BEIBER",
                                   @"subtitle" : @"BOYFRIEND",
                                   @"packItNumber" : @921,
                                   @"rockItNumber" : @277,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d7 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"Madagascar3",
                                   @"thumbnail" : @"Madagascar3",
                                   @"title" : @"MADAGASCAR 3: EUROPE'S MOST WANTED",
                                   @"subtitle" : @"TRAILER",
                                   @"packItNumber" : @158,
                                   @"rockItNumber" : @323,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d8 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"MonstersUniversity",
                                   @"thumbnail" : @"MonstersUniversity",
                                   @"title" : @"MONSTERS UNIVERSITY",
                                   @"subtitle" : @"TRAILER",
                                   @"packItNumber" : @110,
                                   @"rockItNumber" : @245,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d9 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"NikeFootball",
                                   @"thumbnail" : @"NikeFootball",
                                   @"title" : @"NIKE FOOTBALL: MERCURIAL VAPOR VIII",
                                   @"subtitle" : @"CRISTIANO RONALDO VS RAFA NADAL",
                                   @"packItNumber" : @883,
                                   @"rockItNumber" : @653,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d10 = [NSMutableDictionary dictionaryWithDictionary:
                                    @{@"videoURL" : @"OneDirection",
                                    @"thumbnail" : @"OneDirection",
                                    @"title" : @"ONE DIRECTION",
                                    @"subtitle" : @"LIVE WHILE WE'RE YOUNG",
                                    @"packItNumber" : @101,
                                    @"rockItNumber" : @121,
                                    @"packIt" : @FALSE,
                                    @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d11 = [NSMutableDictionary dictionaryWithDictionary:
                                    @{@"videoURL" : @"TheDarkKnightRises",
                                    @"thumbnail" : @"TheDarkKnightRises",
                                    @"title" : @"THE DARK KNIGHT RISES",
                                    @"subtitle" : @"TRAILER",
                                    @"packItNumber" : @334,
                                    @"rockItNumber" : @271,
                                    @"packIt" : @TRUE,
                                    @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d12 = [NSMutableDictionary dictionaryWithDictionary:
                                    @{@"videoURL" : @"TheLionKing",
                                    @"thumbnail" : @"TheLionKing",
                                    @"title" : @"THE LION KING",
                                    @"subtitle" : @"MOVIE",
                                    @"packItNumber" : @646,
                                    @"rockItNumber" : @978,
                                    @"packIt" : @FALSE,
                                    @"rockIt" : @FALSE}];
        
        self.thumbnailDetailsArray = @[d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12];
        
    }
    
    return self;
}


// Video URL accessor

- (NSURL *) videoURLForIndex: (int) index
                  withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    NSString *videoURLString = [videoDetails objectForKey: @"videoURL"];
    
    NSURL *videoURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: videoURLString
                                                                              ofType: @"mp4"] isDirectory: NO];
    
    return videoURL;
}

@end
