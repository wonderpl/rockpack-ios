//
//  SYNAppDelegate.m
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNBottomTabViewController.h"
#import "SYNLoginViewController.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "TestFlight.h"
#import "UIImageView+ImageProcessing.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "UncaughtExceptionHandler.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNActivityManager.h"


@interface SYNAppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *searchManagedObjectContext;
@property (nonatomic, strong) SYNLoginViewController* loginViewController;
@property (nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;

@end

@implementation SYNAppDelegate

@synthesize mainRegistry = _mainRegistry, searchRegistry = _searchRegistry;
@synthesize currentUser = _currentUser, currentOAuth2Credentials = _currentOAuth2Credentials;

- (BOOL) application:(UIApplication *) application
         didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    // Install our exception handler (must happen on the next turn through the event loop - as opposed to right now)
    [self performSelector: @selector(installUncaughtExceptionHandler)
               withObject: nil
               afterDelay: 0];
    
    // Se up core data
    [self initializeCoreDataStack];
    
    
    
    // Create default user
    [self createDefaultUser];
    
    
    
    
    // == Get User and Check Token == //
    
    
    
    // Set up network engine
    [self initializeNetworkEngines];
    
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
    
    
    self.masterViewController = [[SYNMasterViewController alloc] initWithRootViewController:bottomTabVC];
    
    self.loginViewController = [[SYNLoginViewController alloc] init];
    
    
    [self.window makeKeyAndVisible];
    
    
    if(self.currentUser && self.currentOAuth2Credentials) {
        
        if([self.currentOAuth2Credentials hasExpired]) {
            
            // renew
            
            
        }
        
        self.window.rootViewController = self.masterViewController;
        return YES;
    }
    
    
    self.window.rootViewController = self.loginViewController;
    
    return YES;
}


-(void)logout
{
    
    if(!self.currentUser || !self.currentUser.current)
        return;
    
    self.currentUser.current = @(NO);
    
    [self saveContext:YES];
    
    [self.currentOAuth2Credentials removeFromKeychain];
    
    self.currentOAuth2Credentials = nil;
    _currentUser = nil;
    
    self.loginViewController = [[SYNLoginViewController alloc] init];
    
    
    self.window.rootViewController = self.loginViewController;
    
    
    
}

-(void)loginCompleted:(NSNotification*)notification
{
    
    self.window.rootViewController = self.masterViewController;
    
    self.loginViewController = nil;
}

#pragma mark - App Delegate Methods

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
    
    if(self.loginViewController.state == kLoginScreenStateInitial) {
        [self.loginViewController setUpInitialState];
    }
    
    //accessTokenData.accessToken;
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
    
    _mainRegistry = [SYNMainRegistry registry];
    _searchRegistry = [SYNSearchRegistry registry];
}


- (void) resetCoreDataStack
{
//    NSError * error;
//    // retrieve the store URL
//    NSURL * storeURL = [[self.privateManagedObjectContext persistentStoreCoordinator] URLForPersistentStore: [[[self.privateManagedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
//    
//    // lock the current context
//    [self.privateManagedObjectContext lock];
//
//    [self.searchManagedObjectContext reset];
//    [self.mainManagedObjectContext reset];
//    [self.privateManagedObjectContext reset];
//    
//    //delete the store from the current managedObjectContext
//    if ([[self.privateManagedObjectContext persistentStoreCoordinator] removePersistentStore: [[[self.privateManagedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error: &error])
//    {
//        // remove the file containing the data
//        [[NSFileManager defaultManager] removeItemAtURL: storeURL
//                                                  error: &error];
//        
//        //recreate the store like in the  appDelegate method
//        [[self.privateManagedObjectContext persistentStoreCoordinator] addPersistentStoreWithType: NSSQLiteStoreType
//                                                                                    configuration: nil
//                                                                                              URL: storeURL
//                                                                                          options: nil
//                                                                                            error: &error];
//    }
//
//    [self.privateManagedObjectContext unlock];
//    
//    [self saveContext: TRUE];

    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName: @"AbstractCommon"
                                                         inManagedObjectContext: self.mainManagedObjectContext];
    [fetchRequest setEntity: entityDescription];
    
    NSError* error = nil;
    NSArray * managedObjects = [self.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                         error: &error];
    
    for (id managedObject in managedObjects)
    {
        [self.mainManagedObjectContext deleteObject: managedObject];
    }
    
    [self saveContext: TRUE];
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

- (void) initializeNetworkEngines
{
    self.networkEngine = [[SYNNetworkEngine alloc] initWithDefaultSettings];
    [self.networkEngine useCache];
    
    self.oAuthNetworkEngine = [[SYNOAuthNetworkEngine alloc] initWithDefaultSettings];
    
    [self.oAuthNetworkEngine useCache];
    
    // Use this engine as the default for the asynchronous image loading category on UIImageView
    UIImageView.defaultEngine = self.networkEngine;
    
    // TODO: Replace this shameful piece of hackery
    UIImageView.defaultEngine2 = self.networkEngine;
    
}

#pragma mark - Clearing Data

-(void)clearData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VideoInstance"
                                              inManagedObjectContext:self.mainManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&error];
                          
    for (NSManagedObject* objectToDelete in items) {
        
        [self.mainManagedObjectContext deleteObject:objectToDelete];
    }
    
    [self saveContext:YES];
   
}
-(void)deleteDataObject:(NSManagedObject*)managedObject
{
    [self.mainManagedObjectContext deleteObject:managedObject];
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
        
        channelOwnerMe.displayName = @"PAUL CACKETT";
        channelOwnerMe.uniqueId = @"666";
        channelOwnerMe.thumbnailURL = @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Paul.png";
        
        self.channelOwnerMe = channelOwnerMe;
    }
}

#pragma mark - User and Credentials

-(User*)currentUser
{
    if(!_currentUser)
    {
        NSError *error = nil;
        NSEntityDescription *userEntity = [NSEntityDescription entityForName: @"User"
                                                      inManagedObjectContext: self.mainManagedObjectContext];
        
        
        NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
        [userFetchRequest setEntity: userEntity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"current == %@", @(YES)];
        [userFetchRequest setPredicate: predicate];
        
        
        NSArray *userEntries = [self.mainManagedObjectContext executeFetchRequest:userFetchRequest
                                                                            error:&error];
        
        if(userEntries.count > 0)
        {
            _currentUser = (User*)userEntries[0];
        }
        else
        {
            DebugLog(@"No Current User Found in AppDelegate...");
            _currentUser = nil;
        }
    }
    
    return _currentUser;
}

-(SYNOAuth2Credential*)currentOAuth2Credentials
{
    if(!self.currentUser)
        return nil;
    
    if(!_currentOAuth2Credentials)
    {
        
        _currentOAuth2Credentials = [SYNOAuth2Credential credentialFromKeychainForService: kOAuth2Service
                                                                                  account: self.currentUser.uniqueId];
    }
    
    return _currentOAuth2Credentials;
}

#pragma mark - Social Integration Delegate

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[FBSession activeSession] handleOpenURL:url];
    return YES;
}

@end
