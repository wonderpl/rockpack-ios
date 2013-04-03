//
//  SYNAccountSettingsGender.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsGender.h"
#import "SYNAppDelegate.h"
#import "AppConstants.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNAccountSettingsGender ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@end

@implementation SYNAccountSettingsGender
@synthesize appDelegate;
- (id)init
{
    self = [super init];
    if (self) {
        
        self.contentSizeForViewInPopover = CGSizeMake(380, 476);
        CGRect tableViewFrame = CGRectMake(10.0, 10.0, self.contentSizeForViewInPopover.width - 10.0, 100.0);
        self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundView = nil;
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect spinnerFrame = self.spinner.frame;
        spinnerFrame.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 20.0;
        spinnerFrame.origin.x = self.tableView.frame.size.width * 0.5 - spinnerFrame.size.width * 0.5;
        self.spinner.frame = CGRectIntegral(spinnerFrame);
        [self.view addSubview:self.spinner];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed:@"ButtonAccountBackDefault.png"];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
}

- (void) didTapBackButton:(id)sender {
    if(self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Male";
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"Female";
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [self.tableView reloadData];
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (indexPath.row == 0) {
        [self changeUserGenderForValue:@"m"];
    } else {
        [self changeUserGenderForValue:@"f"];
    }
    
    
    [self.spinner startAnimating];
    
}


-(void)changeUserGenderForValue:(NSString*)newGender
{
    
    [self.appDelegate.oAuthNetworkEngine changeUserField:@"gender"
                                                 forUser:appDelegate.currentUser
                                            withNewValue:newGender
                                       completionHandler:^ {
                                           
                                           if([newGender isEqualToString:@"m"]) {
                                               
                                               appDelegate.currentUser.gender = @(GenderMale);
                                               
                                           } else if([newGender isEqualToString:@"f"]) {
                                               
                                               appDelegate.currentUser.gender = @(GenderFemale);
                                               
                                           }
                                           
                                           [self.appDelegate saveContext:YES];
                                           
                                           
                                           [self.spinner stopAnimating];
                                           
                                           [self.navigationController popViewControllerAnimated:YES];
                                           
                                       } errorHandler:^(id errorInfo) {
                                           
                                           
                                           [self.spinner stopAnimating];
                                           
                                           
                                           
                                       }];
}

@end
