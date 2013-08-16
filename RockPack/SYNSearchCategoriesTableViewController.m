//
//  SYNSearchCategoriesTableViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 13/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchCategoriesTableViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "SYNSearchCategoriesIphoneCell.h"
#import "SYNDeviceManager.h"

static NSString *SearchGenresTableCellIdentifier = @"SYNSearchCategoriesIphoneCell";

@interface SYNSearchCategoriesTableViewController ()

@property (nonatomic, strong) NSArray* searchCategories;
@property (nonatomic) BOOL hasRetried;
@property (nonatomic, strong) UIFont* cellFont;
@property (nonatomic, strong) UIColor* cellTextColor;

@end

@implementation SYNSearchCategoriesTableViewController
@synthesize hasRetried;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.cellFont = [UIFont rockpackFontOfSize: 16.0];
    self.cellTextColor = [UIColor colorWithRed:(106.0f/255.0f) green:(114.0f/255.0f) blue:(122.0f/255.0f) alpha:1.0f];
    
    [self.tableView registerClass:[SYNSearchCategoriesIphoneCell class] forCellReuseIdentifier:SearchGenresTableCellIdentifier];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor rockpacLedColor];
    self.tableView.backgroundColor = [UIColor colorWithRed: 241.0f/255.0f green: 241.0f/255.0f blue: 241.0f/255.0f alpha: 1.0f];
    self.tableView.scrollEnabled = NO;
    self.tableView.scrollsToTop = NO;

    
    
    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(void)loadData
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    [categoriesFetchRequest setEntity: categoryEntity];
    
    [categoriesFetchRequest setIncludesSubentities:NO]; // no subgenres needed
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"priority >= 0"];
    [categoriesFetchRequest setPredicate: predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                   ascending: NO];
    
    [categoriesFetchRequest setSortDescriptors: @[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = NO;
    
    NSError *error;
    
    self.searchCategories = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                error: &error];
    
    if (self.searchCategories.count == 0 && !hasRetried) // only request once
    {
        [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary *dictionary) {
            
                BOOL registryResultOk = [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
            
                if (!registryResultOk)
                {
                    DebugLog(@"*** Cannot Register Genre Objects! ***");
                    return;
                }
            
                [self loadData];
            
            } onError: ^(NSError *error) {
                DebugLog(@"%@", [error debugDescription]);
            }];
        
            hasRetried = YES;
            return;
    }
    
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.searchCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SYNSearchCategoriesIphoneCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchGenresTableCellIdentifier forIndexPath:indexPath];
    
    Genre* genre = self.searchCategories[indexPath.item];
    
    if ([genre.name isEqual: @"TV & NEWS"])
    {
        cell.textLabel.text = @"TV & News";
    }
    
    else
    {
        cell.textLabel.text = [genre.name capitalizedString];
    }
        
    cell.textLabel.font = self.cellFont;
    cell.textLabel.textColor = self.cellTextColor;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Genre* genreSelected = self.searchCategories[indexPath.item];
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSNotification* navigationNotification = [NSNotification notificationWithName: kNavigateToPage
                                                                           object: self
                                                                         userInfo: @{@"pageName":kChannelsViewId,
                                                                                     @"action":@"open", @"object":genreSelected}];
    
    [[NSNotificationCenter defaultCenter] postNotification: navigationNotification];
    
    [appDelegate.viewStackManager dismissSearchBarTotal:YES];
    
    
    
   
}

@end
