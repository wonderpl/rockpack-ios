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
@class Genre;

@protocol SYNChannelCategoryTableViewDelegate <NSObject>

@optional
/**
	Callback method triggered when the user selects a category header
	@param tableController the controller that the user interacted with
    @param genre the core data object for the selected category.
 */
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectCategory:(Genre*) category;


/**
    Callback method triggered when the user selects a sub category cell
 
    Alternatively, if a confirm button was added through a xib, pressing it will fire this callback.
	@param tableController the controller that the user interacted with
    @param subCategory the core data object for the selected sub category.

 */
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectSubCategory:(SubGenre*) subCategory;

/**
	fires when the user selects the "All categories" header.
    
    Alternatively, if a closebutton was added through a nib, pressing it will fire this callback.
	@param tableController the controller that the user interacted with
 */
-(void)categoryTableControllerDeselectedAll:(SYNChannelCategoryTableViewController*)tableController;


@end

@interface SYNChannelCategoryTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<SYNChannelCategoryTableViewDelegate> categoryTableControllerDelegate;
@property (nonatomic,weak) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
/**
	toggles the showing of an "All categories" cell or an "Other" category cell at the top of the list
 
    set to YES by default
 */
@property (nonatomic, assign) BOOL showAllCategoriesHeader;




@end
