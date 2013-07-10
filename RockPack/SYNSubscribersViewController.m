//
//  SYNSubscribersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSubscribersViewController.h"
#import "Channel.h"
#import "UIFont+SYNFont.h"

@interface SYNSubscribersViewController ()

@property (nonatomic, strong) UIActivityIndicatorView* activityView;

@end

@implementation SYNSubscribersViewController


-(id)initWithChannel:(Channel*)channel
{
    if (self = [super initWithViewId:kChannelDetailsViewId]) {
        
        self.title = NSLocalizedString(@"SUBSCRIBERS", nil);
        self.channel = channel;
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame: CGRectMake( -(self.contentSizeForViewInPopover.width * 0.5), -15.0, self.contentSizeForViewInPopover.width, 40.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor colorWithRed: (28.0/255.0) green: (31.0/255.0) blue: (33.0/255.0) alpha: (1.0)];
        titleLabel.text = NSLocalizedString (@"SUBSCRIBERS", nil);
        titleLabel.font = [UIFont boldRockpackFontOfSize:18.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        
        
        UIView * labelContentView = [[UIView alloc]init];
        [labelContentView addSubview:titleLabel];
        
        self.navigationItem.titleView = labelContentView;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    self.activityView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    
    [self.activityView hidesWhenStopped];
    
    [self.activityView startAnimating];
    
    [self.view addSubview:self.activityView];
    
    [appDelegate.networkEngine subscribersForUserId:appDelegate.currentUser.uniqueId
                                          channelId:self.channel.uniqueId
                                           forRange:self.dataRequestRange completionHandler:^{
                                               
                                               [self displayUsers];
                                               
                                               [self.activityView stopAnimating];
                                               
                                           } errorHandler:^{
                                               
                                               [self.activityView stopAnimating];
                                               
                                           }];
}



- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    if(self.parentPopover)
    {
        [self.parentPopover dismissPopoverAnimated:YES];
    }
    
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void) displayUsers
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName: @"ChannelOwner"
                                   inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    [request setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: request
                                                                                  error: &error];
    
    if (!resultsArray)
        return;
    
    self.users = [NSMutableArray arrayWithArray: resultsArray];
    
    [self.usersThumbnailCollectionView reloadData];
}



@end
