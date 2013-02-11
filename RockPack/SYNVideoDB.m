//
//  SYNVideoDB.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoDB.h"
#import "SYNVideoDownloadEngine.h"
#import "MKNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "MBProgressHUD.h"
#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "Video.h"
#import "Channel.h"
#import "VideoInstance.h"
#import "ChannelOwner.h"

@interface SYNVideoDB () <MBProgressHUDDelegate>

@property (nonatomic, strong) NSArray *videoDetailsArray;
@property (nonatomic, strong) NSArray *channelDetailsArray;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@property (strong, nonatomic) SYNVideoDownloadEngine *downloadEngine;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) NSMutableArray *progressArray;

// New CoreData support

// We don't need to retain this as it is already retained by the app delegate
@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;

@end

@implementation SYNVideoDB

// Need to explicitly synthesise these as we are using the real ivars below
@synthesize mainManagedObjectContext = _mainManagedObjectContext;

- (NSManagedObjectContext *) mainManagedObjectContext
{
	if (!_mainManagedObjectContext)
	{
        SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.mainManagedObjectContext = delegate.mainManagedObjectContext;
    }
    
    return _mainManagedObjectContext;
}

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

//+ (id) sharedFriendDBManager
//{
//    static dispatch_once_t onceQueue;
//    static SYNVideoDB *friendDBManager = nil;
//    
//    dispatch_once(&onceQueue, ^
//                  {
//                      friendDBManager = [[self alloc] initFriends];
//                  });
//    
//    return friendDBManager;
//}


