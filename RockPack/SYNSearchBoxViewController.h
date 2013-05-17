//
//  SYNAutocompleteViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 15/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNSearchBoxView.h"

@interface SYNSearchBoxViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate>

@property (nonatomic, readonly) BOOL isOnScreen;

@property (nonatomic, weak, readonly) UITextField* searchTextField;

@property (nonatomic, readonly) SYNSearchBoxView* searchBoxView;


- (void) clear;

@end
