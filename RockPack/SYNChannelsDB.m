//
//  SYNChannelsDB.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNAppDelegate.h"
#import "SYNChannelsDB.h"

@interface SYNChannelsDB ()
@property (nonatomic, strong) NSArray *channelDetailsArray;

// New CoreData support
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation SYNChannelsDB

// Need to explicitly synthesise these as we are using the real ivars below
@synthesize managedObjectContext = _managedObjectContext;

- (NSManagedObjectContext *) managedObjectContext
{
	if (!_managedObjectContext)
	{
        SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = delegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}


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
        NSError *error = nil;
        
        // Create a Video entity (to allow us to manipulate Video objects in the DB)
        NSEntityDescription *channelEntity = [NSEntityDescription entityForName: @"Channel"
                                                         inManagedObjectContext: self.managedObjectContext];
        
        // Find out how many Video objects we have in the database
        NSFetchRequest *countFetchRequest = [[NSFetchRequest alloc] init];
        [countFetchRequest setEntity: channelEntity];
        
        NSArray *channelEntries = [self.managedObjectContext executeFetchRequest: countFetchRequest
                                                                         error: &error];
        
        // If we don't have any Video entries in our database, then create some
        // (replace this with API sooner rather than later)
        if ([channelEntries count] == 0)
        {
            NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover1",
                                       @"wallpaperURL" : @"ChannelWallpaper1",
                                       @"title" : @"NIKE SUPERSTARS",
                                       @"subtitle" : @"JUST DO IT",
                                       @"biog" : @"Nike has sponsored more superstars than you’ve had hot dinners. Wayne Rooney, Kobe Bryant, Maria Sharapova, Cristiano Ronaldo, Rafael Nadal, Victoria Azarenka, Roger Federer, Tiger Woods, Drew Brees… the list is almost endless. We can’t guarantee you’ll emulate their achievements, but you’ll be closer to your heroes!",
                                       @"totalPacks" : @214,
                                       @"totalRocks" : @453,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d2 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover2",
                                       @"wallpaperURL" : @"ChannelWallpaper2",
                                       @"title" : @"H & M",
                                       @"subtitle" : @"THE TREND SETTERS",
                                       @"biog" : @"If you want to stand out in the fashion crowd, there’s only one place to shop – H&M. Whatever style tribe you belong to, H&M’s colourful clothes are fun, playful and always cool. Stay on trend this season and head to the High Street’s most stylish shop.",
                                       @"totalPacks" : @144,
                                       @"totalRocks" : @273,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d3 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover3",
                                       @"wallpaperURL" : @"ChannelWallpaper3",
                                       @"title" : @"STAR WARS: THE CLONE WARS",
                                       @"subtitle" : @"FEEL THE FORCE",
                                       @"biog" : @"The amazing adventures of Star Wars come to animated life in this CGI series created by George Lucas himself. Set in the time period between Attack of the Clones and Revenge of the Sith, the series comprises one feature length film, and five, thus far, television series. The force is still strong in Star Wars!",
                                       @"totalPacks" : @341,
                                       @"totalRocks" : @886,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d4 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover4",
                                       @"wallpaperURL" : @"ChannelWallpaper4",
                                       @"title" : @"TES SCIENCE",
                                       @"subtitle" : @"EXCITING EXPERIMENTS",
                                       @"biog" : @"Make learning fun with the TES Science channel. Featuring a whole host of teaching resources designed to make physics, chemistry and co, informative as well as entertaining, the dynamic TES Science channel will inspire a legion of wannabe scientists and professors. The next Brian Cox is just around the corner!",
                                       @"totalPacks" : @553,
                                       @"totalRocks" : @132,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d5 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover5",
                                       @"wallpaperURL" : @"ChannelWallpaper5",
                                       @"title" : @"KATY PERRY",
                                       @"subtitle" : @"PART OF HER",
                                       @"biog" : @"Katy Perry is one of the most colourful pop stars in the world. Instantly recognisable thanks to her captivating looks, humorous behaviour and exciting music, Perry has won legions of fans since bursting onto the scene in 2008. We listen to Katy Perry and we like it.",
                                       @"totalPacks" : @987,
                                       @"totalRocks" : @613,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d6 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover6",
                                       @"wallpaperURL" : @"ChannelWallpaper6",
                                       @"title" : @"JLS",
                                       @"subtitle" : @"JACK THE LADS",
                                       @"biog" : @"Not winning X Factor certainly hasn’t held JLS back. Ortise, Marvin, J.B. and Aston’s infectious brand of R&B has seen them rise to the top of the global pop pile. Not only have they registered multiple number ones, but they’ve been awarded numerous accolades too. They are Outta This World.",
                                       @"totalPacks" : @921,
                                       @"totalRocks" : @277,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d7 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover7",
                                       @"wallpaperURL" : @"ChannelWallpaper7",
                                       @"title" : @"THE HOBBIT",
                                       @"subtitle" : @"THE JOURNEY BEGINS",
                                       @"biog" : @"J. R. R. Tolkien’s fantasy novel follows the various adventures of Bilbo Baggins and friends as they seek to reclaim the Lonely Mountain and its treasure from the evil dragon Smaug. Their quest across Middle-earth sees them encounter wizards, warriors and a strange creature called Gollum. Peter Jackson’s movie adaptation breathes new life into this enduring classic.",
                                       @"totalPacks" : @158,
                                       @"totalRocks" : @323,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d8 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover8",
                                       @"wallpaperURL" : @"ChannelWallpaper8",
                                       @"title" : @"HALO",
                                       @"subtitle" : @"THE HALO NATION",
                                       @"biog" : @"Good versus evil is at the heart of the classic science fiction video game series Halo. Will humanity triumph in its battles with the Covenant? The impact of the franchise can’t be underestimated. Numerous spin-offs confirm the popularity of the game, and the latest in the saga, Halo 4, is fantastic.",
                                       @"totalPacks" : @110,
                                       @"totalRocks" : @245,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d9 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover9",
                                       @"wallpaperURL" : @"ChannelWallpaper9",
                                       @"title" : @"THE X FACTOR",
                                       @"subtitle" : @"SING WHEN YOU'RE WINNING",
                                       @"biog" : @"The original all-singing, all-dancing reality television talent show. The X Factor has given us Leona Lewis, Alexander Burke and JLS, and made a star of the show’s creator Simon Cowell. Have you got what it takes to impress the judges? Have you got The X Factor?",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d10 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover10",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"ADIDAS",
                                       @"subtitle" : @"THE MESSIAH!",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d11 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover11",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"REEBOK",
                                       @"subtitle" : @"LABRINTH & BLUEY",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d12 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover12",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"TES",
                                       @"subtitle" : @"HISTORY",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d13 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover13",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"UNIVERSAL STUDIOS",
                                       @"subtitle" : @"DESPICABLE ME 2",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d14 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover14",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"WARNER BROS.",
                                       @"subtitle" : @"JACK THE GIANT KILLER",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d15 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover15",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"MARVEL",
                                       @"subtitle" : @"THE AVENGERS 2",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d16 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover16",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"CARTOON NETWORK",
                                       @"subtitle" : @"ADVENTURE TIME",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d17 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover17",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"VICTORIOUS",
                                       @"subtitle" : @"TORI AND JADE ROCK!",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d18 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover18",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"MERLIN",
                                       @"subtitle" : @"SERIES 5",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d19 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover19",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"ONE DIRECTION",
                                       @"subtitle" : @"LIVE WHILE WE'RE YOUNG",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d20 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover20",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"ENGLAND FOOTBALL TEAM",
                                       @"subtitle" : @"ROAD TO RIO",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d21 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover21",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"RED BULL",
                                       @"subtitle" : @"THE ATHLETE MACHINE",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d22 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover22",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"PLAYSTATION",
                                       @"subtitle" : @"LITTLE BIG PLANET KARTING",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d23 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover23",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"GAMELOFT",
                                       @"subtitle" : @"ZOMBIEWOOD",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d24 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover24",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"ROVIO",
                                       @"subtitle" : @"ANGRY BIRDS STAR WARS",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d25 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover25",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"COCA-COLA",
                                       @"subtitle" : @"CELEBRATE LONDON",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @TRUE}];
            
            
            NSMutableDictionary *d26 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover26",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"OLD SPICE",
                                       @"subtitle" : @"BELIEVE IN YOUR SMELLF",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d27 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover27",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"YOGSCAST",
                                       @"subtitle" : @"FAN FRIDAY!",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d28 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover28",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"GAP",
                                       @"subtitle" : @"LOVE COMES IN EVERY SHADE",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d29 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover29",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"OFFICIAL PSY",
                                       @"subtitle" : @"GANGNAM STYLE",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d30 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover30",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"EXPERT VILLAGE",
                                       @"subtitle" : @"WATCH. LEARN. DO",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d31 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover31",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"ANNOYING ORANGE",
                                       @"subtitle" : @"TIME TO BURN",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @FALSE,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d32 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"",
                                       @"keyframeURL" : @"ChannelCover32",
                                       @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                       @"title" : @"NBA",
                                       @"subtitle" : @"HEROICS IN TORONTO!",
                                       @"biog" : @"",
                                       @"totalPacks" : @883,
                                       @"totalRocks" : @653,
                                       @"packedByUser" : @TRUE,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d33 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"",
                                        @"keyframeURL" : @"ChannelCover33",
                                        @"wallpaperURL" : @"ChannelWallpaperGeneric",
                                        @"title" : @"DOCTOR WHO",
                                        @"subtitle" : @"SERIES 7",
                                        @"biog" : @"",
                                        @"totalPacks" : @883,
                                        @"totalRocks" : @653,
                                        @"packedByUser" : @FALSE,
                                        @"rockedByUser" : @FALSE}];
            
            self.channelDetailsArray = @[d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d33, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31, d32];
            
            NSError *error = nil;
            
            // Create a Video entity (to allow us to manipulate Video objects in the DB)
            NSEntityDescription *videoEntity = [NSEntityDescription entityForName: @"Video"
                                                           inManagedObjectContext: self.managedObjectContext];
            
            // Find out how many Video objects we have in the database
            NSFetchRequest *countFetchRequest = [[NSFetchRequest alloc] init];
            [countFetchRequest setEntity: videoEntity];
            
            NSArray *videoEntries = [self.managedObjectContext executeFetchRequest: countFetchRequest
                                                                             error: &error];
            
            int index = 0;
            // Now create the NSManaged Video objects corresponding to these details
            for (NSDictionary *channelDetailsDictionary in self.channelDetailsArray)
            {
                //                Video *video = (Video *)[[NSManagedObject alloc] initWithEntity: videoEntity
                //                                                   insertIntoManagedObjectContext: self.managedObjectContext];
                
                Channel *channel = [Channel insertInManagedObjectContext: self.managedObjectContext];
                
                channel.indexValue = index++;
                channel.keyframeURL = [channelDetailsDictionary objectForKey: @"keyframeURL"];
                channel.wallpaperURL = [channelDetailsDictionary objectForKey: @"wallpaperURL"];
                channel.title = [channelDetailsDictionary objectForKey: @"title"];
                channel.subtitle = [channelDetailsDictionary objectForKey: @"subtitle"];
                channel.biog = [channelDetailsDictionary objectForKey: @"biog"];
                channel.biogTitle = [channelDetailsDictionary objectForKey: @"title"];
                channel.packedByUser = [channelDetailsDictionary objectForKey: @"packedByUser"];
                channel.rockedByUser = [channelDetailsDictionary objectForKey: @"rockedByUser"];
                channel.totalPacks = [channelDetailsDictionary objectForKey: @"totalPacks"];
                channel.totalRocks = [channelDetailsDictionary objectForKey: @"totalRocks"];
                channel.userGeneratedValue = FALSE;
                
                [[channel videosSet] addObjectsFromArray: videoEntries];
            }
            
            // Now we have created all our Video objects, save them...
            if (![self.managedObjectContext save: &error])
            {
                NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
                
                if ([detailedErrors count] > 0)
                {
                    for(NSError* detailedError in detailedErrors)
                    {
                        NSLog(@" DetailedError: %@", [detailedError userInfo]);
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


@end
