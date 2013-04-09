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

@interface SYNSideNavigationViewController ()

@property (nonatomic, strong) IBOutlet UILabel* serchLabel;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UIImageView* profilePictureImageView;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) NSDictionary* navigationData;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@end

@implementation SYNSideNavigationViewController

-(id)init
{
    self = [super initWithNibName:@"SYNSideNavigationViewController" bundle:nil];
    if (self) {
        
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
    return 4;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NavigationCell";
    UITableViewCell *cell;
    
    
    if(indexPath.section == 0) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        switch (indexPath.row) {
                
            case 0:
                
                cell.textLabel.text = @"Notification";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 1:
                cell.textLabel.text = @"Acounts";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 2:
                cell.textLabel.text = @"Settings";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 3:
                cell.textLabel.text = @"Buy";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            
                
            
                
        }
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
        cell.detailTextLabel.font = [UIFont rockpackFontOfSize:13.0];
        
        
    } 
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            
            break;
            
        case 1:
            
            break;
            
        case 2:
            
            break;
            
        case 3:
            
            break;
            
        case 4:
            
            break;
            
    }
 
}

@end
