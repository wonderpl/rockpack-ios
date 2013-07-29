//
//  SYNAppDelegate.m
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#if DEBUG
#import <SparkInspector/SparkInspector.h>
#endif

#import "AppConstants.h"
#import "Appirater.h"
#import "ChannelOwner.h"
#import "Channel.h"
#import "GAI.h"
#import "GoogleConversionPing.h"
#import "NSObject+Blocks.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNLoginViewController.h"
#import "SYNLoginViewControllerIphone.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoPlaybackViewController.h"
#import "TestFlight.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "UncaughtExceptionHandler.h"
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SYNAppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext *channelsManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *searchManagedObjectContext;
@property (nonatomic, strong) NSString *apnsToken;
@property (nonatomic, strong) NSString *userAgentString;
@property (nonatomic, strong) SYNChannelManager *channelManager;
@property (nonatomic, strong) SYNLoginBaseViewController *loginViewController;
@property (nonatomic, strong) SYNMasterViewController *masterViewController;
@property (nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;
@property (nonatomic, strong) SYNOnBoardingPopoverQueueController *onBoardingQueue;
@property (nonatomic, strong) SYNVideoQueue *videoQueue;
@property (nonatomic, strong) SYNViewStackManager *viewStackManager;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSURLConnection *connection;

@end


@implementation SYNAppDelegate

// Required, as we are providing both getter and setter
@synthesize  currentOAuth2Credentials = _currentOAuth2Credentials;

- (BOOL)	 application: (UIApplication *) application
         didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
#ifdef ENABLE_USER_RATINGS
    [Appirater setAppId: @"660697542"];
    [Appirater setDaysUntilPrompt: 3];
    [Appirater setUsesUntilPrompt: 3];
    [Appirater setSignificantEventsUntilPrompt: 1];
    [Appirater setTimeBeforeReminding: 20];
    //    [Appirater setDebug: YES];
#endif
    
    // Enable the Spark Inspector
#if DEBUG
    [SparkInspector enableObservation];
#endif
    
#if USEUDID
    //    [TestFlight setDeviceIdentifier: [[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
    
    //Google Adwords conversion tracking. TODO: check parameters with Guy!!
    [GoogleConversionPing pingWithConversionId: @"983664386"
                                         label: @"Km3nCP6G-wQQgo6G1QM"
                                         value: @"0"
                                  isRepeatable: NO];
    
    // We need to set the audio session so that that app will continue to play audio even if the mute switch is on
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    
    if (![audioSession setCategory: AVAudioSessionCategoryPlayback
                             error: &setCategoryError])
    {
        DebugLog(@"Error setting AVAudioSessionCategoryPlayback: %@", setCategoryError);
    }
    
    // Install our exception handler (must happen on the next turn through the event loop - as opposed to right now)
    [self performSelector: @selector(installUncaughtExceptionHandler)
               withObject: nil
               afterDelay: 0];
    
    // Interesting trick to get the user agent string (so that we can send (rough) details about what platform and version of the OS
    // will be similar to... "Mozilla/5.0 (iPad; CPU OS 6_1 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10B141"
    UIWebView *webView = [[UIWebView alloc]initWithFrame: CGRectZero];
    NSString *completeUserAgentString = [webView stringByEvaluatingJavaScriptFromString: @"navigator.userAgent"];
    
    NSString *bundleAndVersionString = [NSString stringWithFormat: @"%@/%@",
                                        [[NSBundle mainBundle] infoDictionary][(NSString *) kCFBundleNameKey],
                                        [[NSBundle mainBundle] infoDictionary][(NSString *) kCFBundleVersionKey]];
    
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
    
    // Se up CoreData //
    [self initializeCoreDataStack];
    
    // Video Queue View Controller //
    self.videoQueue = [SYNVideoQueue queue];
    
    // Subscriptions Manager //
    self.channelManager = [SYNChannelManager manager];
    
    self.onBoardingQueue = [SYNOnBoardingPopoverQueueController queueController];
    
    // ViewStack Manager //
    self.viewStackManager = [SYNViewStackManager manager];
    
    // Network Engine //
    [self initializeNetworkEngines];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loginCompleted:)
                                                 name: kLoginCompleted
                                               object: nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Create a dictionary of defaults to add and register them (if they have not already been set)
    NSDictionary *initDefaults = @{kDownloadedVideoContentBool: @(NO)};
    
    [defaults registerDefaults: initDefaults];
    
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    // Initialise our video player, which ensures that it will be fully set up by the time the first video is played.
    // Tried doing this asynchronously, but could nto guarantee that it was initialised by the time that the first
    // video playback occurred
    
    // First we need to ensure that we have the player JS in place
    [self copyFileFromAppBundleToDocumentsDirectory: @"YouTubeIFramePlayer"
                                             ofType: @"html"];
    
    // Now cause the playback controller to be instantiated
    [SYNVideoPlaybackViewController sharedInstance];
    
    if (self.currentUser && self.currentOAuth2Credentials)
    {
        // If we have a user and a refresh token... //
        if ([self.currentOAuth2Credentials hasExpired])
        {
            [self refreshExpiredTokenOnStartup];
            
        }
        else // we have an access token //
        {
            // set timer for auto refresh //
            
            [self setTokenExpiryTimer];
            
            [self refreshFacebookSession];
            
            self.window.rootViewController = [self createAndReturnRootViewController];
            
            
        }
    }
    else
    {
        if(self.currentUser || self.currentOAuth2Credentials)
        {
            [self logout];
        }
        self.window.rootViewController = [self createAndReturnLoginViewController];
    }
    
