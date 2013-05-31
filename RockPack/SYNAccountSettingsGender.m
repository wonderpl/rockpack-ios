//
//  SYNAccountSettingsGender.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "SYNAccountSettingsGender.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNDeviceManager.h"

@interface SYNAccountSettingsGender ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end


@implementation SYNAccountSettingsGender

- (id) init
{
    if ((self = [super init]))
    {
        self.contentSizeForViewInPopover = CGSizeMake(380, 476);
        
        BOOL isIpad = [SYNDeviceManager.sharedInstance isIPad];
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0, 0.0, (isIpad ? 380 : 320.0), 100.0) style: UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundView = nil;
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        CGRect spinnerFrame = self.spinner.frame;
        spinnerFrame.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 20.0;
        spinnerFrame.origin.x = self.tableView.frame.size.width * 0.5 - spinnerFrame.size.width * 0.5;
        self.spinner.frame = CGRectIntegral(spinnerFrame);
        [self.view addSubview: self.spinner];
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"Cell"];
    
    UIButton *backButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    UIImage* backButtonHighlightedImage = [UIImage imageNamed: @"ButtonAccountBackHighlighted.png"];

    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton setImage: backButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [backButton addTarget: self
                   action: @selector(didTapBackButton:)
         forControlEvents: UIControlEventTouchUpInside];
    
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
}


- (void) didTapBackButton: (id) sender
{
    if (self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
}


#pragma mark - TableView DataSource/Delegate

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return 2;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    if (indexPath.row == 0)
    {
        if (self.appDelegate.currentUser.genderValue == GenderMale)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.text = NSLocalizedString (@"Male", nil);
    }
    else if (indexPath.row == 1)
    {
        if (self.appDelegate.currentUser.genderValue == GenderFemale)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.text = NSLocalizedString (@"Female", nil);
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark) // if it is already selected, return.
        return;
    
    
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UITableViewCell*)obj).accessoryType = UITableViewCellAccessoryNone;
    }];
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self changeUserGenderForValue:( indexPath.row == 0 ? @"m" : @"f")];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [self.spinner startAnimating];
    
}


- (void) changeUserGenderForValue: (NSString*) newGender
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [self.appDelegate.oAuthNetworkEngine changeUserField: @"gender"
                                                 forUser: self.appDelegate.currentUser
                                            withNewValue: newGender
                                       completionHandler: ^ (NSDictionary * dictionary){
                                           if([newGender isEqualToString: @"m"])
                                           {
                                               self.appDelegate.currentUser.gender = @(GenderMale);
                                               
                                               [tracker setCustom: kGADimensionGender
                                                        dimension: @"male"];
                                           }
                                           else if([newGender isEqualToString: @"f"])
                                           {
                                               self.appDelegate.currentUser.gender = @(GenderFemale);
                                               
                                               [tracker setCustom: kGADimensionGender
                                                        dimension: @"female"];
                                           }
                                           else
                                           {
                                               self.appDelegate.currentUser.gender = @(GenderUndecided);
                                               
                                               [tracker setCustom: kGADimensionGender
                                                        dimension: @"unknown"];
                                           }
                                           
                                           [self.appDelegate saveContext: YES];
                                           
                                           [self.spinner stopAnimating];
                                           
                                           [self.navigationController popViewControllerAnimated: YES];
                                           
                                       }
                                            errorHandler: ^(id errorInfo) {
                                                [self.spinner stopAnimating];
                                            }];
}

@end
