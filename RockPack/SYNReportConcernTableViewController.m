//
//  SYNReportConcernTableViewController.m
//  rockpack
//
//  Created by Nick Banks on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNReportConcernTableViewController.h"
#import "UIFont+SYNFont.h"

#define kConcernsCellId @"ConcernsCell"

@interface SYNReportConcernTableViewController ()

@property (nonatomic, strong) NSArray *concernsArray;

@end

@implementation SYNReportConcernTableViewController

- (id) initWithStyle: (UITableViewStyle) style
{
    if ((self = [super initWithStyle: style]))
    {
        // Custom initialization
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass: [UITableViewCell class]
           forCellReuseIdentifier: kConcernsCellId];

    self.concernsArray = @[@"Nudity or pornography",
                           @"Attacks a group or individual",
                           @"Graphic violence",
                           @"Hateful speech or symbols",
                           @"Actively promotes self-harm",
                           @"Spam",
                           @"Other"];
    
    UIButton *customCancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customCancelButtonImage = [UIImage imageNamed: @"ButtonMoveAndScaleCancel.png"];
    UIImage* customCancelButtonHighlightedImage = [UIImage imageNamed: @"ButtonMoveAndScaleCancel.png"];
    
    [customCancelButton setImage: customCancelButtonImage
                        forState: UIControlStateNormal];
    
    [customCancelButton setImage: customCancelButtonHighlightedImage
                        forState: UIControlStateHighlighted];
    
    [customCancelButton addTarget: self
                           action: @selector(_actionCancel)
                 forControlEvents: UIControlEventTouchUpInside];
    
    customCancelButton.frame = CGRectMake(0.0, 0.0, customCancelButtonImage.size.width, customCancelButtonImage.size.height);
    UIBarButtonItem *customCancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView: customCancelButton];
    
    self.navigationItem.leftBarButtonItem = customCancelButtonItem;
    
    UIButton *customUseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* customUseButtonImage = [UIImage imageNamed: @"ButtonMoveAndScaleUse.png"];
    UIImage* customUseButtonHighlightedImage = [UIImage imageNamed: @"ButtonMoveAndScaleUse.png"];
    
    [customUseButton setImage: customUseButtonImage
                     forState: UIControlStateNormal];
    
    [customUseButton setImage: customUseButtonHighlightedImage
                     forState: UIControlStateHighlighted];
    
    [customUseButton addTarget: self
                        action: @selector(_actionUse)
              forControlEvents: UIControlEventTouchUpInside];
    
    customUseButton.frame = CGRectMake(0.0, 0.0, customUseButtonImage.size.width, customUseButtonImage.size.height);
    UIBarButtonItem *customUseButtonItem = [[UIBarButtonItem alloc] initWithCustomView: customUseButton];
    
    self.navigationItem.rightBarButtonItem = customUseButtonItem;
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return self.concernsArray.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kConcernsCellId
                                                            forIndexPath: indexPath];

    cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
    cell.textLabel.text = self.concernsArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath *) tableView: (UITableView *) tableView
   willSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    [self.tableView cellForRowAtIndexPath: oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath: indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    return indexPath;
}


- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
}

@end
