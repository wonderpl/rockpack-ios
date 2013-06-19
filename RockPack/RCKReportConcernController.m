//
//  SYNReportConcernController.m
//  rockpack
//
//  Created by Mats Trovik on 19/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "RCKReportConcernController.h"
#import "SYNReportConcernTableViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"

@interface RCKReportConcernController ()<UIPopoverControllerDelegate>

@property (nonatomic, weak) UIViewController* hostViewController;
@property (nonatomic, strong) SYNReportConcernTableViewController* reportConcernTableViewController;
@property (nonatomic, strong) IBOutlet UIPopoverController *reportConcernPopoverController;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@property (nonatomic,strong) NSString* objectType;
@property (nonatomic,strong) NSString* objectId;

@end

@implementation RCKReportConcernController

-(id)initWithHostViewController:(UIViewController*)hostViewController
{
    self = [super init];
    if(self)
    {
        _hostViewController = hostViewController;
        _appDelegate = (SYNAppDelegate*) [[UIApplication sharedApplication] delegate];
    }
    return self;
}

-(void)reportConcernFromView:(UIButton*)presentingButton objectType:(NSString*)objectType objectId:(NSString*)objectId
{
    self.objectType = objectType;
    self.objectId = objectId;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Create out concerns table view controller
        self.reportConcernTableViewController = [[SYNReportConcernTableViewController alloc] initWithSendReportBlock: ^ (NSString *reportString){
            [self.reportConcernPopoverController dismissPopoverAnimated: YES];
            [self reportConcern: reportString];
            presentingButton.selected = FALSE;
        }
                                                                                                   cancelReportBlock: ^{
                                                                                                       [self.reportConcernPopoverController dismissPopoverAnimated: YES];
                                                                                                       presentingButton.selected = FALSE;
                                                                                                   }];
        
        // Wrap it in a navigation controller
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: self.reportConcernTableViewController];
        
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
        self.reportConcernTableViewController.navigationItem.titleView = containerView;
        
        // Need show the popover controller
        self.reportConcernPopoverController = [[UIPopoverController alloc] initWithContentViewController: navController];
        self.reportConcernPopoverController.popoverContentSize = CGSizeMake(245, 344);
        self.reportConcernPopoverController.delegate = self;
        self.reportConcernPopoverController.popoverBackgroundViewClass = [SYNPopoverBackgroundView class];
        
        CGRect popoverFrame = [self.hostViewController.view convertRect:presentingButton.frame fromView:presentingButton.superview];
        
        // Now present appropriately
        [self.reportConcernPopoverController presentPopoverFromRect: popoverFrame
                                                             inView: self.hostViewController.view
                                           permittedArrowDirections: UIPopoverArrowDirectionLeft
                                                           animated: YES];
    }
    else
    {
        SYNMasterViewController *masterViewController = (SYNMasterViewController*)self.appDelegate.masterViewController;
        
        self.reportConcernTableViewController = [[SYNReportConcernTableViewController alloc] initWithNibName: @"SYNReportConcernTableViewControllerFullScreen~iphone"
                                                                                                      bundle: [NSBundle mainBundle]
                                                                                             sendReportBlock: ^ (NSString *reportString){
                                                                                                 [UIView animateWithDuration: kChannelEditModeAnimationDuration
                                                                                                                  animations: ^{
                                                                                                                      // Fade out the category tab controller
                                                                                                                      self.reportConcernTableViewController.view.alpha = 0.0f;
                                                                                                                  }
                                                                                                                  completion: nil];
                                                                                                 presentingButton.selected = FALSE;
                                                                                                 [self reportConcern: reportString];
                                                                                             }
                                                                                           cancelReportBlock: ^{
                                                                                               [UIView animateWithDuration: kChannelEditModeAnimationDuration
                                                                                                                animations: ^{
                                                                                                                    // Fade out the category tab controller
                                                                                                                    self.reportConcernTableViewController.view.alpha = 0.0f;
                                                                                                                }
                                                                                                                completion: ^(BOOL success){
                                                                                                                    [self.reportConcernTableViewController.view removeFromSuperview];
                                                                                                                }];
                                                                                               presentingButton.selected = FALSE;
                                                                                           }];
        
        
        // Move off the bottom of the screen
        CGRect startFrame = self.reportConcernTableViewController.view.frame;
        startFrame.origin.y = self.hostViewController.view.frame.size.height;
        self.reportConcernTableViewController.view.frame = startFrame;
        
        [masterViewController.view addSubview: self.reportConcernTableViewController.view];
        
        // Slide up onto the screen
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.reportConcernTableViewController.view.frame;
                             endFrame.origin.y = 0.0f;
                             self.reportConcernTableViewController.view.frame = endFrame;
                         }
                         completion: nil];
    }
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
