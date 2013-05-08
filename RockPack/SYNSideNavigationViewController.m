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
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNSideNavigationIphoneCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNSearchBoxViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNRockpackNotification.h"
#import "SYNNotificationsViewController.h"
#import "SYNSoundPlayer.h"

#define kSideNavTitle @"kSideNavTitle"
#define kSideNavType @"kSideNavType"
#define kSideNavAction @"kSideNavAction"

#define kNotificationsRowIndex 3

typedef enum {
    kSideNavigationTypeLoad = 0,
    kSideNavigationTypePage

} kSideNavigationType;

@interface SYNSideNavigationViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton* settingsButton;
@property (nonatomic, strong) IBOutlet UIImageView* profilePictureImageView;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) NSArray* navigationData;
@property (nonatomic, strong) NSIndexPath* currentlySelectedIndexPath;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, strong) UIColor* navItemColor;
@property (nonatomic, strong) UIViewController* currentlyLoadedViewController;
@property (nonatomic, strong) NSMutableDictionary* cellByPageName;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (nonatomic, strong) NSMutableArray* notifications;

@property (nonatomic, strong) UIView* bottomExtraView;

@property (nonatomic) NSInteger unreadNotifications;
//iPhone specific
@property (weak, nonatomic) IBOutlet UIView *mainContentView;

@end


@implementation SYNSideNavigationViewController

// Only need synthesize for custom setters, use latest ObjC naming convention
@synthesize user = _user;
@synthesize currentlyLoadedViewController = _currentlyLoadedViewController;
@synthesize keyForSelectedPage;
@synthesize appDelegate;
@synthesize unreadNotifications;
@synthesize state = _state;

- (id) init
{
    if ((self = [super initWithNibName: @"SYNSideNavigationViewController" bundle: nil]))
    {
        self.navigationData = @[
                                @{kSideNavTitle: @"FEED", kSideNavType: @(kSideNavigationTypePage), kSideNavAction: kFeedTitle},
                                @{kSideNavTitle: @"CHANNELS", kSideNavType: @(kSideNavigationTypePage), kSideNavAction: kChannelsTitle},
                                @{kSideNavTitle: @"PROFILE", kSideNavType: @(kSideNavigationTypePage), kSideNavAction: kProfileTitle},
                                @{kSideNavTitle: @"NOTIFICATIONS", kSideNavType: @(kSideNavigationTypeLoad), kSideNavAction: @"SYNNotificationsViewController"}
                                ];
        
        _state = SideNavigationStateHidden;
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        
        self.unreadNotifications = 0;
        
    }
        
    return self;
}


#pragma mark - View lifecycle
        
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Navigation";
    
    self.userNameLabel.font = [UIFont rockpackFontOfSize: self.userNameLabel.font.pointSize];
    self.nicknameLabel.font = [UIFont rockpackFontOfSize: self.nicknameLabel.font.pointSize];
    
    self.navItemColor = [UIColor colorWithRed: (40.0/255.0)
                                        green: (45.0/255.0)
                                         blue: (51.0/255.0)
                                        alpha: (1.0)];
    
    self.cellByPageName = [NSMutableDictionary dictionaryWithCapacity:3];
    
    CGRect newFrame = self.view.frame;
    
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        
        newFrame.size.height = [[SYNDeviceManager sharedInstance] currentScreenHeight] - 78.0f;
        self.view.frame = newFrame;
        self.mainContentView.frame = self.view.bounds;
        self.backgroundImageView.image = [[UIImage imageNamed:@"PanelMenu"] resizableImageWithCapInsets:UIEdgeInsetsMake( 68.0f, 0.0f, 65.0f ,0.0f)];
        
        self.searchViewController = [[SYNSearchBoxViewController alloc] init];
        [self addChildViewController:self.searchViewController];
        [self.view addSubview:self.searchViewController.view];
        self.searchViewController.searchBoxView.searchTextField.delegate = self;
        [self.searchViewController.searchBoxView.integratedCloseButton addTarget:self action:@selector(closeSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    else // isIPad == TRUE
    {
        self.bottomExtraView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                        self.view.frame.origin.y + self.view.frame.size.height,
                                                                        self.view.frame.size.width,
                                                                        350.0)];
        
        self.bottomExtraView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PanelMenuBottom"]];
        
        [self.view insertSubview:self.bottomExtraView belowSubview:self.settingsButton];
        
        newFrame.size.height = [[SYNDeviceManager sharedInstance] currentScreenHeight];
        self.view.frame = newFrame;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationMarkedRead:)
                                                 name:kNotificationMarkedRead
                                               object:nil];
    
    
    
    
    // == Settings Button == //
    
    CGRect settingsButtonFrame = self.settingsButton.frame;
    settingsButtonFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] - 30.0 - settingsButtonFrame.size.height;
    self.settingsButton.frame = settingsButtonFrame;
    self.settingsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    
    // == User Name Label == //
    
    self.userNameLabel.alpha = 0.0;
    
    
    
    [self getNotifications];
}