- (id) init
{
    if ((self = [super init]))
    {
        NSError *error = nil;
        
        // Create a Video entity (to allow us to manipulate Video objects in the DB)
        NSEntityDescription *videoEntity = [NSEntityDescription entityForName: @"Video"
                                                       inManagedObjectContext: self.mainManagedObjectContext];
        
        // Find out how many Video objects we have in the database
        NSFetchRequest *countFetchRequest = [[NSFetchRequest alloc] init];
        [countFetchRequest setEntity: videoEntity];
        
        NSArray *videoEntries = [self.mainManagedObjectContext executeFetchRequest: countFetchRequest
                                                                         error: &error];
        
        // If we don't have any Video entries in our database, then create some
        // (replace this with API sooner rather than later)
        if ([videoEntries count] == 0)
        {
            // Nasty, but only for demo
            NSMutableDictionary *v1 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"Adidas",
                                       @"keyframeURL" : @"Adidas",
                                       @"title" : @"ADIDAS | TEAM GB",
                                       @"channel" : @"MESSI TOP 5",
                                       @"user" : @"TRICKY NICKY",
                                       @"totalRocks" : @453,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *v2 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"AngryBirds",
                                       @"keyframeURL" : @"AngryBirds",
                                       @"title" : @"ANGRY BIRDS: STAR WARS",
                                       @"channel" : @"WATCH OUT FOR THE PIGS",
                                       @"user" : @"KISHAN THE MAN",
                                       @"totalRocks" : @273,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *v3 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"CallOfDuty",
                                       @"keyframeURL" : @"CallOfDuty",
                                       @"title" : @"CALL OF DUTY: BLACK OPS 2",
                                       @"channel" : @"LEAD BY EXAMPLE",
                                       @"user" : @"LEIGH982",
                                       @"totalRocks" : @886,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *v4 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"CarlyRaeJepsen",
                                       @"keyframeURL" : @"CarlyRaeJepsen",
                                       @"title" : @"CARLY RAE JEPSEN",
                                       @"user" : @"WADINGBIRD",
                                       @"channel" : @"CALL ME?",
                                       @"totalRocks" : @132,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *v5 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"HotelTransylvania",
                                       @"keyframeURL" : @"HotelTransylvania",
                                       @"title" : @"HOTEL TRANSYLVANIA",
                                       @"channel" : @"SPOOKY!",
                                       @"user" : @"8BITBOY",
                                       @"totalRocks" : @613,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *v6 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"JustinBieber",
                                       @"keyframeURL" : @"JustinBieber",
                                       @"title" : @"JUSTIN BIEBER",
                                       @"channel" : @"MY SUMMER",
                                       @"user" : @"LILACBAGEL",
                                       @"totalRocks" : @277,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *v7 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"Madagascar3",
                                       @"keyframeURL" : @"Madagascar3",
                                       @"title" : @"MADAGASCAR 3: EUROPE'S MOST WANTED",
                                       @"channel" : @"POLKA DOT AFRO",
                                       @"user" : @"ERINPASTA",
                                       @"totalRocks" : @323,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *v8 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"MonstersUniversity",
                                       @"keyframeURL" : @"MonstersUniversity",
                                       @"title" : @"MONSTERS UNIVERSITY",
                                       @"user" : @"ADRIANALIMA",
                                       @"channel" : @"THEY ARE BACK",
                                       @"totalRocks" : @245,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *v9 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"NikeFootball",
                                       @"keyframeURL" : @"NikeFootball",
                                       @"title" : @"NIKE FOOTBALL: MERCURIAL VAPOR VIII",
                                       @"channel" : @"RONALDO VS RAFA",
                                       @"user" : @"SOPHIE_SMITH",
                                       @"totalRocks" : @653,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *v10 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"OneDirection",
                                        @"keyframeURL" : @"OneDirection",
                                        @"title" : @"ONE DIRECTION",
                                        @"channel" : @"LIVE WHILE WE'RE YOUNG",
                                        @"user" : @"ARDENTIRISHBOY",
                                        @"totalRocks" : @121,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *v11 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"TheDarkKnightRises",
                                        @"keyframeURL" : @"TheDarkKnightRises",
                                        @"title" : @"THE DARK KNIGHT RISES",
                                        @"user" : @"NEARSPECTRE",
                                        @"channel" : @"BEWARE OF THE BAT",
                                        @"totalRocks" : @271,
                                        @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *v12 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"TheLionKing",
                                        @"keyframeURL" : @"TheLionKing",
                                        @"title" : @"THE LION KING",
                                        @"channel" : @"CIRCLE OF LIFE",
                                        @"user" : @"FUNNYPENGUIN",
                                        @"totalRocks" : @978,
                                        @"rockedByUser" : @FALSE}];
            
            self.videoDetailsArray = @[v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12];
            
            NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover1",
                                       @"wallpaperURL" : @"ChannelWallpaper1",
                                       @"title" : @"NIKE SUPERSTARS",
                                       @"subtitle" : @"JUST DO IT",
                                       @"biog" : @"Nike has sponsored more superstars than you’ve had hot dinners. Wayne Rooney, Kobe Bryant, Maria Sharapova, Cristiano Ronaldo, Rafael Nadal, Victoria Azarenka, Roger Federer, Tiger Woods, Drew Brees… the list is almost endless. We can’t guarantee you’ll emulate their achievements, but you’ll be closer to your heroes!",
                                       @"totalRocks" : @453,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d2 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover2",
                                       @"wallpaperURL" : @"ChannelWallpaper2",
                                       @"title" : @"H & M",
                                       @"subtitle" : @"THE TREND SETTERS",
                                       @"biog" : @"If you want to stand out in the fashion crowd, there’s only one place to shop – H&M. Whatever style tribe you belong to, H&M’s colourful clothes are fun, playful and always cool. Stay on trend this season and head to the High Street’s most stylish shop.",
                                       @"totalRocks" : @273,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d3 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover3",
                                       @"wallpaperURL" : @"ChannelWallpaper3",
                                       @"title" : @"ITUNES",
                                       @"subtitle" : @"WHAT'S ON",
                                       @"biog" : @"TThe iTunes Store has been redesigned for your Mac, PC, iPad, iPhone and iPod touch, so it looks and works the same wherever you shop. Easy-to-browse shelves serve up popular music, films, TV programmes and more. And all the features you know and love are even easier to get to. It’s the best kind of shopping — simple.",
                                       @"totalRocks" : @886,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d4 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover4",
                                       @"wallpaperURL" : @"ChannelWallpaper4",
                                       @"title" : @"TES SCIENCE",
                                       @"subtitle" : @"EXCITING EXPERIMENTS",
                                       @"biog" : @"Make learning fun with the TES Science channel. Featuring a whole host of teaching resources designed to make physics, chemistry and co, informative as well as entertaining, the dynamic TES Science channel will inspire a legion of wannabe scientists and professors. The next Brian Cox is just around the corner!",
                                       @"totalRocks" : @132,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d5 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover5",
                                       @"wallpaperURL" : @"ChannelWallpaper5",
                                       @"title" : @"KATY PERRY",
                                       @"subtitle" : @"PART OF HER",
                                       @"biog" : @"Katy Perry is one of the most colourful pop stars in the world. Instantly recognisable thanks to her captivating looks, humorous behaviour and exciting music, Perry has won legions of fans since bursting onto the scene in 2008. We listen to Katy Perry and we like it.",
                                       @"totalRocks" : @613,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d6 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover6",
                                       @"wallpaperURL" : @"ChannelWallpaper6",
                                       @"title" : @"JLS",
                                       @"subtitle" : @"JACK THE LADS",
                                       @"biog" : @"Not winning X Factor certainly hasn’t held JLS back. Ortise, Marvin, J.B. and Aston’s infectious brand of R&B has seen them rise to the top of the global pop pile. Not only have they registered multiple number ones, but they’ve been awarded numerous accolades too. They are Outta This World.",
                                       @"totalRocks" : @277,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d7 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover7",
                                       @"wallpaperURL" : @"ChannelWallpaper7",
                                       @"title" : @"THE HOBBIT",
                                       @"subtitle" : @"THE JOURNEY BEGINS",
                                       @"biog" : @"J. R. R. Tolkien’s fantasy novel follows the various adventures of Bilbo Baggins and friends as they seek to reclaim the Lonely Mountain and its treasure from the evil dragon Smaug. Their quest across Middle-earth sees them encounter wizards, warriors and a strange creature called Gollum. Peter Jackson’s movie adaptation breathes new life into this enduring classic.",
                                       @"totalRocks" : @323,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d8 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover8",
                                       @"wallpaperURL" : @"ChannelWallpaper8",
                                       @"title" : @"HALO",
                                       @"subtitle" : @"THE HALO NATION",
                                       @"biog" : @"Good versus evil is at the heart of the classic science fiction video game series Halo. Will humanity triumph in its battles with the Covenant? The impact of the franchise can’t be underestimated. Numerous spin-offs confirm the popularity of the game, and the latest in the saga, Halo 4, is fantastic.",
                                       @"totalRocks" : @245,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d9 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover9",
                                       @"wallpaperURL" : @"ChannelWallpaper9",
                                       @"title" : @"THE X FACTOR",
                                       @"subtitle" : @"SING WHEN YOU'RE WINNING",
                                       @"biog" : @"The original all-singing, all-dancing reality television talent show. The X Factor has given us Leona Lewis, Alexander Burke and JLS, and made a star of the show’s creator Simon Cowell. Have you got what it takes to impress the judges? Have you got The X Factor?",
                                       @"totalRocks" : @653,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d10 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover10",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"ADIDAS",
                                        @"subtitle" : @"THE MESSIAH!",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d11 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover11",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"REEBOK",
                                        @"subtitle" : @"LABRINTH & BLUEY",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d12 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover12",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"TES",
                                        @"subtitle" : @"HISTORY",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d13 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover13",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"UNIVERSAL STUDIOS",
                                        @"subtitle" : @"DESPICABLE ME 2",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d14 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover14",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"WARNER BROS.",
                                        @"subtitle" : @"JACK THE GIANT KILLER",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d15 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover15",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"MARVEL",
                                        @"subtitle" : @"THE AVENGERS 2",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d16 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover16",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"CARTOON NETWORK",
                                        @"subtitle" : @"ADVENTURE TIME",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d17 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover17",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"VICTORIOUS",
                                        @"subtitle" : @"TORI AND JADE ROCK!",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d18 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover18",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"MERLIN",
                                        @"subtitle" : @"SERIES 5",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d19 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover19",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"ONE DIRECTION",
                                        @"subtitle" : @"LIVE WHILE WE'RE YOUNG",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d20 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover20",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"ENGLAND FOOTBALL TEAM",
                                        @"subtitle" : @"ROAD TO RIO",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d21 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover21",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"RED BULL",
                                        @"subtitle" : @"THE ATHLETE MACHINE",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d22 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover22",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"PLAYSTATION",
                                        @"subtitle" : @"LITTLE BIG PLANET KARTING",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d23 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover23",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"GAMELOFT",
                                        @"subtitle" : @"ZOMBIEWOOD",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d24 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover24",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"ROVIO",
                                        @"subtitle" : @"ANGRY BIRDS STAR WARS",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d25 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover25",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"COCA-COLA",
                                        @"subtitle" : @"CELEBRATE LONDON",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @TRUE}];
            
            
            NSMutableDictionary *d26 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover26",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"OLD SPICE",
                                        @"subtitle" : @"BELIEVE IN YOUR SMELLF",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d27 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover27",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"YOGSCAST",
                                        @"subtitle" : @"FAN FRIDAY!",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d28 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover28",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"GAP",
                                        @"subtitle" : @"LOVE COMES IN EVERY SHADE",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d29 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover29",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"OFFICIAL PSY",
                                        @"subtitle" : @"GANGNAM STYLE",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d30 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover30",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"EXPERT VILLAGE",
                                        @"subtitle" : @"WATCH. LEARN. DO",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d31 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover31",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"ANNOYING ORANGE",
                                        @"subtitle" : @"TIME TO BURN",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d32 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover32",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"NBA",
                                        @"subtitle" : @"HEROICS IN TORONTO!",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d33 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover33",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"DOCTOR WHO",
                                        @"subtitle" : @"SERIES 7",
                                        @"biog" : @"",
                                        @"totalRocks" : @653,
                                        @"rockedByUser" : @FALSE}];
            
            self.channelDetailsArray = @[d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d33, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31, d32];
            
            int uniqueId = 0;
            NSMutableArray *videos = [[NSMutableArray alloc] initWithCapacity: 12];
            
            // Now create the NSManaged Video objects corresponding to these details
            for (NSDictionary *videoDetailsDictionary in self.videoDetailsArray)
            {                          
                Video *video = [Video insertInManagedObjectContext: self.mainManagedObjectContext];
                
                video.uniqueId = [NSString stringWithFormat: @"%d", uniqueId++];
                video.source = @"rockpack"; // Hardwire this for now
                video.sourceId = videoDetailsDictionary [@"videoURL"];
                video.categoryId = @"funny";
                video.thumbnailURL = videoDetailsDictionary [@"keyframeURL"];
                video.starredByUser = videoDetailsDictionary [@"rockedByUser"];
                video.starCount = videoDetailsDictionary [@"totalRocks"];
                
                [videos addObject: video];
            }
            
            // Create a couple of channel owners in the database, one for the user of the app and one for another user
            ChannelOwner *channelOwnerMe = [ChannelOwner insertInManagedObjectContext: self.mainManagedObjectContext];
            
            channelOwnerMe.name = @"NICK BANKS";
            channelOwnerMe.uniqueId = @"666";
            channelOwnerMe.thumbnailURL = @"ChannelThumb0";
            
            SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.channelOwnerMe = channelOwnerMe;
            
            int index = 0;
            // Now create the NSManaged Video objects corresponding to these details
            for (NSDictionary *channelDetailsDictionary in self.channelDetailsArray)
            {                
                Channel *channel = [Channel insertInManagedObjectContext: self.mainManagedObjectContext];
                
                channel.uniqueId = [NSString stringWithFormat: @"%d", index];
                channel.categoryId = @"funny";
                channel.positionValue = index;
                channel.coverThumbnailSmallURL = channelDetailsDictionary [@"keyframeURL"];
                channel.wallpaperURL = channelDetailsDictionary [@"wallpaperURL"];
                channel.title = channelDetailsDictionary [@"title"];
                channel.channelDescription = channelDetailsDictionary [@"biog"];
                channel.rockedByUser = channelDetailsDictionary [@"rockedByUser"];
                channel.rockCount = channelDetailsDictionary [@"totalRocks"];
                
                ChannelOwner *channelOwner = [ChannelOwner insertInManagedObjectContext: self.mainManagedObjectContext];
                channelOwner.name = ((NSDictionary *)[self.videoDetailsArray objectAtIndex: index % 12]) [@"user"];
                channelOwner.uniqueId = [NSString stringWithFormat: @"ChannelThumb%d", (index % 12) + 1];;
                channelOwner.thumbnailURL = [NSString stringWithFormat: @"ChannelThumb%d", (index % 12) + 1];
                
                channel.channelOwner = channelOwner;
                
                // Now create a set of 10 VideoInstances for each channel
                
                int i = 0;
                
                // Fake up a date which counts back from today (dependent on the value of index)
                NSDate *instanceDate = [NSDate dateWithTimeIntervalSinceNow: index * -(60*60*24)];
                
                for (Video *video in videos)
                {
                    VideoInstance *videoInstance = [VideoInstance insertInManagedObjectContext: self.mainManagedObjectContext];
                    int fakeIndex = 99;
                    if (index < 12)
                    {
                        fakeIndex = (i + index) % 12;
                    }
                    videoInstance.uniqueId = [NSString stringWithFormat: @"%d", fakeIndex];
                    videoInstance.dateAdded = instanceDate;
                    videoInstance.title = [(NSDictionary *)[self.videoDetailsArray objectAtIndex: i++] objectForKey: @"title"];
                    videoInstance.video = video;
                    videoInstance.channel = channel;
                }
                
                 index++;
            }
            
            // Now we have created all our Video objects, save them...
            if (![self.mainManagedObjectContext save: &error])
            {
                NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
                
                if ([detailedErrors count] > 0)
                {
                    for(NSError* detailedError in detailedErrors)
                    {
                        DebugLog(@" DetailedError: %@", [detailedError userInfo]);
                    }
                }
                
                // Bail out if save failed
                error = [NSError errorWithDomain: NSURLErrorDomain
                                            code: NSURLErrorCannotDecodeContentData
                                        userInfo: nil];
                
                @throw NSGenericException;
            }

        }
    }
    
    return self;
}


