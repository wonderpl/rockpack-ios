//
//  SYNAppDelegate.m
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNViewController.h"
#import "TestFlight.h"
#import "UncaughtExceptionHandler.h"

@implementation SYNAppDelegate


// 7476be3185f5971ed3af8d0c6a136c80_MTQyOTYxMjAxMi0xMC0xMyAxMjoyMTozOS41MDgxNDA
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self performSelector: @selector(installUncaughtExceptionHandler)
               withObject: nil
               afterDelay: 0];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[SYNViewController alloc] initWithNibName: @"SYNViewController"
                                                              bundle: nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Exception handler

- (void) installUncaughtExceptionHandler
{
	InstallUncaughtExceptionHandler();
    
    [TestFlight takeOff: @"d5a8ff3d95e248e5e3a6f3282fa3e8e8_ODU2NA"];
}

@end
