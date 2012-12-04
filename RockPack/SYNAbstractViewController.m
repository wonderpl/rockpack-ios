//
//  SYNAbstractViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers
//
//  To keep the code as DRY as possible, we put as much common stuff in here as possible

#import "SYNAbstractViewController.h"
#import "SYNAppDelegate.h"

@interface SYNAbstractViewController ()

@property (nonatomic, strong) NSFetchedResultsController *channelFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *videoFetchedResultsController;

@end

@implementation SYNAbstractViewController

@synthesize videoFetchedResultsController = _videoFetchedResultsController;
@synthesize channelFetchedResultsController = _channelFetchedResultsController;

// Need to explicitly synthesise these as we are using the real ivars below
@synthesize managedObjectContext = _managedObjectContext;


#pragma mark - Core Data support

// Single cached MOC for all the view controllers
- (NSManagedObjectContext *) managedObjectContext
{
    static dispatch_once_t onceQueue;
    static NSManagedObjectContext *managedObjectContext = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
                      managedObjectContext = delegate.managedObjectContext;
                  });
    
    return managedObjectContext;
}


// Generalised version of videoFetchedResultsController, you can override the predicate and sort descriptors
// by overiding the videoFetchedResultsControllerPredicate and videoFetchedResultsControllerSortDescriptors methods
- (NSFetchedResultsController *) videoFetchedResultsController
{
    NSError *error = nil;
    
    // Return cached version if we have already created one
    if (_videoFetchedResultsController != nil)
    {
        return _videoFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"Video"
                                      inManagedObjectContext: self.managedObjectContext];
    
    // Add any sort descriptors and predicates
    fetchRequest.predicate = self.videoFetchedResultsControllerPredicate;
    fetchRequest.sortDescriptors = self.videoFetchedResultsControllerSortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.videoFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                             managedObjectContext: self.managedObjectContext
                                                                               sectionNameKeyPath: nil
                                                                                        cacheName: nil];
    _videoFetchedResultsController.delegate = self;
    
    ZAssert([_videoFetchedResultsController performFetch: &error], @"videoFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _videoFetchedResultsController;
}

// Abstract functions, should be overidden in subclasses
- (NSPredicate *) videoFetchedResultsControllerPredicate
{
    AssertOrLog (@"videoFetchedResultsControllerPredicate:Abstract function called");
    return nil;
}

- (NSArray *) videoFetchedResultsControllerSortDescriptors
{
    AssertOrLog (@"videoFetchedResultsControllerSortDescriptors:Abstract function called");
    return nil;
}

// Generalised version of channelFetchedResultsController, you can override the predicate and sort descriptors
// by overiding the channelFetchedResultsControllerPredicate and channelFetchedResultsControllerSortDescriptors methods
- (NSFetchedResultsController *) channelFetchedResultsController
{
    NSError *error = nil;
    
    // Return cached version if we have already created one
    if (_channelFetchedResultsController != nil)
    {
        return _channelFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                      inManagedObjectContext: self.managedObjectContext];
    
    // Add any sort descriptors and predicates
    fetchRequest.predicate = self.channelFetchedResultsControllerPredicate;
    fetchRequest.sortDescriptors = self.channelFetchedResultsControllerSortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.channelFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                               managedObjectContext: self.managedObjectContext
                                                                                 sectionNameKeyPath: nil
                                                                                          cacheName: nil];
    _channelFetchedResultsController.delegate = self;
    
    ZAssert([_channelFetchedResultsController performFetch: &error], @"channelFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _channelFetchedResultsController;
}


// Abstract functions, should be overidden in subclasses
- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    AssertOrLog (@"channelFetchedResultsControllerPredicate:Abstract function called");
    return nil;
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    AssertOrLog (@"channelFetchedResultsControllerSortDescriptors:Abstract function called");
    return nil;
}


// Helper method: Save the current DB state
- (void) saveDB
{
    NSError *error = nil;
    
    if (![self.managedObjectContext save: &error])
    {
        NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
        
        if ([detailedErrors count] > 0)
        {
            for(NSError* detailedError in detailedErrors)
            {
                NSLog(@" DetailedError: %@", [detailedError userInfo]);
            }
        }
        
        // Bail out if save failed
        error = [NSError errorWithDomain: NSURLErrorDomain
                                    code: NSCoreDataError
                                userInfo: nil];
        
        @throw error;
    }  
}


#pragma - Animation support

// Special animation of pushing new view controller onto UINavigationController's stack
- (void) animatedPushViewController: (UIViewController *) vc
{
    NSLog (@"%@", self.navigationController);
    
    [self.navigationController pushViewController: vc
                                         animated: NO];
    
//    [UIView animateWithDuration: 0.5f
//                          delay: 0.0f
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations: ^
//     {
//         // Contract thumbnail view
//         self.view.alpha = 0.0f;
//         vc.view.alpha = 1.0f;
//         
//     }
//                     completion: ^(BOOL finished)
//     {
//     }];
}

- (IBAction) animatedPopViewController
{
    //	[self.navigationController popViewControllerAnimated: YES];
    
    UIViewController *parentVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    parentVC.view.alpha = 0.0f;
    
    [self.navigationController popViewControllerAnimated: NO];
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         parentVC.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}

@end