#ifdef ENABLE_USER_RATINGS
    [Appirater appLaunched: YES];
#endif
    
    return YES;
}

-(void)refreshFacebookSession
{
    // link to facebook
    
    
    if(self.currentUser.facebookAccountUrl)
    {
        if(!FBSession.activeSession.isOpen)
        {
            [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                
                DebugLog(@"*** Complete! %@", session);
                
                
                
            }];
        }
        else
        {
            [self.oAuthNetworkEngine getExternalAccountForUrl:self.currentUser.facebookAccountUrl completionHandler:^(id response) {
                
                NSDictionary* external_accounts = response[@"external_accounts"];
                
                NSArray* accounts = external_accounts ? external_accounts[@"items"] : nil;
                
                if(accounts && accounts.count > 0)
                {
                    NSDictionary* facebookAccount = (NSDictionary*)accounts[0];
                    if(facebookAccount)
                    {
                        self.currentUser.facebookToken = facebookAccount[@"external_token"];
                    }
                    
                }
                
                if(self.currentUser.facebookToken)
                {
                    [[SYNFacebookManager sharedFBManager] openSessionFromExistingToken:self.currentUser.facebookToken
                                                                             onSuccess:^{
                                                                                 
                                                                                 
                                                                                 
                                                                             } onFailure:^(NSString *errorMessage) {
                                                                                 
                                                                             }];
                }
                
            } errorHandler:^(id error) {
                
            }];
        }
        
    }
}

- (void) setTokenExpiryTimer
{
    if (self.tokenExpiryTimer)
    {
        [self.tokenExpiryTimer invalidate];
    }
    
    NSTimeInterval intervalToExpiry = [self.currentOAuth2Credentials.expirationDate timeIntervalSinceNow];
    
    self.tokenExpiryTimer = [NSTimer scheduledTimerWithTimeInterval: intervalToExpiry
                                                             target: self
                                                           selector: @selector(refreshExpiredToken)
                                                           userInfo: nil
                                                            repeats: NO];
}


- (void) refreshExpiredTokenOnStartup
{
    //Add imageview to the window as placeholder while we wait for the token refresh call.
    [self.tokenExpiryTimer invalidate];
    
    UIImageView *startImageView = nil;
    CGPoint startImageCenter = self.window.center;
    
    if (IS_IPAD)
    {
        if (UIDeviceOrientationIsLandscape([[SYNDeviceManager sharedInstance] currentOrientation]))
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default-Landscape"]];
            
            if ([[SYNDeviceManager sharedInstance] currentOrientation] == UIDeviceOrientationLandscapeLeft)
            {
                startImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                startImageCenter.x -= 10;
            }
            else
            {
                startImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                startImageCenter.x += 10;
            }
        }
        else
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default-Portrait"]];
            startImageCenter.y += 10;
        }
    }
    else
    {
        if ([SYNDeviceManager.sharedInstance currentScreenHeight] > 480.0f)
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default-568h"]];
        }
        else
        {
            startImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Default"]];
        }
    }
    
    [self.window
     addSubview: startImageView];
    startImageView.center = startImageCenter;
    
    
    //refresh token
    [self.oAuthNetworkEngine refreshOAuthTokenWithCompletionHandler: ^(id response) {
        
        if (!self.window.rootViewController)
        {
            self.window.rootViewController = [self createAndReturnRootViewController];
        }
        
        [startImageView removeFromSuperview];
        
        self.tokenExpiryTimer = nil;
        
        [self refreshFacebookSession];
        
        
    } errorHandler: ^(id response) {
        [self logout];
        
        self.tokenExpiryTimer = nil;
        
        if (!self.window.rootViewController)
        {
            self.window.rootViewController = [self createAndReturnLoginViewController];
        }
        
        [startImageView removeFromSuperview];
    }];
}


