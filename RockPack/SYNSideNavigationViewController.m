//
//  SYNInboxOverlayViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSideNavigationViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "AppConstants.h"
#import "GAI.h"
#import "SYNDeviceManager.h"

#define kSideNavTitle @"kSideNavTitle"
#define kSideNavType @"kSideNavType"
#define kSideNavAction @"kSideNavAction"

typedef enum {
    kSideNavigationTypeLoad = 0,
    kSideNavigationTypePage

} kSideNavigationType;

@interface SYNSideNavigationViewController ()

@property (nonatomic, strong) IBOutlet UIButton* settingsButton;
@property (nonatomic, strong) IBOutlet UIImageView* profilePictureImageView;
@property (nonatomic, strong) IBOutlet UILabel* serchLabel;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) NSArray* navigationData;
@property (nonatomic, strong) NSIndexPath* currentlySelectedIndexPath;
@property (nonatomic, strong) UIColor* navItemColor;
@property (nonatomic, strong) UIViewController* currentlyLoadedViewController;
@property (nonatomic, strong) NSMutableDictionary* cellByPageName;

@property (nonatomic, strong) UIView* bottomExtraView;

@end


@implementation SYNSideNavigationViewController

// Only need synthesize for custom setters, use latest ObjC naming convention
@synthesize user = _user;
@synthesize currentlyLoadedViewController = _currentlyLoadedViewController;
@synthesize keyForSelectedPage;

- (id) init
{
    if ((self = [super initWithNibName: @"SYNSideNavigationViewController" bundle: nil]))
    {
        self.navigationData = @[
                                @{kSideNavTitle: @"FEED", kSideNavType: @(kSideNavigationTypePage), kSideNavAction: kFeedTitle},
                                @{kSideNavTitle: @"CHANNELS", kSideNavType: @(kSideNavigationTypePage), kSideNavAction: kChannelsTitle},
                                @{kSideNavTitle: @"MY ROCKPACK", kSideNavType: @(kSideNavigationTypePage), kSideNavAction: kProfileTitle},
                                @{kSideNavTitle: @"NOTIFICATIONS", kSideNavType: @(kSideNavigationTypeLoad), kSideNavAction: @"SYNNotificationsViewController"},
                                @{kSideNavTitle: @"ACCOUNTS", kSideNavType: @(kSideNavigationTypeLoad), kSideNavAction: @""}
                                ];
        
        self.state = SideNavigationStateHidden;
        
        self.bottomExtraView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.origin.y + self.view.frame.size.height, self.view.frame.size.width, 300.0)];
        self.bottomExtraView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PanelMenuBottom"]];
        [self.view addSubview:self.bottomExtraView];
        
    }
        
    return self;
}


#pragma mark - View lifecycle
        
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Navigation";
    
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 20.0];
    
    self.navItemColor = [UIColor colorWithRed: (40.0/255.0)
                                        green: (45.0/255.0)
                                         blue: (51.0/255.0)
                                        alpha: (1.0)];
    
    self.cellByPageName = [NSMutableDictionary dictionaryWithCapacity:3];
}


#pragma mark - Button Actions

- (IBAction) settingsButtonPressed: (id) sender
{
    
}


