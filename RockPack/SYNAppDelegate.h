//
//  SYNAppDelegate.h
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNBottomTabViewController;

@interface SYNAppDelegate : UIResponder <UIApplicationDelegate>

// Main app window
@property (strong, nonatomic) UIWindow *window;

// Support for Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


// Root view controller
@property (strong, nonatomic) SYNBottomTabViewController *viewController;

- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;

@end