#pragma mark - Notifications

-(void)getNotifications
{
    [appDelegate.oAuthNetworkEngine notificationsFromUserId:appDelegate.currentUser.uniqueId completionHandler:^(id response) {
        
        if(![response isKindOfClass:[NSDictionary class]])
            return;
        
        NSDictionary* responseDictionary = (NSDictionary*)response;
        
        NSDictionary* notificationsDictionary = [responseDictionary objectForKey:@"notifications"];
        if(!notificationsDictionary)
            return;
        
        NSNumber* totalNumber = [notificationsDictionary objectForKey:@"total"];
        if(!totalNumber)
            return;
        
        NSInteger total = [totalNumber integerValue];
        
        if(total == 0)
        {
            [self.tableView reloadData];
            return;
        }
        
        
        NSArray* itemsArray = (NSArray*)[notificationsDictionary objectForKey:@"items"];
        if(!itemsArray)
        {
            // TODO: handle erro in parsing items
            return;
            
        }
        
        self.notifications = [NSMutableArray arrayWithCapacity:unreadNotifications];
        
        for (NSDictionary* itemData in itemsArray)
        {
            if(!itemData) continue;
            
            SYNRockpackNotification* notification = [SYNRockpackNotification notificationWithData:itemData];
            
            if(!notification.read)
                self.unreadNotifications++;
            
            [self.notifications addObject:notification];
            
        }
        
        [self.tableView reloadData];
        
    } errorHandler:^(id error) {
        
        DebugLog(@"Could not load notifications");
        
        
    }];
}

-(void)notificationMarkedRead:(NSNotification*)notification
{
    
}

#pragma mark - Button Actions

- (IBAction) settingsButtonPressed: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAccountSettingsPressed
                                                        object:self];
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
    BOOL isIPad = [[SYNDeviceManager sharedInstance] isIPad];
    static NSString *CellIdentifier = @"NavigationCell";
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    { 
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            if(isIPad)
            {
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: CellIdentifier];
            }
            else
            {
                cell = [[SYNSideNavigationIphoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
        }
        
        NSDictionary* navigationElement = (NSDictionary*)[self.navigationData objectAtIndex: indexPath.row];
        
        
        
        kSideNavigationType navigationType = [((NSNumber*)[navigationElement objectForKey: kSideNavType]) integerValue];
        
        // == Type == //
        
        NSString* cellTitle = [navigationElement objectForKey: kSideNavTitle];
        
        if(navigationType == kSideNavigationTypePage)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSString* pageName = [navigationElement objectForKey: kSideNavAction];
            
            [self.cellByPageName setObject:cell forKey:pageName];
        }
        else
        {
            if(indexPath.row == kNotificationsRowIndex)
            {
                cellTitle = [NSString stringWithFormat:@"%@       %i", cellTitle, self.unreadNotifications];
                if(self.unreadNotifications == 0)
                    cell.accessoryType = UITableViewCellAccessoryNone;
                else
                    cell.accessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"NavArrow"]];
                
            }
            else
            {
                
                cell.accessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"NavArrow"]];
            }
            
            
        }
        
        // == Title == //
        
        
        cell.textLabel.text = cellTitle;
        
        
        if(isIPad)
        {
            cell.textLabel.font = [UIFont rockpackFontOfSize: 15.0];
            
            UIView* selectedView = [[UIView alloc] initWithFrame:cell.frame];
            selectedView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"NavSelected"]];
            cell.selectedBackgroundView = selectedView;
            cell.textLabel.textColor = self.navItemColor;
        }
    
        
        
    }
    
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    
    // if notifications cell is clicked and there are no notifications, deselect it.
    if(indexPath.row == kNotificationsRowIndex && self.notifications.count == 0) 
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    // if we are re-clicking a cell, return without deselecting
    if([indexPath compare:self.currentlySelectedIndexPath] == NSOrderedSame)
    {
        
        return;
    }
        
    
    UITableViewCell* previousSelectedCell = [self.tableView cellForRowAtIndexPath:self.currentlySelectedIndexPath];
    [previousSelectedCell setSelected:NO];
    
    if(self.currentlySelectedIndexPath.row > 3)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    self.currentlySelectedIndexPath = indexPath;
    
    
    
    
    
    NSDictionary* navigationElement = (NSDictionary*)[self.navigationData objectAtIndex: indexPath.row];
    kSideNavigationType navigationType = [((NSNumber*)[navigationElement objectForKey: kSideNavType]) integerValue];
    NSString* navigationAction = (NSString*)[navigationElement objectForKey: kSideNavAction];
    
    if (navigationType == kSideNavigationTypeLoad)
    {
        
        Class theClass = NSClassFromString(navigationAction);
        self.currentlyLoadedViewController = (UIViewController*)[[theClass alloc] init];
        
        // == NOTIFICATIONS == //
        
        if(indexPath.row == kNotificationsRowIndex)
        {
            
            ((SYNNotificationsViewController*)self.currentlyLoadedViewController).notifications = self.notifications;
        }
        
        
        self.state = SideNavigationStateFull;
        
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath isEqual:self.currentlySelectedIndexPath] )
    {
        [cell setSelected:YES];
    }
}