#pragma mark - UITableView Deleagate

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return self.navigationData.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"NavigationCell";
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    { 
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: CellIdentifier];
        
        NSDictionary* navigationElement = (NSDictionary*)[self.navigationData objectAtIndex: indexPath.row];
        
        cell.textLabel.text = [navigationElement objectForKey: kSideNavTitle];
        
        kSideNavigationType navigationType = [((NSNumber*)[navigationElement objectForKey: kSideNavType]) integerValue];
        
        
        UIView* selectedView = [[UIView alloc] initWithFrame:cell.frame];
        selectedView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"NavSelected"]];
        cell.selectedBackgroundView = selectedView;
        
        
        if(navigationType == kSideNavigationTypePage)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSString* pageName = [navigationElement objectForKey: kSideNavAction];
            
            [self.cellByPageName setObject:cell forKey:pageName];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"NavArrow"]];
        }
            
        cell.textLabel.font = [UIFont rockpackFontOfSize: 15.0];
        
        cell.textLabel.textColor = self.navItemColor;
        
        
    } 
    
    return cell;
}


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    
    if([indexPath compare:self.currentlySelectedIndexPath] == NSOrderedSame)
        return;
    
    UITableViewCell* previousSelectedCell = [self.tableView cellForRowAtIndexPath:self.currentlySelectedIndexPath];
    [previousSelectedCell setSelected:NO];
    
    if(self.currentlySelectedIndexPath.row > 3)
    {
        
    }
    
    self.currentlySelectedIndexPath = indexPath;
    
    
    
    
    
    NSDictionary* navigationElement = (NSDictionary*)[self.navigationData objectAtIndex: indexPath.row];
    kSideNavigationType navigationType = [((NSNumber*)[navigationElement objectForKey: kSideNavType]) integerValue];
    NSString* navigationAction = (NSString*)[navigationElement objectForKey: kSideNavAction];
    
    if (navigationType == kSideNavigationTypeLoad)
    {
        
        Class theClass = NSClassFromString(navigationAction);
        self.currentlyLoadedViewController = (UIViewController*)[[theClass alloc] init];
        
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations: ^{
                             
                             CGRect sideNavigationFrame = self.view.frame;
                             
                             sideNavigationFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenWidth] - self.view.frame.size.width;
                             self.view.frame =  sideNavigationFrame;
                             
                         } completion: ^(BOOL finished) {
                             
                             self.state = SideNavigationStateFull;
                             
                         }];
        
    }
    else
    {
        
        NSNotification* navigationNotification = [NSNotification notificationWithName: kNavigateToPage
                                                                               object: self
                                                                             userInfo: @{@"pageName":navigationAction}];
        
        [[NSNotificationCenter defaultCenter] postNotification: navigationNotification];
    }
    
    // Google analytics
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"mainNavClick"
                         withLabel: navigationAction
                         withValue: nil];
}


#pragma mark - Accessor Methods

- (void) setUser: (User *) user
{
    _user = user;
    self.userNameLabel.text = [NSString stringWithFormat: @"%@", self.user.fullName];
    
    [self.profilePictureImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.user.thumbnailURL]
                                             placeHolderImage: [UIImage imageNamed: @"NotFoundAvatarYou.png"]];
}


-(void)setSelectedCellByPageName:(NSString*)pageName
{
    self.keyForSelectedPage = pageName;
    UITableViewCell* cellSelected = (UITableViewCell*)[self.cellByPageName objectForKey:pageName];
    if(!cellSelected)
        return;
    
    for (UITableViewCell* cell in [self.cellByPageName allValues]) {
        if(cellSelected == cell)
            [cell setSelected:YES];
        else
            [cell setSelected:NO];
    }
    
    NSIndexPath* selectedIndexPath = [NSIndexPath indexPathForItem:([[self.cellByPageName allValues] indexOfObject:cellSelected] - 1) inSection:0];

    self.currentlySelectedIndexPath = selectedIndexPath;
    
}

-(void)deselectAllCells
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++)
    {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];
            [cell setSelected:NO];
        }
    }
}

- (void) setCurrentlyLoadedViewController: (UIViewController *) currentlyLoadedVC
{
    if (self.currentlyLoadedViewController)
    {
        [self.currentlyLoadedViewController.view removeFromSuperview];
    }
    
    _currentlyLoadedViewController = currentlyLoadedVC;
    
    // Bail out if setting to nil
    if(!self.currentlyLoadedViewController)
        return;
    
    CGSize containerSize = self.containerView.frame.size;
    CGRect vcRect = self.currentlyLoadedViewController.view.frame;
    vcRect.size = containerSize;
    self.currentlyLoadedViewController.view.frame = vcRect;
    
    [self.containerView addSubview: self.currentlyLoadedViewController.view];
}


- (void) reset
{
    self.currentlySelectedIndexPath = nil;
    
}


#pragma mark - Orientation Change

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        
    }
    else
    {
        
    }
    
    
}

@end
