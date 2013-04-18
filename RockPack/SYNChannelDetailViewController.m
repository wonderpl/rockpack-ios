//
//  SYNChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNChannelHeaderView.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNTextField.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "UIImageView+ImageProcessing.h"


@interface SYNChannelDetailViewController ()

@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) Channel *channel;

@end

@implementation SYNChannelDetailViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Channels - Detail";
    
    // Set wallpaper
    [self.avatarImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL]
                                     placeHolderImage: nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadCollectionViews)
                                                 name: kDataUpdated
                                               object: nil];
    
    if ([self.channel.resourceURL hasPrefix: @"https"])
    {
        [appDelegate.oAuthNetworkEngine updateChannel: self.channel.resourceURL];
    }
    else
    {
        [appDelegate.networkEngine updateChannel: self.channel.resourceURL];
    }
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
    [self.videoThumbnailCollectionView reloadData];
}


- (BOOL) needsAddButton
{
    return YES;
}


- (void) shareChannelButtonTapped: (id) sender
{
    NSString *messageString = kChannelShareMessage;
    
//  TODO: Put in cover art image?
//  UIImage *messageImage = [UIImage imageNamed: @"xyz.png"];
    
    // TODO: Put in real link
    NSURL *messageURL = [NSURL URLWithString: @"http://www.rockpack.com"];
    
    [self shareURL: messageURL
       withMessage: messageString
          fromRect: self.shareButton.frame
   arrowDirections: UIPopoverArrowDirectionUp];
}

@end
