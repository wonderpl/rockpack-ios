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
                                   @"wallpaper" : @"ChannelWallpaper1",
                                   @"title" : @"NIKE SUPERSTARS",
                                   @"subtitle" : @"JUST DO IT",
                                   @"biog" : @"Nike has sponsored more superstars than you’ve had hot dinners. Wayne Rooney, Kobe Bryant, Maria Sharapova, Cristiano Ronaldo, Rafael Nadal, Victoria Azarenka, Roger Federer, Tiger Woods, Drew Brees… the list is almost endless. We can’t guarantee you’ll emulate their achievements, but you’ll be closer to your heroes!",
                                   @"packItNumber" : @214,
                                   @"rockItNumber" : @453,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d2 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"ChannelCover2",
                                   @"wallpaper" : @"ChannelWallpaper2",
                                   @"title" : @"H & M",
                                   @"subtitle" : @"THE TREND SETTERS",
                                   @"biog" : @"If you want to stand out in the fashion crowd, there’s only one place to shop – H&M. Whatever style tribe you belong to, H&M’s colourful clothes are fun, playful and always cool. Stay on trend this season and head to the High Street’s most stylish shop.",
                                   @"packItNumber" : @144,
                                   @"rockItNumber" : @273,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d3 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"",
                                   @"thumbnail" : @"ChannelCover3",
                                   @"wallpaper" : @"ChannelWallpaper3",
                                   @"title" : @"STAR WARS: THE CLONE WARS",
                                   @"subtitle" : @"FEEL THE FORCE",
                                   @"biog" : @"The amazing adventures of Star Wars come to animated life in this CGI series created by George Lucas himself. Set in the time period between Attack of the Clones and Revenge of the Sith, the series comprises one feature length film, and five, thus far, television series. The force is still strong in Star Wars!",
                                   @"packItNumber" : @341,
                                   @"rockItNumber" : @886,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d4 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"CarlyRaeJepsen",
                                   @"thumbnail" : @"ChannelCover4",
                                   @"wallpaper" : @"ChannelWallpaper4",
                                   @"title" : @"TES SCIENCE",
                                   @"subtitle" : @"EXCITING EXPERIMENTS",
                                   @"biog" : @"Make learning fun with the TES Science channel. Featuring a whole host of teaching resources designed to make physics, chemistry and co, informative as well as entertaining, the dynamic TES Science channel will inspire a legion of wannabe scientists and professors. The next Brian Cox is just around the corner!",
                                   @"packItNumber" : @553,
                                   @"rockItNumber" : @132,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d5 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"HotelTransylvania",
                                   @"thumbnail" : @"ChannelCover5",
                                   @"wallpaper" : @"ChannelWallpaper5",
                                   @"title" : @"KATY PERRY",
                                   @"subtitle" : @"PART OF HER",
                                   @"biog" : @"Katy Perry is one of the most colourful pop stars in the world. Instantly recognisable thanks to her captivating looks, humorous behaviour and exciting music, Perry has won legions of fans since bursting onto the scene in 2008. We listen to Katy Perry and we like it.",
                                   @"packItNumber" : @987,
                                   @"rockItNumber" : @613,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d6 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"JustinBieber",
                                   @"thumbnail" : @"ChannelCover6",
                                   @"wallpaper" : @"ChannelWallpaper6",
                                   @"title" : @"JLS",
                                   @"subtitle" : @"JACK THE LADS",
                                   @"biog" : @"Not winning X Factor certainly hasn’t held JLS back. Ortise, Marvin, J.B. and Aston’s infectious brand of R&B has seen them rise to the top of the global pop pile. Not only have they registered multiple number ones, but they’ve been awarded numerous accolades too. They are Outta This World.",
                                   @"packItNumber" : @921,
                                   @"rockItNumber" : @277,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d7 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"Madagascar3",
                                   @"thumbnail" : @"ChannelCover7",
                                   @"wallpaper" : @"ChannelWallpaper7",
                                   @"title" : @"THE HOBBIT",
                                   @"subtitle" : @"THE JOURNEY BEGINS",
                                   @"biog" : @"J. R. R. Tolkien’s fantasy novel follows the various adventures of Bilbo Baggins and friends as they seek to reclaim the Lonely Mountain and its treasure from the evil dragon Smaug. Their quest across Middle-earth sees them encounter wizards, warriors and a strange creature called Gollum. Peter Jackson’s movie adaptation breathes new life into this enduring classic.",
                                   @"packItNumber" : @158,
                                   @"rockItNumber" : @323,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @FALSE}];
        
        NSMutableDictionary *d8 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"MonstersUniversity",
                                   @"thumbnail" : @"ChannelCover8",
                                   @"wallpaper" : @"ChannelWallpaper8",
                                   @"title" : @"HALO",
                                   @"subtitle" : @"THE HALO NATION",
                                   @"biog" : @"Good versus evil is at the heart of the classic science fiction video game series Halo. Will humanity triumph in its battles with the Covenant? The impact of the franchise can’t be underestimated. Numerous spin-offs confirm the popularity of the game, and the latest in the saga, Halo 4, is fantastic.",
                                   @"packItNumber" : @110,
                                   @"rockItNumber" : @245,
                                   @"packIt" : @FALSE,
                                   @"rockIt" : @TRUE}];
        
        NSMutableDictionary *d9 = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"videoURL" : @"NikeFootball",
                                   @"thumbnail" : @"ChannelCover9",
                                   @"wallpaper" : @"ChannelWallpaper9",
                                   @"title" : @"THE X FACTOR",
                                   @"subtitle" : @"SING WHEN YOU'RE WINNING",
                                   @"biog" : @"The original all-singing, all-dancing reality television talent show. The X Factor has given us Leona Lewis, Alexander Burke and JLS, and made a star of the show’s creator Simon Cowell. Have you got what it takes to impress the judges? Have you got The X Factor?",
                                   @"packItNumber" : @883,
                                   @"rockItNumber" : @653,
                                   @"packIt" : @TRUE,
                                   @"rockIt" : @FALSE}];
        
        self.thumbnailDetailsArray = @[d1, d2, d3, d4, d5, d6, d7, d8, d9];
    }
    
    return self;
}

- (UIImage *) wallpaperForIndex: (int) index
                     withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    NSString *thumbnailString = [videoDetails objectForKey: @"wallpaper"];
    
    UIImage *thumbnail = [UIImage imageNamed: thumbnailString];
    
    return thumbnail;
}

- (NSString *) biogForIndex: (int) index
                  withOffset: (int) offset
{
    NSDictionary *videoDetails = [self.thumbnailDetailsArray objectAtIndex: [self adjustedIndexForIndex: index withOffset: offset]];
    NSString *videoTitle = [videoDetails objectForKey: @"biog"];
    
    return videoTitle;
}

@end