- (void) refreshExpiredToken
{
    [self.tokenExpiryTimer invalidate];
    
    self.tokenExpiryTimer = nil;
    
    [self.oAuthNetworkEngine
     refreshOAuthTokenWithCompletionHandler: ^(id response) {
     }
     errorHandler: ^(id response) {
         [self logout];
     }];
}


- (UIViewController *) createAndReturnRootViewController
{
    SYNContainerViewController *containerViewController = [[SYNContainerViewController alloc] init];
    
    self.masterViewController = [[SYNMasterViewController alloc] initWithContainerViewController: containerViewController];
    
    return self.masterViewController;
}


- (UIViewController *) createAndReturnLoginViewController
{
    if (IS_IPAD)
    {
        self.loginViewController = [[SYNLoginViewController alloc] init];
    }
    else
    {
        self.loginViewController = [[SYNLoginViewControllerIphone alloc] init];
    }
    
    return self.loginViewController;
}


- (void) logout
{
    
    self.masterViewController = nil;
    
    [self.currentOAuth2Credentials removeFromKeychain];
    
    [self.tokenExpiryTimer invalidate];
    self.tokenExpiryTimer = nil;
    
    [[SYNFacebookManager sharedFBManager] logoutOnSuccess: ^{
    }
                                                onFailure: ^(NSString *errorMessage) {
                                                }];
    
    self.currentOAuth2Credentials = nil;
    
    _currentUser = nil;
    
    [self nukeCoreData];
    
    self.window.rootViewController = [self createAndReturnLoginViewController];
}


- (void) loginCompleted: (NSNotification *) notification
{
    self.window.rootViewController = [self createAndReturnRootViewController];
    
    self.loginViewController = nil;
    
    // At this point we should update out APNS token (if we actually have one)
    if (self.currentUser && self.apnsToken)
    {
        [self.oAuthNetworkEngine updateApplePushNotificationForUserId: self.currentUser.uniqueId
                                                                token: self.apnsToken
                                                    completionHandler: ^(NSDictionary *dictionary) {
                                                        DebugLog(@"Apple push notification token update successful");
                                                    }
                                                         errorHandler: ^(NSError *error) {
                                                             DebugLog(@"Apple push notification token update failed");
                                                         }];
    }
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
    [self.tokenExpiryTimer invalidate];
    self.tokenExpiryTimer = nil;
}


- (void) applicationWillEnterForeground: (UIApplication *) application
{
    if (self.loginViewController)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if (self.loginViewController.state == kLoginScreenStateInitial)
        {
            [self.loginViewController setUpInitialState];
        }
        else if (self.loginViewController.state == kLoginScreenStateLogin)
        {
            [self.loginViewController reEnableLoginControls];
        }
    }
    else
    {
        if(self.currentOAuth2Credentials)
        {
            NSTimeInterval refreshTimeout = [self.currentOAuth2Credentials.expirationDate timeIntervalSinceNow];
        
            if (refreshTimeout < kOAuthTokenExpiryMargin)
            {
                [self refreshExpiredToken];
            }
            else
            {
                [self setTokenExpiryTimer];
            }
    }
    }
}


- (void) applicationDidBecomeActive: (UIApplication *) application
{
    NSString *facebookAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"FacebookAppID"];
    
    [FBSettings publishInstall: facebookAppId];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.loginViewController)
    {
        [self.loginViewController applicationResume];
    }
    
    [self checkForUpdatedPlayerCode];
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
    
    // Automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 30;
    [GAI sharedInstance].defaultTracker.sessionTimeout = 300; // was 30
    
    // Set debug to YES to enable  extra debugging information.
    [GAI sharedInstance].debug = NO;
    
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId: kGoogleAnalyticsId];
}


#pragma mark - Core Data stack

