//
//  SYNReportConcernTableViewController.h
//  rockpack
//
//  Created by Nick Banks on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SYNCancelReportBlock)(void);
typedef void (^SYNSendReportBlock)(NSString *reportString);

@interface SYNReportConcernTableViewController : UITableViewController

@end
