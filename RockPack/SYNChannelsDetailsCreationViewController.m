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
    self.channelDescriptionTextView.text = @"Describe your channel...";
}

- (void) viewWillAppear: (BOOL) animated
{
    
    [self.channelWallpaperImageView setImageFromURL: [NSURL URLWithString: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/75/ChannelCreationCoverBackground1.jpg"]
                                   placeHolderImage: nil];
}

@end
