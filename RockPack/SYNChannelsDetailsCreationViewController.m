//
//  SYNtChannelsDetailsCreationViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "HPGrowingTextView.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "SYNChannelHeaderView.h"
#import "SYNTextField.h"

@interface SYNChannelsDetailsCreationViewController ()

@end

@implementation SYNChannelsDetailsCreationViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Hide buttons not used in channel creation
    self.editButton.hidden = TRUE;
    self.shareButton.hidden = TRUE;
    self.channelCoverCarouselCollectionView.hidden = FALSE;
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = FALSE;
    self.collectionHeaderView.channelDescriptionTextView.text = @"Describe your channel...";
    
    // Set all labels and images to correspond to the selected channel
    self.channelTitleTextField.text = @"NAME YOUR CHANNEL...";
    self.userNameLabel.text = @"BY YOU";
    
    // set User's avatar picture
    [self.userAvatarImageView setImageFromURL: [NSURL URLWithString: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Sofia.png"]
                             placeHolderImage: nil];
    
    
    [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverBackground1.jpg"]
                                   placeHolderImage: nil];
}



@end