- (void) initializeCoreDataStack
{
    NSError *error;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"Rockpack"
                                              withExtension: @"momd"];
    
    if (!modelURL)
    {
        AssertOrLog(@"Failed to find model URL");
    }
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    
    if (!managedObjectModel)
    {
        AssertOrLog(@"Failed to initialize model");
    }
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    
    if (!persistentStoreCoordinator)
    {
        AssertOrLog(@"Failed to initialize persistent store coordinator");
    }
    
    // == Main Context
    self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    self.privateManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    self.mainManagedObjectContext.parentContext = self.privateManagedObjectContext;
    
    // == Search Context
    self.searchManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *searchPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    NSPersistentStore *searchStore = [searchPersistentStoreCoordinator addPersistentStoreWithType: NSInMemoryStoreType
                                                                                    configuration: nil
                                                                                              URL: nil
                                                                                          options: nil
                                                                                            error: &error];
    
    if (!searchStore)
    {
        AssertOrLog(@"Failed to initialize search managed context in app delegate");
    }
    
    self.searchManagedObjectContext.persistentStoreCoordinator = searchPersistentStoreCoordinator;

    // == Channel Context
    self.channelsManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    NSPersistentStoreCoordinator *channelsPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    NSPersistentStore *channelsStore = [channelsPersistentStoreCoordinator addPersistentStoreWithType: NSInMemoryStoreType
                                                                                        configuration: nil
                                                                                                  URL: nil
                                                                                              options: nil
                                                                                                error: &error];
    
    if (!channelsStore)
    {
        AssertOrLog(@"Failed to initialize channels managed context in app delegate");
    }
    
    self.channelsManagedObjectContext.persistentStoreCoordinator = channelsPersistentStoreCoordinator;
    
    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                              inDomains: NSUserDomainMask] lastObject];
    
    storeURL = [storeURL URLByAppendingPathComponent: @"Rockpack.sqlite"];
    
    //Try to migrate
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                                        configuration: nil
                                                                                  URL: storeURL
                                                                              options: @{NSInferMappingModelAutomaticallyOption: @(YES), NSMigratePersistentStoresAutomaticallyOption: @(YES)}
                                                                                error: &error];
    
    if (error)
    {
        if ([[NSFileManager defaultManager] removeItemAtURL: storeURL
                                                      error: &error])
        {
            DebugLog(@"Existing database - migration failed so deleted");
        }
        else
        {
            DebugLog(@"*** Could not delete persistent store, %@", error);
        }
        
        store = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                         configuration: nil
                                                                   URL: storeURL
                                                               options: @{NSMigratePersistentStoresAutomaticallyOption: @(YES)}
                                                                 error: &error];
    }
    
    if (store == nil)
    {
        DebugLog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    _mainRegistry = [SYNMainRegistry registry];
    _searchRegistry = [SYNSearchRegistry registry];
}


-(void)nukeCoreData
{
    _mainRegistry = nil;
    _searchRegistry = nil;
    self.mainManagedObjectContext = nil;
    self.privateManagedObjectContext = nil;
    self.searchManagedObjectContext = nil;
    self.channelsManagedObjectContext = nil;
    self.oAuthNetworkEngine = nil;
    self.networkEngine = nil;
    
    
    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                              inDomains: NSUserDomainMask] lastObject];
    
    storeURL = [storeURL URLByAppendingPathComponent: @"Rockpack.sqlite"];
    
    NSError* error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL: storeURL
                                                  error: &error])
    {
        [self initializeCoreDataStack];
        [self initializeNetworkEngines];
        // Video Queue //
        self.videoQueue = [SYNVideoQueue queue];
        
        // Subscriptions Manager //
        self.channelManager = [SYNChannelManager manager];
    }
    else
    {
        AssertOrLog(@"*** Could not delete persistent store, %@", error);
    }
    
    
}

