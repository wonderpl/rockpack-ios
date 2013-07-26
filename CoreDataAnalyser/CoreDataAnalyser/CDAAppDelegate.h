//
//  CDAAppDelegate.h
//  CoreDataAnalyser
//
//  Created by Mats Trovik on 24/07/2013.
//  Copyright (c) 2013 Rockpack. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMainUpdated  @"MAINUpdated"

@class CDAViewController;

@interface CDAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CDAViewController *viewController;

@property (nonatomic, strong) NSManagedObjectContext* privateManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext* mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext* importManagedObjectContext;

@end
