//
//  SYNAccountSettingsLocation.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsLocation.h"
#import "User.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNDeviceManager.h"

@interface SYNAccountSettingsLocation ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, weak) User* user;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;

@end

@implementation SYNAccountSettingsLocation
@synthesize appDelegate;

-(id)init
{
    if(self = [super init]) {
        
        
        
        self.contentSizeForViewInPopover = CGSizeMake(380, 476);
        
        BOOL isIpad = [[SYNDeviceManager sharedInstance] isIPad];
        
        
        CGRect tableViewFrame = CGRectMake(0.0, 0.0, (isIpad ? 380.0 : 320.0), 100.0);
        self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundView = nil;
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.user = appDelegate.currentUser;
        
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
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
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"United States";
        if([self.user.locale isEqualToString:@"en-us"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"United Kingdom";
        if([self.user.locale isEqualToString:@"en-gb"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    
    
    return cell;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark) // if it is already selected, return.
        return;
    
    
    [appDelegate clearUserBoundData];
    
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UITableViewCell*)obj).accessoryType = UITableViewCellAccessoryNone;
    }];
    
    [self changeUserLocaleForValue:(indexPath.row == 1) ? @"en-gb" : @"en-us"];
    
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.spinner startAnimating];
}

-(void)changeUserLocaleForValue:(NSString*)newLocale
{
    [self.appDelegate.oAuthNetworkEngine changeUserField:@"locale"
                                                 forUser:appDelegate.currentUser
                                            withNewValue:newLocale
                                       completionHandler:^ {
                                           
                                           self.user.locale = newLocale; ;
                                           [self.spinner stopAnimating];
                                           
                                           [self.appDelegate saveContext:YES];
                                           
                                           [self.navigationController popViewControllerAnimated:YES];
                                           
                                       } errorHandler:^(id errorInfo) {
                                           
                                           
                                           [self.spinner stopAnimating];
                                           
                                           
                                           
                                       }];
}

@end
