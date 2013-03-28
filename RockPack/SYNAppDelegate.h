//
//  SYNAppDelegate.h
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SYNMainRegistry.h"
#import "SYNSearchRegistry.h"
#import "SYNRegistry.h"
#import "User.h"
#import "SYNOAuth2Credential.h"

// Something new!

@class SYNBottomTabViewController, ChannelOwner, SYNNetworkEngine, SYNOAuthNetworkEngine;

@interface SYNAppDelegate : UIResponder <UIApplicationDelegate>

// Main app window
@property (strong, nonatomic) UIWindow *window;

// Support for Core Data
@property (nonatomic, readonly) NSManagedObjectContext *mainManagedObjectContext;

@property (nonatomic, readonly) NSManagedObjectContext *searchManagedObjectContext;

// Comms support
@property (readonly, nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (readonly, nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;

@property (readonly, nonatomic, strong) User* currentUser;

@property (nonatomic, strong) SYNOAuth2Credential* currentOAuth2Credentials;

// Root view controller
@property (strong, nonatomic) UIViewController *masterViewController;

// Bit of a hack to represent the current user
@property (weak, nonatomic) ChannelOwner *channelOwnerMe;


@property (readonly, nonatomic, strong) SYNMainRegistry* mainRegistry;
@property (readonly, nonatomic, strong) SYNSearchRegistry* searchRegistry;

-(void)deleteDataObject:(NSManagedObject*)managedObject;
- (void) saveContext: (BOOL) wait;
-(void) saveSearchContext;
- (void) resetCoreDataStack;
-(void)clearData;
-(void)logout;

@end
