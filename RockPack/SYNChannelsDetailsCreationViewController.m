//
//  SYNChannelsDetailsCreationViewController.m
//  rockpack
//
//  Created by Nick Banks on 08/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNTextField.h"
#import "UIImageView+MKNetworkKitAdditions.h"

@implementation SYNChannelsDetailsCreationViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Hide buttons not used in channel creation
    self.editButton.hidden = TRUE;
    self.shareButton.hidden = TRUE;
    self.saveOrDoneButtonLabel.hidden = FALSE;
    
    self.channelTitleTextField.enabled = TRUE;
    
    [self showDoneButton];
    
    self.channelCoverCarouselCollectionView.hidden = TRUE;
    
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = FALSE;
    self.collectionHeaderView.channelDescriptionTextView.text = @"Describe your channel...";
    
    // Set all labels and images to correspond to the selected channel
    self.channelTitleTextField.text = @"NAME YOUR CHANNEL...";
    self.userNameLabel.text = @"BY YOU";
    self.changeCoverLabel.text = @"ADD A COVER";
    
    // set User's avatar picture
    [self.userAvatarImageView setImageFromURL: [NSURL URLWithString: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Sofia.png"]
                             placeHolderImage: nil];
    
    
    [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverBackground1.jpg"]
                                   placeHolderImage: nil];
    
    // As we don't actually have a real channel at the moment, fake up the channel description
    self.channel.channelDescription = @"Describe your channel...";
}

- (BOOL) hideChannelDescriptionHighlight
{
    return FALSE;
}

@end
