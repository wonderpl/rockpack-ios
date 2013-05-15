//
//  SYNReportConcernTableViewController.m
//  rockpack
//
//  Created by Nick Banks on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNReportConcernTableCell.h"
#import "SYNReportConcernTableViewController.h"
#import "UIFont+SYNFont.h"

#define kConcernsCellId @"SYNReportConcernTableCell"

@interface SYNReportConcernTableViewController ()

@property (nonatomic, strong) NSArray *concernsArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) SYNCancelReportBlock cancelReportBlock;
@property (nonatomic, strong) SYNSendReportBlock sendReportBlock;

@end

@implementation SYNReportConcernTableViewController

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
       sendReportBlock: (SYNSendReportBlock) sendReportBlock
     cancelReportBlock: (SYNCancelReportBlock) cancelReportBlock
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        self.sendReportBlock = sendReportBlock;
        self.cancelReportBlock = cancelReportBlock;
    }
    
    return self;
}

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
    
    [self.tableView registerNib: [UINib nibWithNibName: @"SYNReportConcernTableCell" bundle: [NSBundle mainBundle]]
         forCellReuseIdentifier: kConcernsCellId];
    
//    [self.tableView registerClass: [UITableViewCell class]
//           forCellReuseIdentifier: kConcernsCellId];

    self.concernsArray = @[NSLocalizedString (@"Nudity or pornography", nil),
                           NSLocalizedString (@"Attacks a group or individual", nil),
                           NSLocalizedString (@"Graphic violence", nil),
                           NSLocalizedString (@"Hateful speech or symbols", nil),
                           NSLocalizedString (@"Actively promotes self-harm", nil),
                           NSLocalizedString (@"Spam", nil),
                           NSLocalizedString (@"Other", nil)];
    
    UIButton *customCancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customCancelButtonImage = [UIImage imageNamed: @"ButtonPopoverCancel"];
    UIImage* customCancelButtonHighlightedImage = [UIImage imageNamed: @"ButtonPopoverCancelHighlighted.png"];
    
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
    UIImage* customUseButtonImage = [UIImage imageNamed: @"ButtonPopoverReport"];
    UIImage* customUseButtonHighlightedImage = [UIImage imageNamed: @"ButtonPopoverReportHighlighted.png"];
    
    [customUseButton setImage: customUseButtonImage
                     forState: UIControlStateNormal];
    
    [customUseButton setImage: customUseButtonHighlightedImage
                     forState: UIControlStateHighlighted];
    
    [customUseButton addTarget: self
                        action: @selector(actionSendReport)
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
    SYNReportConcernTableCell *cell = [tableView dequeueReusableCellWithIdentifier: kConcernsCellId
                                                                        forIndexPath: indexPath];

    cell.titleLabel.text = self.concernsArray[indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath *) tableView: (UITableView *) tableView
   willSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    
    // Deselect old cell
    SYNReportConcernTableCell *oldCell = (SYNReportConcernTableCell *)[self.tableView cellForRowAtIndexPath: oldIndex];
    oldCell.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
    oldCell.checkmarkImage.hidden = TRUE;
    
    oldCell.titleLabel.textColor = [UIColor colorWithRed: 106.0f/255.0f
                                                   green: 114.0f/255.0f
                                                    blue: 122.0f/255.0f
                                                   alpha: 1.0f];
    
    oldCell.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                       alpha: 0.75f];
    
    // Highlight new cell
    SYNReportConcernTableCell *newCell = (SYNReportConcernTableCell *)[self.tableView cellForRowAtIndexPath: indexPath];
    newCell.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
    newCell.checkmarkImage.hidden = FALSE;
    newCell.titleLabel.textColor = [UIColor whiteColor];
    newCell.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                       alpha:  0.15f];
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


- (void) actionSendReport
{
    NSString *reportString = self.concernsArray[self.selectedIndexPath.row];
    self.sendReportBlock(reportString);
}

@end
