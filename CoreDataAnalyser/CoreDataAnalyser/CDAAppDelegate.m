//
//  CDAAppDelegate.m
//  CoreDataAnalyser
//
//  Created by Mats Trovik on 24/07/2013.
//  Copyright (c) 2013 Rockpack. All rights reserved.
//

#import "CDAAppDelegate.h"

#import "CDAViewController.h"
#import <CoreData/CoreData.h>

#define USE_PARALLEL_CONTEXTS
//#define USE_FETCHED_RESULT_CONTROLLER

@interface CDAAppDelegate ()



@end

@implementation CDAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeCoreDataStack];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[CDAViewController alloc] init];
    } else {
        self.viewController = [[CDAViewController alloc] init];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) initializeCoreDataStack
{
    NSError *error;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"Rockpack"
                                              withExtension: @"momd"];
    
    NSAssert(modelURL, @"No datamodel");
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    
    NSAssert(managedObjectModel, @"Could not initialize MOM");
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    
    NSAssert(persistentStoreCoordinator, @"persistens store coordinator failed to initialise");
    
    // == Main Context
#ifdef USE_PARALLEL_CONTEXTS
    self.importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    self.importManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    self.mainManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];

#else
    self.privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    self.privateManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    self.mainManagedObjectContext.parentContext = self.privateManagedObjectContext;
    
    self.importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.importManagedObjectContext.parentContext = self.mainManagedObjectContext;
    
#endif
    
    
    
    
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
            NSLog(@"Existing database - migration failed so deleted");
        }
        else
        {
            NSAssert(!error, @"Failed to delete exisiting database!");
        }
        
        store = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                         configuration: nil
                                                                   URL: storeURL
                                                               options: @{NSMigratePersistentStoresAutomaticallyOption: @(YES)}
                                                                 error: &error];
    }
    
    NSAssert2(store, @"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
    
    
}

-(void)saveNotification:(NSNotification*)note
{
    NSManagedObjectContext* context = [note object];

    if(context == self.importManagedObjectContext){
        [self.mainManagedObjectContext performBlock:^{
            [self.mainManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMainUpdated object:self.mainManagedObjectContext];
        }];
    }
    else
    {
        [self.importManagedObjectContext performBlock:^{
            [self.importManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
        }];
    }
}

@end
