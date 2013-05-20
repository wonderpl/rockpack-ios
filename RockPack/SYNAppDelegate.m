//
//  SYNAppDelegate.m
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNLoginViewController.h"
#import "SYNLoginViewControllerIphone.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoPlaybackViewController.h"
#import "TestFlight.h"
#import "UIImageView+ImageProcessing.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "UncaughtExceptionHandler.h"
#import <FacebookSDK/FacebookSDK.h>
//#import <XRay/XRay.h>
#import <objc/runtime.h>

extern void instrumentObjcMessageSends(BOOL);


@interface SYNAppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *searchManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *channelsManagedObjectContext;

@property (nonatomic, strong) SYNLoginBaseViewController* loginViewController;
@property (nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;
@property (nonatomic, strong) NSString *userAgentString;
@property (nonatomic, strong) SYNVideoQueue* videoQueue;
@property (nonatomic, strong) SYNChannelManager* channelManager;


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
    
    // Interesting trick to get the user agent string (so that we can send (rough) details about what platform and version of the OS
    // will be similar to... "Mozilla/5.0 (iPad; CPU OS 6_1 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10B141"
    UIWebView *webView = [[UIWebView alloc]initWithFrame: CGRectZero];
    NSString *completeUserAgentString = [webView stringByEvaluatingJavaScriptFromString: @"navigator.userAgent"];
    
    NSString *bundleAndVersionString = [NSString stringWithFormat:@"%@/%@",
                                        [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleNameKey],
                                        [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey]];

    // We just want the bit in-between the first set of brackets
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString: @"()"];
    
    NSArray *agentSubStrings = [completeUserAgentString componentsSeparatedByCharactersInSet: separatorSet];
    
    if (agentSubStrings.count > 1)
    {
        self.userAgentString = [NSString stringWithFormat: @"%@ (%@)", bundleAndVersionString, agentSubStrings [1]];
    }
    else
    {
        // Shouldn't happen, but programming defensively
        self.userAgentString = bundleAndVersionString;
    }
    
    // Automatically send uncaught exceptions to Google Analytics.
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval 
    [GAI sharedInstance].dispatchInterval = 30;
    
    // Set debug to YES to enable  extra debugging information.
//    [GAI sharedInstance].debug = YES;
    
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId: kGoogleAnalyticsId];
    
    // Se up CoreData // 
    [self initializeCoreDataStack];

    
    
    // Video Queue View Controller //
    self.videoQueue = [SYNVideoQueue queue];
    
    
    // Subscriptions Manager //
    self.channelManager = [SYNChannelManager manager];
    
    
    // Network Engine //
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
    [self.window makeKeyAndVisible];
    
    /// Initialise our video players
    // Perhaps asynchronous is a bad idea, as someone could play the video before it has been fully constructed
//    dispatch_async(dispatch_get_main_queue(), ^{
        [SYNVideoPlaybackViewController sharedInstance];
//    });
    
    if (self.currentUser && self.currentOAuth2Credentials) {
        
        // If we have a user and a refresh token... // 
        if ([self.currentOAuth2Credentials hasExpired]) {
            
            [self.oAuthNetworkEngine refreshOAuthTokenWithCompletionHandler:^(id response) {
            
                self.window.rootViewController = [self createAndReturnRootViewController];
                
            } errorHandler:^(id response) {
                
                self.window.rootViewController = [self createAndReturnLoginViewController];
                
                
            }];
            
            return YES;
            
        // else if we have an access token // 
        } else {
            
            self.window.rootViewController = [self createAndReturnRootViewController];
            return YES;
            
        }
    }
    else
    {
        self.window.rootViewController = [self createAndReturnLoginViewController];
        return YES;
    }
    
    return YES;
}

-(UIViewController*)createAndReturnRootViewController
{
    SYNContainerViewController* containerViewController = [[SYNContainerViewController alloc] init];
    
    
    self.masterViewController = [[SYNMasterViewController alloc] initWithContainerViewController:containerViewController];
    
    return self.masterViewController;
}

-(UIViewController*)createAndReturnLoginViewController
{
    if([[SYNDeviceManager sharedInstance] isIPad])
    {
        self.loginViewController = [[SYNLoginViewController alloc] init];
    }
    else
    {
        self.loginViewController = [[SYNLoginViewControllerIphone alloc] init];
    }
    
    return self.loginViewController;
}