// Save the main context first (propagating the changes to the private) and then the private
- (void) saveContext: (BOOL) wait
{
    if ([self.mainManagedObjectContext hasChanges])
    {
        [self.mainManagedObjectContext
         performBlockAndWait: ^
         {
             NSError *error = nil;
             
             if (![self.mainManagedObjectContext
                   save: &error])
             {
                 AssertOrLog(@"Error saving Main moc: %@\n%@", [error localizedDescription], [error userInfo]);
             }
         }];
    }
    
    void (^ savePrivate) (void) = ^
    {
        NSError *error = nil;
        
        if (![self.privateManagedObjectContext
              save: &error])
        {
            AssertOrLog(@"Error saving Private moc: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    };
    
    if ([self.privateManagedObjectContext hasChanges])
    {
        if (wait)
        {
            [self.privateManagedObjectContext
             performBlockAndWait: savePrivate];
        }
        else
        {
            [self.privateManagedObjectContext
             performBlock: savePrivate];
        }
    }
}


- (void) saveSearchContext
{
    if ([self.searchManagedObjectContext hasChanges])
    {
        NSError *error = nil;
        
        if (![self.searchManagedObjectContext
              save: &error])
        {
            AssertOrLog(@"Error saving Search moc: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}


- (void) saveChannelsContext
{
    if (!self.channelsManagedObjectContext)
    {
        return;
    }
    
    if ([self.channelsManagedObjectContext hasChanges])
    {
        NSError *error = nil;
        
        if (![self.channelsManagedObjectContext
              save: &error])
        {
            AssertOrLog(@"Error saving Channels moc: %@\n%@", [error localizedDescription], [error userInfo]);
        }
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
}


#pragma mark - Clearing Data

- (void) clearCoreDataMainEntities: (BOOL) userBound
{
    NSError *error;
    NSArray *itemsToDelete;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // == Clear VideoInstances == //
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"VideoInstance"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    
    itemsToDelete = [self.mainManagedObjectContext
                     executeFetchRequest: fetchRequest
                     error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext
         deleteObject: objectToDelete];
    }
    
    // == Clear Cover Art == //
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"CoverArt"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    
    itemsToDelete = [self.mainManagedObjectContext
                     executeFetchRequest: fetchRequest
                     error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext
         deleteObject: objectToDelete];
    }
    
    // == Clear Channels == //
    if (!userBound)
    {
        // do not delete data relating to the user such as subscriptions and channels
        NSPredicate *notUserChannels = [NSPredicate predicateWithFormat: @"channelOwner.uniqueId != %@ AND subscribedByUser != YES", self.currentUser.uniqueId];
        [fetchRequest setPredicate: notUserChannels];
    }
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    itemsToDelete = [self.mainManagedObjectContext
                     executeFetchRequest: fetchRequest
                     error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext
         deleteObject: objectToDelete];
    }
    
    fetchRequest.predicate = nil;

    // == Clear Categories (Genres) == //
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Genre"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    fetchRequest.includesSubentities = YES; // to include SubGenre objecst
    
    itemsToDelete = [self.mainManagedObjectContext
                     executeFetchRequest: fetchRequest
                     error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext
         deleteObject: objectToDelete];
    }
    
    // == Clear ChannelOwner == //
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                         inManagedObjectContext: self.mainManagedObjectContext]];
    
    fetchRequest.includesSubentities = NO; // do not include User objects as these are handled elsewhere
    
    itemsToDelete = [self.mainManagedObjectContext
                     executeFetchRequest: fetchRequest
                     error: &error];
    
    for (NSManagedObject *objectToDelete in itemsToDelete)
    {
        [self.mainManagedObjectContext
         deleteObject: objectToDelete];
    }
    
    // == Save == //
    [self saveContext: YES];
    
    if (!userBound)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kClearedLocationBoundData
                                                            object: self];
    }
}


- (void) deleteDataObject: (NSManagedObject *) managedObject
{
    [self.mainManagedObjectContext
     deleteObject: managedObject];
}


#pragma mark - User and Credentials

- (User *) currentUser
{
    if (!_currentUser)
    {
        NSError *error = nil;
        NSEntityDescription *userEntity = [NSEntityDescription entityForName: @"User"
                                                      inManagedObjectContext: self.mainManagedObjectContext];
        
        
        NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
        [userFetchRequest setEntity: userEntity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"current == %@", @(YES)];
        [userFetchRequest setPredicate: predicate];
        
        
        NSArray *userEntries = [self.mainManagedObjectContext
                                executeFetchRequest: userFetchRequest
                                error: &error];
        
        if (userEntries.count > 0)
        {
            _currentUser = (User *) userEntries[0];
            
            if (userEntries.count > 1) // housekeeping, clear duplicate user entries
            {
                for (int u = 1; u < userEntries.count; u++)
                {
                    [self.mainManagedObjectContext
                     deleteObject: ((User *) userEntries[u])];
                }
            }
        }
        else
        {
            DebugLog(@"No Current User Found in AppDelegate...");
            _currentUser = nil;
        }
    }
    
    return _currentUser;
}


