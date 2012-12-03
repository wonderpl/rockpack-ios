//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate>

// Public properties

@property (readonly) NSManagedObjectContext *managedObjectContext;

// Public methods

// Core Data support

// Generalised fetchedResultsControllers
- (NSFetchedResultsController *) videoFetchedResultsController;
- (NSPredicate *) videoFetchedResultsControllerPredicate;
- (NSArray *) videoFetchedResultsControllerSortDescriptors;

- (NSFetchedResultsController *) channelFetchedResultsController;
- (NSPredicate *) channelFetchedResultsControllerPredicate;
- (NSArray *) channelFetchedResultsControllerSortDescriptors;

// Persist the current state of CoreData to the mySQL DB
- (void) saveDB;

// Animation support

// Push new view controller onto UINavigationController stack using a custom animation
// Fade old VC out, fade new VC in (as opposed to regular push animation)
- (void) animatedPushViewController: (UIViewController *) vc;
- (IBAction) animatedPopViewController;

@end
