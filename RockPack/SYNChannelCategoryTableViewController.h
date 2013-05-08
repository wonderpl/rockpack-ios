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
/**
	Callback method triggered when the user selects a category header
	@param tableController the controller that the user interacted with
	@param uniqueId the unique Id of the category selected
	@param title the title of the category selected.
 */
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectCategoryWithId:(NSString*)uniqueId title:(NSString*)title;

/**
	Callback method triggered when the user selects a sub category cell
 
    Alternatively, if a confirm button was added through a xib, pressing it will fire this callback.
	@param tableController the controller that the user interacted with
	@param uniqueId the unique id for the sub category selected
	@param categoryTitle the title of the category the subcategory belongs to
	@param subCategoryTitle the title of the subcategory that wa selected
 */
-(void)categoryTableController:(SYNChannelCategoryTableViewController*)tableController didSelectSubCategoryWithId:(NSString*)uniqueId categoryTitle:(NSString*)categoryTitle subCategoryTitle:(NSString*)subCategoryTitle;

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
	toggles the showing of an "All categories" cell at the top of the list
 
    set to YES by default
 */
@property (nonatomic, assign) BOOL showAllCategoriesHeader;


@end
