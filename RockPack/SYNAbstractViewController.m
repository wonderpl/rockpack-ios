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

// We don't need to retain this as it is already retained by the app delegate
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation SYNAbstractViewController

// Need to explicitly synthesise these as we are using the real ivars below
@synthesize managedObjectContext = _managedObjectContext;

- (NSManagedObjectContext *) managedObjectContext
{
	if (!_managedObjectContext)
	{
		SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.managedObjectContext = delegate.managedObjectContext;
	}
    
    return _managedObjectContext;
}

@end
