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
#import "SYNChannelHeaderView.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNChannelHeaderView.h"
#import "SYNNetworkEngine.h"
#import "SYNTextField.h"
#import "UIImageView+MKNetworkKitAdditions.h"

@interface SYNChannelsDetailViewController ()

@end

@implementation SYNChannelsDetailViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Show edit and share buttons
    
    if (![self.channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId])
    {
        self.editButton.hidden = YES;
        self.buyButton.hidden = NO;
        self.buyEditLabel.text = @"BUY";
        
    }
    else
    {
        self.editButton.hidden = NO;
        self.buyButton.hidden = YES;
        self.buyEditLabel.text = @"EDIT";
    }
    
    self.shareButton.hidden = FALSE;
    
    // Hide save or done buttons and hide cover selection carousel
    self.saveOrDoneButtonLabel.hidden = NO;
    self.saveOrDoneButtonLabel.text = @"SHARE";
    self.coverSelectionView.hidden = YES;
    
    // Remove text field highlightes
    self.channelTitleHighlightImageView.hidden = TRUE;
    self.channelDescriptionHightlightView.hidden = TRUE;
    
    // Disable text fields until edit button selected
    self.channelTitleTextField.enabled = FALSE;
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadCollectionViews)
                                                 name: kDataUpdated
                                               object: nil];
    
    
    [appDelegate.networkEngine updateChannel: self.channel.resourceURL];
}

-(IBAction)tappedOnUserAvatar:(UIButton*)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserChannels object:self userInfo:@{@"ChannelOwner":self.channel.channelOwner}];
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

@end
