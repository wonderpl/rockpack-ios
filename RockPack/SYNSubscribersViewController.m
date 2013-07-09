//
//  SYNSubscribersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSubscribersViewController.h"
#import "Channel.h"

@interface SYNSubscribersViewController ()

@property (nonatomic, strong) UIActivityIndicatorView* activityView;

@end

@implementation SYNSubscribersViewController


-(id)initWithChannel:(Channel*)channel
{
    if (self = [super initWithViewId:kChannelDetailsViewId]) {
        self.title = @"SUBSCRIBERS";
        self.channel = channel;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self.activityView hidesWhenStopped];
    
    [self.activityView startAnimating];
    
    [self.view addSubview:self.activityView];
    
    [appDelegate.networkEngine subscribersForUserId:appDelegate.currentUser.uniqueId
                                          channelId:self.channel.uniqueId
                                           forRange:self.dataRequestRange ompletionHandler:^{
                                               
                                               [self displayUsers];
                                               
                                               [self.activityView stopAnimating];
                                               
                                           } errorHandler:^{
                                               
                                               [self.activityView stopAnimating];
                                               
                                           }];
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
