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

@property (readonly, weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
