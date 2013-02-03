//
//  SYNChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "SYNAppDelegate.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNNetworkEngine.h"

@interface SYNChannelsDetailViewController ()

@end

@implementation SYNChannelsDetailViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadCollectionViews)
                                                 name: kDataUpdated
                                               object: nil];
    
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    [appDelegate.networkEngine updateChannel: self.channel.resourceURL];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kDataUpdated
                                                  object: nil];
}


- (void) reloadCollectionViews
{
    self.videoInstancesArray = [NSMutableArray arrayWithArray: self.channel.videoInstancesSet.array];
    [self.videoThumbnailCollectionView reloadData];
}

@end
