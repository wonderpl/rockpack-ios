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
typedef void (^SYNSelectedReportBlock)(void);

@interface SYNReportConcernTableViewController :  UIViewController <UITableViewDataSource, UITableViewDelegate>

// Initialiser for iPhone version
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
       sendReportBlock: (SYNSendReportBlock) sendReportBlock
     cancelReportBlock: (SYNCancelReportBlock) cancelReportBlock;

// Initialiser for iPad version
- (id) initWithSendReportBlock: (SYNSendReportBlock) sendReportBlock
             cancelReportBlock: (SYNCancelReportBlock) cancelReportBlock;

@end
