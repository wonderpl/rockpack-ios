//
//  SYNReportConcernTableViewController.m
//  rockpack
//
//  Created by Nick Banks on 08/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNReportConcernTableCell.h"
#import "SYNReportConcernTableViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNMasterViewController.h"

#define kConcernsCellId @"SYNReportConcernTableCell"

@interface SYNReportConcernTableViewController () <UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *concernsArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) SYNCancelReportBlock cancelReportBlock;
@property (nonatomic, strong) SYNSendReportBlock sendReportBlock;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *reportButton;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UILabel *reportTableTitleLabel;

@property (nonatomic, strong) IBOutlet UIPopoverController *reportConcernPopoverController;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@property (nonatomic,strong) NSString* objectType;
@property (nonatomic,strong) NSString* objectId;

@end

@implementation SYNReportConcernTableViewController

#pragma mark - Object lifecycle

- (id) init
{
    self = [super init];
    if(self)
    {
        _appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}


- (void) dealloc
{
    // Defensive programming
    self.reportConcernPopoverController.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib: [UINib nibWithNibName: @"SYNReportConcernTableCell" bundle: [NSBundle mainBundle]]
         forCellReuseIdentifier: kConcernsCellId];
    
    self.concernsArray = @[NSLocalizedString (@"Nudity or pornography", nil),
                           NSLocalizedString (@"Attacks a group or individual", nil),
                           NSLocalizedString (@"Graphic violence", nil),
                           NSLocalizedString (@"Hateful speech or symbols", nil),
                           NSLocalizedString (@"Actively promotes self-harm", nil),
                           NSLocalizedString (@"Spam", nil),
                           NSLocalizedString (@"Other", nil)];
    
    UIButton *customCancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customCancelButtonImage = [UIImage imageNamed: @"ButtonPopoverCancel"];
    UIImage* customCancelButtonHighlightedImage = [UIImage imageNamed: @"ButtonPopoverCancelHighlighted"];
    
    self.reportTableTitleLabel.font = [UIFont boldRockpackFontOfSize: self.reportTableTitleLabel.font.pointSize];
    
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
    UIImage* customUseButtonDisabledImage = [UIImage imageNamed: @""];
    
    [customUseButton setImage: customUseButtonImage
                     forState: UIControlStateNormal];
    
    [customUseButton setImage: customUseButtonHighlightedImage
                     forState: UIControlStateHighlighted];
    
    [customUseButton setImage: customUseButtonDisabledImage
                     forState: UIControlStateDisabled];
    
    [customUseButton addTarget: self
                        action: @selector(actionSendReport)
              forControlEvents: UIControlEventTouchUpInside];
    
    customUseButton.frame = CGRectMake(0.0, 0.0, customUseButtonImage.size.width, customUseButtonImage.size.height);
    UIBarButtonItem *customUseButtonItem = [[UIBarButtonItem alloc] initWithCustomView: customUseButton];
    
    self.navigationItem.rightBarButtonItem = customUseButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    
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
    if (IS_IPHONE)
    {
        self.reportButton.enabled = TRUE;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
    }
    
    self.selectedIndexPath = indexPath;
}


- (IBAction) actionCancel
{
    self.cancelReportBlock();
}


- (IBAction) actionSendReport
{
    NSString *reportString = self.concernsArray[self.selectedIndexPath.row];
    self.sendReportBlock(reportString);
    
    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Thanks!", nil)
                                message: NSLocalizedString(@"A member of our editorial team will review this content and take any necessary action.", nil)
                               delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}

/**
 show the report concern UI
 @param presentingButton UI button to show the popup from on iPad. Will get deselected on on completion or cancellation.
 @param objectType the name of the type of object to report
 @param objectId the id of the object to report
 */
-(void)reportConcernFromView:(UIButton*)presentingButton inViewController:(UIViewController*) viewController popOverArrowDirection:(UIPopoverArrowDirection)direction objectType:(NSString*)objectType objectId:(NSString*)objectId completedBlock:(SYNReportCompletedBlock)completedBlock
{
    self.objectType = objectType;
    self.objectId = objectId;
    __weak SYNReportConcernTableViewController* weakSelf = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Create out concerns table view controller
        self.sendReportBlock = ^ (NSString *reportString){
            [weakSelf.reportConcernPopoverController dismissPopoverAnimated: YES];
            [weakSelf reportConcern: reportString];
            if(completedBlock)
            {
                completedBlock();
            }
        };
        self.cancelReportBlock = ^{
            [weakSelf.reportConcernPopoverController dismissPopoverAnimated: YES];
            if(completedBlock)
            {
                completedBlock();
            };
        };
        
        // Wrap it in a navigation controller
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: self];
        
        // Hard way of adding a title (need to due to custom font offsets)
        UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake (0, 0, 80, 28)];
        containerView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake (0, 4, 80, 28)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldRockpackFontOfSize: 20.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0, 1.0);
        label.text = NSLocalizedString(@"REPORT", nil);
        [containerView addSubview: label];
        self.navigationItem.titleView = containerView;
        
        // Need show the popover controller
        self.reportConcernPopoverController = [[UIPopoverController alloc] initWithContentViewController: navController];
        self.reportConcernPopoverController.popoverContentSize = CGSizeMake(245, 344);
        self.reportConcernPopoverController.delegate = self;
        self.reportConcernPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
        
        CGRect popoverFrame = [viewController.view convertRect:presentingButton.frame fromView:presentingButton.superview];
        
        // Now present appropriately
        [self.reportConcernPopoverController presentPopoverFromRect: popoverFrame
                                                             inView: viewController.view
                                           permittedArrowDirections: direction
                                                           animated: YES];
    }
    else
    {
        SYNMasterViewController *masterViewController = (SYNMasterViewController*)self.appDelegate.masterViewController;
        self.sendReportBlock = ^ (NSString *reportString){
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 // Fade out the category tab controller
                                 weakSelf.view.alpha = 0.0f;
                             }
                             completion: nil];
            [weakSelf reportConcern: reportString];
            if(completedBlock)
            {
                completedBlock();
            }
        };
        self.cancelReportBlock = ^{
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 // Fade out the category tab controller
                                 weakSelf.view.alpha = 0.0f;
                             }
                             completion: ^(BOOL success){
                                 [weakSelf.view removeFromSuperview];
                             }];
            if(completedBlock)
            {
                completedBlock();
            }
        };
        
        
        // Move off the bottom of the screen
        CGRect startFrame = self.view.frame;
        startFrame.origin.y = viewController.view.frame.size.height;
        self.view.frame = startFrame;
        
        [masterViewController.view addSubview: self.view];
        
        // Slide up onto the screen
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.view.frame;
                             endFrame.origin.y = 0.0f;
                             self.view.frame = endFrame;
                         }
                         completion: nil];
    }
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    self.cancelReportBlock();
}

- (void) reportConcern: (NSString *) reportString
{
    [self.appDelegate.oAuthNetworkEngine reportConcernForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                                     objectType: self.objectType
                                                       objectId: self.objectId
                                                         reason: reportString
                                              completionHandler: ^(NSDictionary *dictionary){
                                                  //                                              DebugLog(@"Concern successfully reported");
                                              }
                                                   errorHandler: ^(NSError* error) {
                                                       DebugLog(@"Report concern failed");
                                                       DebugLog(@"%@", [error debugDescription]);
                                                   }];
}





@end