// Attempt to download all of the videos into the /Documents directory

- (void) downloadContentIfRequiredDisplayingHUDInView: (UIView *) view;
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	// Check to see if we hace already successfully downloaded the content
	if ([userDefaults boolForKey: kDownloadedVideoContentBool]  == FALSE)
    {
        self.HUD = [[MBProgressHUD alloc] initWithView: view];
        [view addSubview: self.HUD];
        
        self.HUD.delegate = self;
        self.HUD.labelText = @"Downloading";
        self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
        self.HUD.color = [UIColor colorWithRed: 25.0f/255.0f green: 82.0f/255.0f blue: 112.0f/255.0f alpha: 1.0f];
        self.HUD.removeFromSuperViewOnHide = YES;
        
        [self.HUD show: YES];
        
        // Set up networking
        self.downloadEngine = [[SYNVideoDownloadEngine alloc] initWithHostName: @"rockpack.discover.video.s3.amazonaws.com"
                                                            customHeaderFields: nil];
        
        self.progressArray = [[NSMutableArray alloc] initWithCapacity: self.videoDetailsArray.count];
        
        
                // Initialise percentage array
        for (int videoFileIndex = 0; videoFileIndex < self.videoDetailsArray.count; videoFileIndex++)
        {
            [self.progressArray addObject: [NSNumber numberWithDouble: 0.0f]];
        }
        
        __block int numberDownloaded = 0;
             
        for (int videoFileIndex = 0; videoFileIndex < self.videoDetailsArray.count; videoFileIndex++)
        {        
            NSDictionary *videoDetails = [self.videoDetailsArray objectAtIndex: videoFileIndex];
            NSString *videoURLString = videoDetails [@"videoURL"];
            
            NSString *downloadPath = [NSHomeDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"/Documents/%@.mp4", videoURLString, nil]];
            
            self.downloadOperation = [self.downloadEngine downloadFileFrom: [NSString stringWithFormat: @"%@.mp4", videoURLString, nil]
                                                                    toFile: downloadPath];
            
            [self.downloadOperation onDownloadProgressChanged: ^(double progress)
             {
                 [self.progressArray replaceObjectAtIndex: videoFileIndex
                                               withObject: [NSNumber numberWithDouble: progress]];
                 
                 [self updateProgressIndicator];
             }];
            
            __block SYNVideoDB *weakSelf = self;
            
            [self.downloadOperation addCompletionHandler: ^(MKNetworkOperation *completedOperation)
             {
                 if (++numberDownloaded == weakSelf.videoDetailsArray.count)
                 {
                     [weakSelf.HUD hide: NO];
                     
                     // Indicate that we don't need to do this again
                     [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: TRUE]
                                                               forKey: kDownloadedVideoContentBool];
                     
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
             }
             errorHandler: ^(MKNetworkOperation* completedOperation, NSError* error)
             {
                 [weakSelf.HUD hide: NO];
                 [UIAlertView showWithError: error];
             }];
        }
    }
}


- (void) updateProgressIndicator
{
    double cumulativeProgress = 0.0f;
    
    for (int videoFileIndex = 0; videoFileIndex < self.videoDetailsArray.count; videoFileIndex++)
    {
        NSNumber *progress = [self.progressArray objectAtIndex: videoFileIndex];
        cumulativeProgress += progress.doubleValue;
    }
    
    self.HUD.progress = cumulativeProgress / (double) self.videoDetailsArray.count;
}

@end
