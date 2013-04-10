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

@end

@implementation SYNSideNavigationViewController

@synthesize navigationData;
@synthesize user;
@synthesize navItemColor;

-(id)init
{
    self = [super initWithNibName:@"SYNSideNavigationViewController" bundle:nil];
    if (self) {
        navigationData = @[
                           @{kSideNavTitle:@"FEED", kSideNavType:@(kSideNavigationTypePage), kSideNavAction:@""},
                           @{kSideNavTitle:@"CHANNELS", kSideNavType:@(kSideNavigationTypePage), kSideNavAction:@""},
                           @{kSideNavTitle:@"MY ROCKPACK", kSideNavType:@(kSideNavigationTypePage), kSideNavAction:@""},
                           @{kSideNavTitle:@"NOTIFICATIONS", kSideNavType:@(kSideNavigationTypeLoad), kSideNavAction:@""},
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
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        
        if(navigationType == kSideNavigationTypeLoad)
            cell.accessoryType = UITableViewCellAccessoryNone;
        else
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:15.0];
        
        cell.textLabel.textColor = navItemColor;
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        
        
    } 
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* navigationElement = (NSDictionary*)[navigationData objectAtIndex:indexPath.row];
    kSideNavigationType navigationType = [((NSNumber*)[navigationElement objectForKey:kSideNavType]) integerValue];
    //NSString* navigationAction = (NSString*)[navigationElement objectForKey:kSideNavAction];
    
    if(navigationType == kSideNavigationTypeLoad)
    {
        
    }
    else
    {
        
    }
    
 
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
