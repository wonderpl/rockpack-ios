//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers

#import <UIKit/UIKit.h>

@interface SYNAbstractViewController : UIViewController

@property (readonly, weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
