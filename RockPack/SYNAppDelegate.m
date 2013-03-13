//
//  SYNAppDelegate.m
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNBottomTabViewController.h"
#import "SYNNetworkEngine.h"
#import "TestFlight.h"
#import "UIImageView+ImageProcessing.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "UncaughtExceptionHandler.h"
#import "ChannelOwner.h"
#import "SYNMasterViewController.h"
#import "SYNLoginViewController.h"

#define kShowLoginPhase YES

@interface SYNAppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *searchManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (nonatomic, strong) SYNLoginViewController* loginViewController;
@end

@implementation SYNAppDelegate

@synthesize mainRegistry = _mainRegistry, searchRegistry = _searchRegistry, userRegistry = _userRegistry;
@synthesize currentAccessInfo = _currentAccessInfo;

- (BOOL) application:(UIApplication *) application
         didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    // Install our exception handler (must happen on the next turn through the event loop - as opposed to right now)
    [self performSelector: @selector(installUncaughtExceptionHandler)
               withObject: nil
               afterDelay: 0];
    
    // Se up core data
    [self initializeCoreDataStack];
    
    // Set up network engine
    [self initializeNetworkEngine];
    
    
    // Create default user
    [self createDefaultUser];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginCompleted:)
                                                 name:kLoginCompleted
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	// Create a dictionary of defaults to add and register them (if they have not already been set)
	NSDictionary *initDefaults = [NSDictionary dictionaryWithObjectsAndKeys: @(NO), kDownloadedVideoContentBool,
                                                                             nil];
	[defaults registerDefaults: initDefaults];

    
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    SYNBottomTabViewController* bottomTabVC = [[SYNBottomTabViewController alloc] initWithNibName: @"SYNBottomTabViewController"
                                                                       bundle: nil];
    
    SYNMasterViewController* masterViewContoller = [[SYNMasterViewController alloc] initWithRootViewController:bottomTabVC];
    
    self.viewController = masterViewContoller;
    
    self.loginViewController = [[SYNLoginViewController alloc] init];
    
    if(kShowLoginPhase)
        self.window.rootViewController = self.loginViewController;
    else
        self.window.rootViewController = self.viewController;
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)loginCompleted:(NSNotification*)notification
{
    
    AccessInfo* accessInfo = (AccessInfo*)[[notification userInfo] objectForKey:@"AccessInfo"];
    _currentAccessInfo = accessInfo;
    
    self.window.rootViewController = self.viewController;
    
    self.loginViewController = nil;
    
}

#pragma mark - App state transitions

- (void) applicationWillResignActive: (UIApplication *) application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // We need to save out database here (not in background)
    [self saveContext: kSaveSynchronously];
}


- (void) applicationDidEnterBackground: (UIApplication *) application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // We need to save out database here (not in background)
    [self saveContext: kSaveSynchronously];
}


- (void) applicationWillEnterForeground: (UIApplication *) application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void) applicationDidBecomeActive: (UIApplication *) application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void) applicationWillTerminate: (UIApplication *) application
{
    // Saves changes in the application's managed object context before the application terminates.
    
    // We need to save out database here (not in background)
    [self saveContext: kSaveSynchronously];
}


#pragma mark - Exception handler

- (void) installUncaughtExceptionHandler
{
	InstallUncaughtExceptionHandler();
    
    [TestFlight takeOff: kTestFlightAppToken];
}


#pragma mark - Core Data stack

- (void) initializeCoreDataStack
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"Rockpack" withExtension: @"momd"];
    ZAssert(modelURL, @"Failed to find model URL");
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    ZAssert(managedObjectModel, @"Failed to initialize model");
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    ZAssert(persistentStoreCoordinator, @"Failed to initialize persistent store coordinator");
    
    // == Main Context
    
    self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    self.privateManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    self.mainManagedObjectContext.parentContext = self.privateManagedObjectContext;
    
    // == Search Context
    
    self.searchManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *searchPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError* error;
    NSPersistentStore* searchStore = [searchPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                                    configuration:nil
                                                                                              URL:nil
                                                                                          options:nil
                                                                                            error:&error];
    ZAssert(searchStore, @"Failed to initialize search managed context in app delegate");
    
    
    self.searchManagedObjectContext.persistentStoreCoordinator = searchPersistentStoreCoordinator;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSError *error = nil;
    
        NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                                  inDomains: NSUserDomainMask] lastObject];
        
        storeURL = [storeURL URLByAppendingPathComponent: @"Rockpack.sqlite"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: [storeURL path]])
        {
            NSDictionary *existingPersistentStoreMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType: NSSQLiteStoreType
                                                                                                                       URL: storeURL
                                                                                                                     error: &error];
            
            if (!existingPersistentStoreMetadata)
            {
                // Something *really* bad has happened to the persistent store
                [NSException raise: NSInternalInconsistencyException
                            format: @"Failed to read metadata for persistent store %@: %@", storeURL, error];
            }
            
            if (![managedObjectModel isConfiguration: nil compatibleWithStoreMetadata: existingPersistentStoreMetadata])
            {
                if ([[NSFileManager defaultManager] removeItemAtURL: storeURL
                                                               error: &error])
                {
                    DebugLog(@"Existing database - incompatible schema detected, so deleted");
                }
                else
                {
                    DebugLog(@"*** Could not delete persistent store, %@", error);
                }
            } // else the existing persistent store is compatible with the current model - nice!
        } // else no database file yet

        NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                            configuration: nil
                                                                                      URL: storeURL
                                                                                  options: nil
                                                                                    error: &error];
        if (store == nil)
        {
            DebugLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
        }
    });
    
    // Registries
    
    _mainRegistry = [SYNMainRegistry registry];
    _searchRegistry = [SYNSearchRegistry registry];
    _userRegistry = [SYNUserInfoRegistry registry];
}