-(void)logout
{
    
    if(!self.currentUser || !self.currentUser.current)
        return;
    
    self.currentUser.currentValue = NO;
    
    [self clearCoreDataMainEntities:YES];
    
    
    self.currentOAuth2Credentials = nil;
    _currentUser = nil;
    
    
    self.window.rootViewController = [self createAndReturnLoginViewController];
    
    
    
}

-(void)loginCompleted:(NSNotification*)notification
{
    
    self.window.rootViewController = [self createAndReturnRootViewController];
    
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
    
    NSError* error;
    
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
    NSPersistentStore* searchStore = [searchPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                                    configuration:nil
                                                                                              URL:nil
                                                                                          options:nil
                                                                                            error:&error];
    ZAssert(searchStore, @"Failed to initialize search managed context in app delegate");
    self.searchManagedObjectContext.persistentStoreCoordinator = searchPersistentStoreCoordinator;
    
    
    
    // == Channel Context
    
    self.channelsManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *channelsPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSPersistentStore* channelsStore = [channelsPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                                        configuration:nil
                                                                                                  URL:nil
                                                                                              options:nil
                                                                                                error:&error];
    
    ZAssert(channelsStore, @"Failed to initialize channels managed context in app delegate");
    self.channelsManagedObjectContext.persistentStoreCoordinator = channelsPersistentStoreCoordinator;
    
    

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


// Save the main context first (propagating the changes to the private) and then the private
- (void) saveContext: (BOOL) wait
{
    
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
    
    if([self.searchManagedObjectContext hasChanges])
    {
        NSError *error = nil;
        ZAssert([self.searchManagedObjectContext save: &error], @"Error saving Search moc: %@\n%@",
                [error localizedDescription], [error userInfo]);
    }
}

-(void) saveChannelsContext
{
    if(!self.channelsManagedObjectContext)
        return;
    
    if([self.channelsManagedObjectContext hasChanges])
    {
        NSError *error = nil;
        ZAssert([self.channelsManagedObjectContext save: &error], @"Error saving Search moc: %@\n%@",
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

-(void)clearCoreDataMainEntities:(BOOL)userBound
{
    
    NSError *error;
    NSArray *itemsToDelete;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // == Clear VideoInstances == //
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"VideoInstance"
                                        inManagedObjectContext:self.mainManagedObjectContext]];
    
    
    itemsToDelete = [self.mainManagedObjectContext executeFetchRequest:fetchRequest
                                                                 error:&error];
    
    for (NSManagedObject* objectToDelete in itemsToDelete) {
        
        [self.mainManagedObjectContext deleteObject:objectToDelete];
    }
    
    
    // == Clear Channels == //
    
    if(!userBound)
    {
        NSPredicate* notUserChannels = [NSPredicate predicateWithFormat:@"channelOwner.uniqueId != %@ AND subscribedByUser != YES", self.currentUser.uniqueId];
        [fetchRequest setPredicate:notUserChannels];
    }
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Channel"
                                        inManagedObjectContext:self.mainManagedObjectContext]];
    
    itemsToDelete = [self.mainManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject* objectToDelete in itemsToDelete) {
        
        [self.mainManagedObjectContext deleteObject:objectToDelete];
    }
    
    
    [self saveContext:YES];
    
    if(!userBound)
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kClearedLocationBoundData
                                                            object:self];
    }
}




-(void)deleteDataObject:(NSManagedObject*)managedObject
{
    [self.mainManagedObjectContext deleteObject:managedObject];
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

-(void)setCurrentOAuth2Credentials:(SYNOAuth2Credential *)nCurrentOAuth2Credentials
{
    [_currentOAuth2Credentials removeFromKeychain];
    
    if(!self.currentUser)
    {
        _currentOAuth2Credentials = nil;
        DebugLog(@"Tried to save credentials without an active user");
        return;
    }
    
    _currentOAuth2Credentials = nCurrentOAuth2Credentials;
    
    if(_currentOAuth2Credentials != nil)
    {
        [_currentOAuth2Credentials saveToKeychainForService:kOAuth2Service
                                                    account:self.currentUser.uniqueId];
    }
    
    
    
    
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


// Used to force a refresh of the credentials
- (void) resetCurrentOAuth2Credentials
{
    _currentOAuth2Credentials = nil;
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
