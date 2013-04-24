//
//  SYNChannelCategoryTableViewController.h
//  rockpack
//
//  Created by Mats Trovik on 23/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabViewDelegate.h"

#define kCategoryNameKey @"CategoryName"
#define kSubCategoriesKey @"SubCategory"

@class SYNChannelCategoryTableViewController;

@protocol SYNChannelCategoryTableViewDelegate <NSObject>

@optional
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectCategoryWithId:(NSString*)uniqueId;
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectSubCategoryWithId:(NSString*)uniqueId;

@end

@interface SYNChannelCategoryTableViewController : UITableViewController

@property (nonatomic, weak) id<SYNChannelCategoryTableViewDelegate> categoryTableControllerDelegate;

@end
