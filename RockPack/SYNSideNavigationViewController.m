//
//  SYNInboxOverlayViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSideNavigationViewController.h"
#import "UIFont+SYNFont.h"
#import "User.h"

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

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) NSArray* navigationData;

@end

@implementation SYNSideNavigationViewController

@synthesize navigationData;

-(id)init
{
    self = [super initWithNibName:@"SYNSideNavigationViewController" bundle:nil];
    if (self) {
        navigationData = @[
                           @{kSideNavTitle:@"Notification", kSideNavType:@(kSideNavigationTypeLoad), kSideNavAction:@""},
                           @{kSideNavTitle:@"Acounts", kSideNavType:@(kSideNavigationTypeLoad), kSideNavAction:@""},
                           @{kSideNavTitle:@"Settings", kSideNavType:@(kSideNavigationTypePage), kSideNavAction:@""},
                           @{kSideNavTitle:@"Buy", kSideNavType:@(kSideNavigationTypeLoad), kSideNavAction:@""}
                           ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}


#pragma mark - User Details

-(void)showUserDetails:(User*)user
{
    self.userNameLabel.text = [NSString stringWithFormat:@"%@\n%@", user.firstName, user.lastName];
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
        
        if(navigationType == kSideNavigationTypeLoad)
            cell.accessoryType = UITableViewCellAccessoryNone;
        else
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
        cell.detailTextLabel.font = [UIFont rockpackFontOfSize:13.0];
        
        
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

@end
