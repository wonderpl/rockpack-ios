//
//  SYNInboxOverlayViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "User.h"
#import <UIKit/UIKit.h>

@interface SYNSideNavigationViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) User* user;


-(void)reset;

@end
