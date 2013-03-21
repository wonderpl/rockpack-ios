//
//  SYNAccountSettingsLocation.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsLocation.h"

@interface SYNAccountSettingsLocation ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation SYNAccountSettingsLocation

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
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"United States";
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"United Kingdom";
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

@end