- (void) resetCoreDataStack
{
    NSError * error;
    // retrieve the store URL
    NSURL * storeURL = [[self.privateManagedObjectContext persistentStoreCoordinator] URLForPersistentStore: [[[self.privateManagedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    
    // lock the current context
    [self.privateManagedObjectContext lock];
    
    //to drop pending changes (in all contexts)
    [self.privateManagedObjectContext reset];
    [self.mainManagedObjectContext reset];
    [self.searchManagedObjectContext reset];
    
    //delete the store from the current managedObjectContext
    if ([[self.privateManagedObjectContext persistentStoreCoordinator] removePersistentStore: [[[self.privateManagedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error: &error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL: storeURL
                                                  error: &error];
        
        //recreate the store like in the  appDelegate method
        [[self.privateManagedObjectContext persistentStoreCoordinator] addPersistentStoreWithType: NSSQLiteStoreType
                                                                                    configuration: nil
                                                                                              URL: storeURL
                                                                                          options: nil
                                                                                            error: &error];
    }
    
    [self.privateManagedObjectContext unlock];
}


// Save the main context first (propagating the changes to the private) and then the private
- (void) saveContext: (BOOL) wait
{
    // If we don't have a valid MOC, then bail
    if (!self.mainManagedObjectContext)
        return;
    
    if ([self.mainManagedObjectContext hasChanges])
    {
        [self.mainManagedObjectContext performBlockAndWait:^
         {
             NSError *error = nil;
             ZAssert([self.mainManagedObjectContext save: &error], @"Error saving Main moc: %@\n%@",
                     [error localizedDescription], [error userInfo]);
         }];
    }
    
    void (^savePrivate) (void) = ^
    {
        NSError *error = nil;
        ZAssert([self.privateManagedObjectContext save: &error], @"Error saving Private moc: %@\n%@",
                [error localizedDescription], [error userInfo]);
    };
    
    if ([self.privateManagedObjectContext hasChanges])
    {
        if (wait)
        {
            [self.privateManagedObjectContext performBlockAndWait: savePrivate];
        }
        else
        {
            [self.privateManagedObjectContext performBlock: savePrivate];
        }
    }
}

-(void) saveSearchContext
{
    if(!self.searchManagedObjectContext)
        return;
    
    if([self.searchManagedObjectContext hasChanges])
    {
        NSError *error = nil;
        ZAssert([self.searchManagedObjectContext save: &error], @"Error saving Search moc: %@\n%@",
                [error localizedDescription], [error userInfo]);
    }
}


#pragma mark - Network engine suport

- (void) initializeNetworkEngine
{
    self.networkEngine = [[SYNNetworkEngine alloc] initWithDefaultSettings];
    [self.networkEngine useCache];
    
    // Use this engine as the default for the asynchronous image loading category on UIImageView
    UIImageView.defaultEngine = self.networkEngine;
    
    // TODO: Replace this shameful piece of hackery
    UIImageView.defaultEngine2 = self.networkEngine;
    
}


- (void) createDefaultUser
{
    // See if we have already created a default user object, and if not create one
    NSError *error = nil;
    NSEntityDescription *channelOwnerEntity = [NSEntityDescription entityForName: @"ChannelOwner"
                                                          inManagedObjectContext: self.mainManagedObjectContext];
    
    // Find out how many Video objects we have in the database
    NSFetchRequest *channelOwnerFetchRequest = [[NSFetchRequest alloc] init];
    [channelOwnerFetchRequest setEntity: channelOwnerEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == 666"];
    [channelOwnerFetchRequest setPredicate: predicate];
    
    NSArray *channelOwnerEntries = [self.mainManagedObjectContext executeFetchRequest: channelOwnerFetchRequest
                                                                                error: &error];
    
    if (channelOwnerEntries.count > 0)
    {
        self.channelOwnerMe = (ChannelOwner *)channelOwnerEntries[0];
    }
    else
    {
        ChannelOwner *channelOwnerMe = [ChannelOwner insertInManagedObjectContext: self.mainManagedObjectContext];
        
        channelOwnerMe.name = @"PAUL CACKETT";
        channelOwnerMe.uniqueId = @"666";
        channelOwnerMe.thumbnailURL = @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Paul.png";
        
        self.channelOwnerMe = channelOwnerMe;
    }
}


@end
