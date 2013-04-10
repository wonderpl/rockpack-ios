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

#define kSideNavTitle @"kSideNavTitle"
#define kSideNavType @"kSideNavType"
#define kSideNavAction @"kSideNavAction"

typedef enum {
    kSideNavigationTypeLoad = 0,
    kSideNavigationTypePage

} kSideNavigationType;

@interface SYNSideNavigationViewController ()

@property (nonatomic, strong) IBOutlet UILabel* serchLabel;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UIImageView* profilePictureImageView;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) IBOutlet UIButton* settingsButton;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) UIColor* navItemColor;

@property (nonatomic, strong) NSArray* navigationData;

@property (nonatomic, strong) NSIndexPath* currentlySelectedIndexPath;

@property (nonatomic, strong) UIViewController* currentlyLoadedViewController;

@end

@implementation SYNSideNavigationViewController

@synthesize navigationData;
@synthesize user;
@synthesize navItemColor;
@synthesize currentlySelectedIndexPath;
@synthesize currentlyLoadedViewController;

-(id)init
{
    self = [super initWithNibName:@"SYNSideNavigationViewController" bundle:nil];
    if (self) {
        navigationData = @[
                           @{kSideNavTitle:@"FEED", kSideNavType:@(kSideNavigationTypePage), kSideNavAction:@"Feed"},
                           @{kSideNavTitle:@"CHANNELS", kSideNavType:@(kSideNavigationTypePage), kSideNavAction:@"Channels"},
                           @{kSideNavTitle:@"MY ROCKPACK", kSideNavType:@(kSideNavigationTypePage), kSideNavAction:@"My Rockpack"},
                           @{kSideNavTitle:@"NOTIFICATIONS", kSideNavType:@(kSideNavigationTypeLoad), kSideNavAction:@"SYNNotificationsViewController"},
                           @{kSideNavTitle:@"ACCOUNTS", kSideNavType:@(kSideNavigationTypeLoad), kSideNavAction:@""}
                           ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userNameLabel.font = [UIFont rockpackFontOfSize:20.0];
    
    navItemColor = [UIColor colorWithRed:(40.0/255.0)
                                   green:(45.0/255.0)
                                    blue:(51.0/255.0)
                                   alpha:(1.0)];
   
}

#pragma mark - Button Actions

-(IBAction)settingsButtonPressed:(id)sender
{
    
}



#pragma mark - UITableView Deleagate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return navigationData.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NavigationCell";
    UITableViewCell *cell;
    
    
    if(indexPath.section == 0) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        NSDictionary* navigationElement = (NSDictionary*)[navigationData objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [navigationElement objectForKey:kSideNavTitle];
        
        kSideNavigationType navigationType = [((NSNumber*)[navigationElement objectForKey:kSideNavType]) integerValue];
        
        
        
        if(navigationType == kSideNavigationTypePage) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavArrow"]];
        }
            
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:15.0];
        
        cell.textLabel.textColor = navItemColor;
        
        UIView* selectedView = [[UIView alloc] initWithFrame:cell.frame];
        selectedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavSelected"]];
        cell.selectedBackgroundView = selectedView;
        
        
    } 
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath compare:currentlySelectedIndexPath] == NSOrderedSame)
        return;
    
    //self.currentlySelectedIndexPath = indexPath;
    
    NSDictionary* navigationElement = (NSDictionary*)[navigationData objectAtIndex:indexPath.row];
    kSideNavigationType navigationType = [((NSNumber*)[navigationElement objectForKey:kSideNavType]) integerValue];
    NSString* navigationAction = (NSString*)[navigationElement objectForKey:kSideNavAction];
    
    if(navigationType == kSideNavigationTypeLoad)
    {
        
        Class theClass = NSClassFromString(navigationAction);
        self.currentlyLoadedViewController = (UIViewController*)[[theClass alloc] init];
        
    }
    else
    {
        
        NSNotification* navigationNotification = [NSNotification notificationWithName:kNavigateToPage
                                                                               object:self
                                                                             userInfo:@{@"pageName":navigationAction}];
        
        [[NSNotificationCenter defaultCenter] postNotification:navigationNotification];
    }
    
 
}

-(void)setCurrentlyLoadedViewController:(UIViewController *)currentlyLoadedVC
{
    
    
    if(currentlyLoadedViewController) {
        [currentlyLoadedViewController.view removeFromSuperview];
    }
    
    
    currentlyLoadedViewController = currentlyLoadedVC;
    
    if(!currentlyLoadedViewController)
        return;
    
    CGSize containerSize = self.containerView.frame.size;
    CGRect vcRect = currentlyLoadedViewController.view.frame;
    vcRect.size = containerSize;
    currentlyLoadedViewController.view.frame = vcRect;
    
    [self.containerView addSubview:currentlyLoadedViewController.view];
    
    
}

-(void)reset
{
    self.currentlySelectedIndexPath = nil;
}

#pragma mark - Accessor Methods

-(void)setUser:(User *)nuser
{
    user = nuser;
    self.userNameLabel.text = [NSString stringWithFormat:@"%@", user.fullName];
    [self.profilePictureImageView setAsynchronousImageFromURL: [NSURL URLWithString: user.thumbnailURL]
                                      placeHolderImage: [UIImage imageNamed:@"NotFoundAvatarYou.png"]];
}

@end
