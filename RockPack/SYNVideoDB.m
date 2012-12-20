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

@interface SYNVideoDB () <MBProgressHUDDelegate>

@property (nonatomic, strong) NSArray *videoDetailsArray;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@property (strong, nonatomic) SYNVideoDownloadEngine *downloadEngine;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) NSMutableArray *progressArray;

// New CoreData support

// We don't need to retain this as it is already retained by the app delegate
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation SYNVideoDB

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
        NSError *error = nil;
        
        // Create a Video entity (to allow us to manipulate Video objects in the DB)
        NSEntityDescription *videoEntity = [NSEntityDescription entityForName: @"Video"
                                                       inManagedObjectContext: self.managedObjectContext];
        
        // Find out how many Video objects we have in the database
        NSFetchRequest *countFetchRequest = [[NSFetchRequest alloc] init];
        [countFetchRequest setEntity: videoEntity];
        
        NSArray *videoEntries = [self.managedObjectContext executeFetchRequest: countFetchRequest
                                                                         error: &error];
        
        // If we don't have any Video entries in our database, then create some
        // (replace this with API sooner rather than later)
        if ([videoEntries count] == 0)
        {
            // Nasty, but only for demo
            NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"Adidas",
                                       @"keyframeURL" : @"Adidas",
                                       @"title" : @"ADIDAS | TEAM GB",
                                       @"channel" : @"MESSI TOP 5",
                                       @"user" : @"TRICKY NICKY",
                                       @"totalRocks" : @453,
                                       @"rockedByUser" : @FALSE}];
        
            NSMutableDictionary *d2 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"AngryBirds",
                                       @"keyframeURL" : @"AngryBirds",
                                       @"title" : @"ANGRY BIRDS: STAR WARS",
                                       @"channel" : @"WATCH OUT FOR THE PIGS",
                                       @"user" : @"KISHAN THE MAN",
                                       @"totalRocks" : @273,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d3 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"CallOfDuty",
                                       @"keyframeURL" : @"CallOfDuty",
                                       @"title" : @"CALL OF DUTY: BLACK OPS 2",
                                       @"channel" : @"LEAD BY EXAMPLE",
                                       @"user" : @"LEIGH982",
                                       @"totalRocks" : @886,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d4 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"CarlyRaeJepsen",
                                       @"keyframeURL" : @"CarlyRaeJepsen",
                                       @"title" : @"CARLY RAE JEPSEN",
                                       @"user" : @"WADINGBIRD",
                                       @"channel" : @"CALL ME?",
                                       @"totalRocks" : @132,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d5 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"HotelTransylvania",
                                       @"keyframeURL" : @"HotelTransylvania",
                                       @"title" : @"HOTEL TRANSYLVANIA",
                                       @"channel" : @"SPOOKY!",
                                       @"user" : @"8BITBOY",
                                       @"totalRocks" : @613,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d6 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"JustinBieber",
                                       @"keyframeURL" : @"JustinBieber",
                                       @"title" : @"JUSTIN BIEBER",
                                       @"channel" : @"MY SUMMER",
                                       @"user" : @"LILACBAGEL",
                                       @"totalRocks" : @277,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d7 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"Madagascar3",
                                       @"keyframeURL" : @"Madagascar3",
                                       @"title" : @"MADAGASCAR 3: EUROPE'S MOST WANTED",
                                       @"channel" : @"POLKA DOT AFRO",
                                       @"user" : @"ERINPASTA",
                                       @"totalRocks" : @323,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d8 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"MonstersUniversity",
                                       @"keyframeURL" : @"MonstersUniversity",
                                       @"title" : @"MONSTERS UNIVERSITY",
                                       @"user" : @"ADRIANALIMA",
                                       @"channel" : @"THEY ARE BACK",
                                       @"totalRocks" : @245,
                                       @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d9 = [NSMutableDictionary dictionaryWithDictionary:
                                       @{@"videoURL" : @"NikeFootball",
                                       @"keyframeURL" : @"NikeFootball",
                                       @"title" : @"NIKE FOOTBALL: MERCURIAL VAPOR VIII",
                                       @"channel" : @"RONALDO VS RAFA",
                                       @"user" : @"SOPHIE_SMITH",
                                       @"totalRocks" : @653,
                                       @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d10 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"OneDirection",
                                        @"keyframeURL" : @"OneDirection",
                                        @"title" : @"ONE DIRECTION",
                                        @"channel" : @"LIVE WHILE WE'RE YOUNG",
                                        @"user" : @"ARDENTIRISHBOY",
                                        @"totalRocks" : @121,
                                        @"rockedByUser" : @FALSE}];
            
            NSMutableDictionary *d11 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"TheDarkKnightRises",
                                        @"keyframeURL" : @"TheDarkKnightRises",
                                        @"title" : @"THE DARK KNIGHT RISES",
                                        @"user" : @"NEARSPECTRE",
                                        @"channel" : @"BEWARE OF THE BAT",
                                        @"totalRocks" : @271,
                                        @"rockedByUser" : @TRUE}];
            
            NSMutableDictionary *d12 = [NSMutableDictionary dictionaryWithDictionary:
                                        @{@"videoURL" : @"TheLionKing",
                                        @"keyframeURL" : @"TheLionKing",
                                        @"title" : @"THE LION KING",
                                        @"channel" : @"CIRCLE OF LIFE",
                                        @"user" : @"FUNNYPENGUIN",
                                        @"totalRocks" : @978,
                                        @"rockedByUser" : @FALSE}];
            
            self.videoDetailsArray = @[d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12];
            
            // Now create the NSManaged Video objects corresponding to these details
            for (NSDictionary *videoDetailsDictionary in self.videoDetailsArray)
            {           
//                Video *video = (Video *)[[NSManagedObject alloc] initWithEntity: videoEntity
//                                                   insertIntoManagedObjectContext: self.managedObjectContext];
                
                Video *video = [Video insertInManagedObjectContext: self.managedObjectContext];
                
                video.videoURL = [videoDetailsDictionary objectForKey: @"videoURL"];
                video.keyframeURL = [videoDetailsDictionary objectForKey: @"keyframeURL"];
                video.videoTitle = [videoDetailsDictionary objectForKey: @"title"];
                video.channelName = [videoDetailsDictionary objectForKey: @"channel"];
                video.userName = [videoDetailsDictionary objectForKey: @"user"];
                video.rockedByUser = [videoDetailsDictionary objectForKey: @"rockedByUser"];
                video.totalRocks = [videoDetailsDictionary objectForKey: @"totalRocks"];
            }
            
            // Now we have created all our Video objects, save them...
            if (![self.managedObjectContext save: &error])
            {
                NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
                
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
            NSString *videoURLString = [videoDetails objectForKey: @"videoURL"];
            
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
