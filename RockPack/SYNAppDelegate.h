//
//  SYNAppDelegate.h
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelManager.h"
#import "SYNMainRegistry.h"
#import "SYNOAuth2Credential.h"
#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNRegistry.h"
#import "SYNSearchRegistry.h"
#import "SYNVideoQueue.h"
#import "SYNViewStackManager.h"
#import "User.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#define kShowLoginPhase YES
#define kUsingProductionAPI YES

@class SYNMasterViewController;

// Something new!

@class SYNContainerViewController, ChannelOwner, SYNNetworkEngine, SYNOAuthNetworkEngine;

@interface SYNAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, assign) BOOL playerUpdated;
@property (nonatomic, assign) BOOL searchRefreshDisabled;
@property (nonatomic, readonly) NSManagedObjectContext *channelsManagedObjectContext;
@property (nonatomic, readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (nonatomic, readonly) NSManagedObjectContext *searchManagedObjectContext;
@property (nonatomic, readonly) SYNChannelManager* channelManager;;
@property (nonatomic, readonly) SYNOnBoardingPopoverQueueController* onBoardingQueue;
@property (nonatomic, readonly) SYNVideoQueue* videoQueue;
@property (nonatomic, readonly) SYNViewStackManager* viewStackManager;
@property (nonatomic, strong) NSTimer* tokenExpiryTimer;
@property (nonatomic, strong) SYNOAuth2Credential* currentOAuth2Credentials;
@property (readonly, nonatomic, strong) NSString *userAgentString;
@property (readonly, nonatomic, strong) SYNMainRegistry* mainRegistry;
@property (readonly, nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (readonly, nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;
@property (readonly, nonatomic, strong) SYNSearchRegistry* searchRegistry;
@property (readonly, nonatomic, strong) User* currentUser;
@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) SYNMasterViewController *masterViewController;

- (void) deleteDataObject: (NSManagedObject*) managedObject;
- (void) saveContext: (BOOL) wait;
- (void) saveSearchContext;
- (void) saveChannelsContext;
- (void) clearCoreDataMainEntities: (BOOL) userBound;
- (void) logout;
- (void) resetCurrentOAuth2Credentials;
- (void) setTokenExpiryTimer;

@end
