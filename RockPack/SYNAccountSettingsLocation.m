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

@interface SYNAccountSettingsLocation ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, weak) User* user;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNAccountSettingsLocation
@synthesize appDelegate;

-(id)init
{
    if(self = [super init]) {
        self.contentSizeForViewInPopover = CGSizeMake(380, 476);
        CGRect tableViewFrame = CGRectMake(10.0, 10.0, self.contentSizeForViewInPopover.width - 10.0, 100.0);
        self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundView = nil;
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.user = appDelegate.currentUser;
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
    
    
    
    NSString* oldLocale = self.user.locale;
    
    if(indexPath.row == 1) {
        self.user.locale = @"en-gb";
    } else {
        self.user.locale = @"en-us";
    }
    if(![oldLocale isEqualToString:self.user.locale]) {
        // clear core data
        [appDelegate clearData];
    }
    
    
    [self.tableView reloadData];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
