//
//  SYNReportConcernTableViewController.m
//  rockpack
//
//  Created by Nick Banks on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNReportConcernTableViewController.h"
#import "UIFont+SYNFont.h"

#define kConcernsCellId @"ConcernsCell"

@interface SYNReportConcernTableViewController ()

@property (nonatomic, strong) NSArray *concernsArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) SYNCancelReportBlock cancelReportBlock;
@property (nonatomic, strong) SYNSendReportBlock sendReportBlock;

@end

@implementation SYNReportConcernTableViewController

- (id) initWithSendReportBlock: (SYNSendReportBlock) sendReportBlock
             cancelReportBlock: (SYNCancelReportBlock) cancelReportBlock

{
    if ((self = [super init]))
    {
        // Store completion blocks
        self.sendReportBlock = sendReportBlock;
        self.cancelReportBlock = cancelReportBlock;
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass: [UITableViewCell class]
           forCellReuseIdentifier: kConcernsCellId];

    self.concernsArray = @[NSLocalizedString (@"Nudity or pornography", nil),
                           NSLocalizedString (@"Attacks a group or individual", nil),
                           NSLocalizedString (@"Graphic violence", nil),
                           NSLocalizedString (@"Hateful speech or symbols", nil),
                           NSLocalizedString (@"Actively promotes self-harm", nil),
                           NSLocalizedString (@"Spam", nil),
                           NSLocalizedString (@"Other", nil)];
    
    UIButton *customCancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customCancelButtonImage = [UIImage imageNamed: @"ButtonMoveAndScaleCancel.png"];
    UIImage* customCancelButtonHighlightedImage = [UIImage imageNamed: @"ButtonMoveAndScaleCancel.png"];
    
    [customCancelButton setImage: customCancelButtonImage
                        forState: UIControlStateNormal];
    
    [customCancelButton setImage: customCancelButtonHighlightedImage
                        forState: UIControlStateHighlighted];
    
    [customCancelButton addTarget: self
                           action: @selector(actionCancel)
                 forControlEvents: UIControlEventTouchUpInside];
    
    customCancelButton.frame = CGRectMake(0.0, 0.0, customCancelButtonImage.size.width, customCancelButtonImage.size.height);
    UIBarButtonItem *customCancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView: customCancelButton];
    
    self.navigationItem.leftBarButtonItem = customCancelButtonItem;
    
    UIButton *customUseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customUseButtonImage = [UIImage imageNamed: @"ButtonMoveAndScaleUse.png"];
    UIImage* customUseButtonHighlightedImage = [UIImage imageNamed: @"ButtonMoveAndScaleUse.png"];
    
    [customUseButton setImage: customUseButtonImage
                     forState: UIControlStateNormal];
    
    [customUseButton setImage: customUseButtonHighlightedImage
                     forState: UIControlStateHighlighted];
    
    [customUseButton addTarget: self
                        action: @selector(_actionUse)
              forControlEvents: UIControlEventTouchUpInside];
    
    customUseButton.frame = CGRectMake(0.0, 0.0, customUseButtonImage.size.width, customUseButtonImage.size.height);
    UIBarButtonItem *customUseButtonItem = [[UIBarButtonItem alloc] initWithCustomView: customUseButton];
    
    self.navigationItem.rightBarButtonItem = customUseButtonItem;
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return self.concernsArray.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kConcernsCellId
                                                            forIndexPath: indexPath];

    cell.textLabel.font = [UIFont rockpackFontOfSize:16.0];
    cell.textLabel.text = self.concernsArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath *) tableView: (UITableView *) tableView
   willSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    [self.tableView cellForRowAtIndexPath: oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath: indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    return indexPath;
}


- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    self.selectedIndexPath = indexPath;
}


- (void) actionCancel
{
    self.cancelReportBlock();
}


- (void) actionUse
{
    NSString *reportString = self.concernsArray[self.selectedIndexPath.row];
    self.sendReportBlock(reportString);
}

@end