- (void) setCurrentOAuth2Credentials: (SYNOAuth2Credential *) nCurrentOAuth2Credentials
{
    [_currentOAuth2Credentials removeFromKeychain];
    
    if (!self.currentUser)
    {
        _currentOAuth2Credentials = nil;
        DebugLog(@"Tried to save credentials without an active user");
        return;
    }
    
    _currentOAuth2Credentials = nCurrentOAuth2Credentials;
    
    if (_currentOAuth2Credentials != nil)
    {
        [_currentOAuth2Credentials saveToKeychainForService: kOAuth2Service
                                                    account: _currentOAuth2Credentials.userId];
    }
}


- (SYNOAuth2Credential *) currentOAuth2Credentials
{
    if (!self.currentUser)
    {
        return nil;
    }
    
    if (!_currentOAuth2Credentials)
    {
        _currentOAuth2Credentials = [SYNOAuth2Credential credentialFromKeychainForService: kOAuth2Service
                                                                                  account: self.currentUser.uniqueId];
        if (!_currentOAuth2Credentials)
        {
            AssertOrLog(@"Detected currentUser data, but no matching OAuth2 credentials");
        }
    }
    
    return _currentOAuth2Credentials;
}


// Used to force a refresh of the credentials
- (void) resetCurrentOAuth2Credentials
{
    _currentOAuth2Credentials = nil;
}


#pragma mark - Social deep linking

- (BOOL) application: (UIApplication *) application
       handleOpenURL: (NSURL *) url
{
    return YES;
}


- (NSDictionary *) parseURLParams: (NSString *) query
{
    NSArray *pairs = [query componentsSeparatedByString: @"&"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *pair in pairs)
    {
        NSRange range = [pair rangeOfString: @"="];
        
        NSString *key = [pair substringToIndex: range.location];
        NSString *value = [pair substringFromIndex: range.location + 1];
        
        params[key] = value;
    }
    
    return params;
}


// rockpack://USERID/
// (test) http://dev.rockpack.com/paulegan/deeplinktest/user.html
// rockpack://USERID/channels/CHANNELID/
// (test) http://dev.rockpack.com/paulegan/deeplinktest/channel.html
// rockpack://USERID/channels/CHANNELID/videos/VIDEOID/
// (test) http://dev.rockpack.com/paulegan/deeplinktest/video.html
// http://share.demo.rockpack.com/s/SXL1kOk

