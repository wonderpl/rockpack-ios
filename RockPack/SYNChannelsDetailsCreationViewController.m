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
#import "UIImageView+ImageProcessing.h"

@implementation SYNChannelsDetailsCreationViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Hide buttons not used in channel creation
    self.editButton.hidden = YES;
    self.shareButton.hidden = YES;
    self.saveOrDoneButtonLabel.hidden = NO;
    
    self.channelTitleTextField.enabled = YES;
    
    [self showDoneButton];
    
    self.channelCoverCarouselCollectionView.hidden = TRUE;
    
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = FALSE;
    self.collectionHeaderView.channelDescriptionTextView.text = @"Describe your channel...";
    
    // Set all labels and images to correspond to the selected channel
    self.channelTitleTextField.text = @"NAME YOUR CHANNEL...";
    self.displayNameLabel.text = @"BY YOU";
    self.changeCoverLabel.text = @"ADD A COVER";
    
    // set User's avatar picture
    [self.userAvatarImageView setAsynchronousImageFromURL: [NSURL URLWithString: @"http://demo.dev.rockpack.com.s3.amazonaws.com/images/Sofia.png"]
                                         placeHolderImage: nil];
    
    // As we don't actually have a real channel at the moment, fake up the channel description
    self.channel.channelDescription = @"Describe your channel...";
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteHideTabBar
                                                        object: self];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteShowTabBar
                                                        object: self];
    
    [super viewWillDisappear: animated];
}

- (BOOL) hideChannelDescriptionHighlight
{
    return FALSE;
}

@end
