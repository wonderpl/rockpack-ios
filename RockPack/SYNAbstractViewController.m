//
//  SYNAbstractViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers

#import "SYNAbstractViewController.h"
#import "SYNAppDelegate.h"

@interface SYNAbstractViewController ()

@end

@implementation SYNAbstractViewController

// Need to explicitly synthesise these as we are using the real ivars below
@synthesize managedObjectContext = _managedObjectContext;

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


- (void) animatedPushViewController: (UIViewController *) vc
{
    vc.view.alpha = 0.0f;
    
    [self.navigationController pushViewController: vc
                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         vc.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}

@end