- (BOOL)  application: (UIApplication *) application
              openURL: (NSURL *) url
    sourceApplication: (NSString *) sourceApplication
           annotation: (id) annotation
{
    // Is it one of our own custom 'rockpack' URL schemes
    if ([url.scheme isEqualToString: @"rockpack"])
    {
        BOOL success = FALSE;
        
        NSString *userId = url.host;
        NSArray *pathComponents = url.pathComponents;
        
        NSString *hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey: ([userId isEqualToString: self.currentUser.uniqueId])? @"SecureAPIHostName" : @"APIHostName"];
        
        switch (pathComponents.count)
        {
            // User profile
            case 1:
            {
                if (userId)
                {
                    ChannelOwner *channelOwner = [ChannelOwner instanceFromDictionary: @{@"id" : userId}
                                                            usingManagedObjectContext: self.mainManagedObjectContext
                                                                  ignoringObjectTypes: kIgnoreChannelObjects];
                    
                    [self.viewStackManager viewProfileDetails: channelOwner];
                    success = TRUE;
                }

                break;
            }
            
            // Channel
            case 3:
            {
                // Extract the channelId from the path
                NSString *channelId = pathComponents[2];
                NSString *resourceURL = [NSString stringWithFormat: @"http://%@/ws/%@/channels/%@/", hostName, userId, channelId];
                Channel* channel = [Channel instanceFromDictionary: @{@"id" : channelId, @"resource_url" : resourceURL}
                                         usingManagedObjectContext: self.mainManagedObjectContext];
                
                if (channel)
                {
                    [self.viewStackManager viewChannelDetails: channel];
                    success = TRUE;
                }
                break;
            }
               
            // Video Instance    
            case 5:
            {
                NSString *channelId = pathComponents[2];
                NSString *videoId = pathComponents[4];
                NSString *resourceURL = [NSString stringWithFormat: @"http://%@/ws/%@/channels/%@/", hostName, userId, channelId];
                Channel* channel = [Channel instanceFromDictionary: @{@"id" : channelId, @"resource_url" : resourceURL}
                                         usingManagedObjectContext: self.mainManagedObjectContext];
                
                if (channel)
                {
                    [self.viewStackManager viewChannelDetails: channel
                                               withAutoplayId: videoId];
                    success = TRUE;
                }
                break;
            }
                
            default:
                // Not sure what this is so indicate failure
                break;
        }

        return success;
    }
    else if ([url.scheme hasPrefix: @"fb"])
    {      
        // It appears to be a Facebook URL scheme, so parse the incoming URL to look for a target_url parameter
        NSString *query = [url fragment];
        
        if (!query)
        {
            query = [url query];
        }
        
        NSDictionary *params = [self parseURLParams: query];
        
        // Check if target URL exists
        NSString *targetURLString = [params valueForKey: @"target_url"];
        
        if (targetURLString)
        {
            
            targetURLString = [targetURLString stringByAppendingString: @"&rockpack_redirect=true"];
//            NSURL *targetURL = [NSURL URLWithString: targetURLString];
//            NSString *query2 = [targetURL query];
//            NSDictionary *targetParams = [self parseURLParams: query2];
//            NSString *deeplink = [targetParams valueForKey: @"deeplink"];
//            
//            // Check for the 'deeplink' parameter to check if this is one of
//            // our incoming news feed link
//            if (deeplink)
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"News"
//                                                                message: [NSString stringWithFormat: @"Incoming: %@", deeplink]
//                                                               delegate: nil
//                                                      cancelButtonTitle: @"OK"
//                                                      otherButtonTitles: nil, nil];
//                [alert show];
//            }

//            [NSURL URLWithString: @"rockpack://3-uaHqB1zdmfJfwbKX8Cug/channels/chlkFaa9SsYoxk4S4Kg5vBPQ/videos/viPOzGRLwURrPfZBJNYJ5asw/"]
//            NSURL *targetURL = [NSURL URLWithString: targetURLString];
//            
//            [self performBlock: ^{
//                if ([[UIApplication sharedApplication] canOpenURL: targetURL])
//                {
//                    [[UIApplication sharedApplication] openURL: targetURL];
//                }
//            } afterDelay: 0.1f];
            
            
//            [self.networkEngine resolveFacebookLink:  targetURLString
//                                  completionHandler: ^(NSDictionary *dictionary) {
//                                      NSLog(@"%@",dictionary);
//                                  }
//                                       errorHandler: ^(NSError *error) {
//                                           NSLog(@"%@", error);
//                                       }];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: targetURLString]];
            [request setHTTPMethod: @"GET"];

            self.connection = [[NSURLConnection alloc] initWithRequest: request
                                                              delegate: self];
            


        }
        
        return [FBSession.activeSession
                handleOpenURL: url];
    }
    else
    {
        // No idea what this scheme does so indicated failure
        return NO;
    }
}


#pragma mark -
#pragma mark NSURLConnection delegates

-(void) connection: (NSURLConnection *) connection
        didReceiveResponse:(NSURLResponse *)response
{
}


- (void) connection: (NSURLConnection *) connection
     didReceiveData: (NSData *) data
{
}


- (void) connection: (NSURLConnection *) connection
        didFailWithError: (NSError *) error
{
    DebugLog (@"Failed");
}


- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
}

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) request
             redirectResponse: (NSURLResponse *) redirectResponse
{
    NSURLRequest *newRequest = request;
    
    if (redirectResponse) {
        newRequest = nil;
        
        NSString *location = [(NSHTTPURLResponse *)redirectResponse allHeaderFields][@"Location"];
        
//        NSString *location = redirectResponse.
        
    }
    
    return newRequest;
}

- (Channel*) channelFromChannelId: (NSString*) channelId
{
    Channel* channel;
    
    NSEntityDescription* channelEntity = [NSEntityDescription entityForName: @"Channel"
                                                     inManagedObjectContext: self.mainManagedObjectContext];
    
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: channelEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", channelId];
    
    [channelFetchRequest setPredicate: predicate];
    
    NSError* error;
    
    NSArray *matchingChannelEntries = [self.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                   error: &error];
    
    if (matchingChannelEntries.count > 0)
    {
        channel = matchingChannelEntries[0];
    }
    
    return channel;
}


#pragma mark - UIWebView-based video player HTML updater