#pragma mark - Accessor Methods

- (void) setUser: (User *) user
{
    _user = user;
    self.userNameLabel.text = [self.user.fullName uppercaseString];
    self.nicknameLabel.text = self.user.username;
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect newFrame = self.view.frame;
    newFrame.size.height = [[SYNDeviceManager sharedInstance] currentScreenHeight];
    self.view.frame = newFrame;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGRect settingsButtonFrame = self.settingsButton.frame;
    settingsButtonFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] - 30.0 - settingsButtonFrame.size.height;
    self.settingsButton.frame = settingsButtonFrame;

    
    
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        
        
    }
    else
    {
        
        
    }
    
    
    
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.mainContentView.alpha = 0.0f;
        
        CGRect endFrame = self.view.frame;
        endFrame.size.height +=58;
        endFrame.origin.y -=58;
        self.view.frame = endFrame;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.searchViewController.searchBoxView revealCloseButton];
        } completion:nil];
        self.mainContentView.hidden = YES;
        
    }];
    self.searchViewController.searchBoxView.searchTextField.delegate = self.searchViewController;
    return YES;
}

#pragma mark - close search callback
-(void)closeSearch:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSideNavigationSearchCloseNotification object:self userInfo:nil];
    
    [self.searchViewController.searchBoxView.searchTextField resignFirstResponder];
    self.searchViewController.searchBoxView.searchTextField.text = @"";
    [self.searchViewController clear];
    self.searchViewController.searchBoxView.searchTextField.delegate = self;
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.searchViewController.searchBoxView hideCloseButton];
    } completion:^(BOOL finished) {
        self.mainContentView.hidden = NO;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.mainContentView.alpha = 1.0f;
            CGRect endFrame = self.view.frame;
            endFrame.size.height -=58;
            endFrame.origin.y +=58;
            self.view.frame = endFrame;
        } completion:^(BOOL finished) {
        }];
                
    }];
}

#pragma mark - Accessor & Animation

-(void)setState:(SideNavigationState)state
{
    if (state == _state)
        return;
    
    _state = state;
    
    switch (_state) {
        case SideNavigationStateHidden:
            [self showHiddenNavigation];
            break;
            
        case SideNavigationStateHalf:
            [self showHalfNavigation];
            break;
            
        case SideNavigationStateFull:
            [self showFullNavigation];
            break;
            
    }
}

-(void)showHalfNavigation
{
    
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideIn];
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         
                         CGRect sideNavigationFrame = self.view.frame;
                         if([[SYNDeviceManager sharedInstance] isIPad])
                         {
                             sideNavigationFrame.origin.x = 1024.0 - 192.0;
                         }
                         else
                         {
                             sideNavigationFrame.origin.x = 704.0f;
                         }
                         self.view.frame = sideNavigationFrame;
                         
                         self.userNameLabel.alpha = 0.0;
                         
                     }
                     completion: ^(BOOL finished) {
                         
                     }];
}

-(void)showFullNavigation
{
    if([[SYNDeviceManager sharedInstance] isIPad])
    {
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations: ^{
                             
                             CGRect sideNavigationFrame = self.view.frame;
                             
                             sideNavigationFrame.origin.x = 1024.0 - self.view.frame.size.width;
                             self.view.frame =  sideNavigationFrame;
                             
                             self.userNameLabel.alpha = 1.0;
                             
                         } completion: ^(BOOL finished) {
                             
                             
                             
                         }];
    }
    
    else
    {
        CGRect startFrame = self.containerView.frame;
        startFrame.origin.x = self.view.frame.size.width;
        self.containerView.frame = startFrame;
        self.containerView.hidden = NO;
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             
                             CGRect selfBounds = self.view.bounds;
                             selfBounds.origin.y = self.containerView.frame.origin.y;
                             self.containerView.frame = selfBounds;
                             
                         } completion: ^(BOOL finished) {
                             
                             
                         }];
    }
}

-(void)showHiddenNavigation
{
    
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideOut];
    
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^ {
                         
                         CGRect sideNavigationFrame = self.view.frame;
                         sideNavigationFrame.origin.x = 1024;
                         self.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                         [self reset];
                         [self deselectAllCells];
                         
                         
                     }];
}


@end
