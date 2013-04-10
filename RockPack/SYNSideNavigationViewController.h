//
//  SYNInboxOverlayViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SYNSideNavigationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) User* user;

@end