- (void) checkForUpdatedPlayerCode
{
    [self.networkEngine updatePlayerSourceWithCompletionHandler: ^(NSDictionary *dictionary) {
         if (dictionary && [dictionary isKindOfClass: [NSDictionary class]])
         {
             // Handle YouTube player updates
             NSString *youTubePlayerURLString = dictionary[@"youtube"];
             
             // Only update if we have valid HTML
             if (youTubePlayerURLString)
             {
                 [self saveAsFileToDocumentsDirectory: @"YouTubeIFramePlayer"
                                               asType: @"html"
                                          usingSource: youTubePlayerURLString];
             }
             
             // Handle Vimeo player updates
             NSString *vimeoPlayerURLString = dictionary[@"vimeo"];
             
             // Only update if we have valid HTML
             if (vimeoPlayerURLString)
             {
                 [self saveAsFileToDocumentsDirectory: @"VimeoIFramePlayer"
                                               asType: @"html"
                                          usingSource: vimeoPlayerURLString];
             }
             
             self.playerUpdated = TRUE;
         }
         else
         {
             DebugLog(@"Unexpected response from player source update");
         }
     }
     errorHandler: ^(NSError *error) {
         DebugLog(@"Player source update failed");
         // Don't worry, we'll try again next time the app comes to the foreground
     }];
}


- (void) copyFileFromAppBundleToDocumentsDirectory: (NSString *) fileName
                                            ofType: (NSString *) type
{
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *pathComponent = [NSString stringWithFormat: @"%@.%@", fileName, type];
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent: pathComponent];
    
    if ([fileManager fileExistsAtPath: destinationPath] == NO)
    {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource: fileName
                                                               ofType: type];
        
        [fileManager copyItemAtPath: sourcePath
                             toPath: destinationPath
                              error: &error];
    }
}


- (void) saveAsFileToDocumentsDirectory: (NSString *) fileName
                                 asType: (NSString *) type
                            usingSource: (NSString *) source
{
    NSError *error;
    NSString *destinationPath = [self destinationPathInDocumentsDirectoryUsingFilename: fileName
                                                                               andType: type];
    
    BOOL status = [source writeToFile: destinationPath
                           atomically: YES
                             encoding: NSUTF8StringEncoding
                                error: &error];
    
    // If something wet wrong, then revert to the original player source
    if (!status)
    {
        [self copyFileFromAppBundleToDocumentsDirectory: fileName
                                                 ofType: type];
    }
}


- (NSString *) destinationPathInDocumentsDirectoryUsingFilename: (NSString *) fileName
                                                        andType: (NSString *) type
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *pathComponent = [NSString stringWithFormat: @"%@.%@", fileName, type];
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent: pathComponent];
    
    return destinationPath;
}


#pragma mark - Notification support

- (void) application: (UIApplication *) application
         didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) deviceToken
{
    // Strip all the formatting from the token
    NSString *formattedToken = [deviceToken description];
    
    formattedToken = [formattedToken stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"<>"]];
    formattedToken = [formattedToken stringByReplacingOccurrencesOfString: @" "
                                                               withString: @""];
    
    NSLog(@"My token is: %@", formattedToken);
    
    self.apnsToken = formattedToken;
    
    // If the user has already logged in then send the latest token to the server
    if (self.currentUser)
    {
        [self performBlock: ^{
            [self.oAuthNetworkEngine updateApplePushNotificationForUserId: self.currentUser.uniqueId
                                                                    token: formattedToken
                                                        completionHandler: ^(NSDictionary *dictionary) {
                                                            DebugLog(@"Apple push notification token update successful");
                                                        }
                                                             errorHandler: ^(NSError *error) {
                                                                 DebugLog(@"Apple push notification token update failed");
                                                             }];
        } afterDelay: 2.0f];       
    }
}


- (void) application: (UIApplication *) application
         didFailToRegisterForRemoteNotificationsWithError: (NSError *) error
{
    NSLog(@"Failed to get token, error: %@", error);
    self.apnsToken = nil;
    
    // Test code, doesn't actually belong in here, but good way to test
//    [self performBlock: ^{
//        [self.viewStackManager displaySideNavigatorFromPushNotification];
//    }
//            afterDelay: 3.0f];
//    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"rockpack://www.rockpack.com"]])
//	{
//		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"rockpack://www.rockpack.com"]];
//	}
}



- (void) application: (UIApplication*) application
         didReceiveRemoteNotification: (NSDictionary*) userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    
    [self.viewStackManager displaySideNavigatorFromPushNotification];
}

@end
