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
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectCategoryWithId:(NSString*)uniqueId title:(NSString*)title;
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectSubCategoryWithId:(NSString*)uniqueId categoryTitle:(NSString*)categoryTitle subCategoryTitle:(NSString*)subCategoryTitle;
-(void)categoryTableControllerDeselectedAll:(SYNChannelCategoryTableViewController*)tableController;

@end

@interface SYNChannelCategoryTableViewController : UIViewController

@property (nonatomic, weak) id<SYNChannelCategoryTableViewDelegate> categoryTableControllerDelegate;

@property (nonatomic,weak) IBOutlet UITableView* tableView;

@end
