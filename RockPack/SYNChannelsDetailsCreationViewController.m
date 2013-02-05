//
//  SYNtChannelsDetailsCreationViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "HPGrowingTextView.h"
#import "SYNAppDelegate.h"
#import "SYNBottomTabViewController.h"
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
    self.saveOrDoneButtonLabel.hidden = FALSE;

    [self showDoneButton];
    
    self.channelCoverCarouselCollectionView.hidden = TRUE;
    
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


#pragma mark - UI Helpers

- (void) showDoneButton
{
    self.saveButton.hidden = TRUE;
    
    // We need to start off with the DONE button visible as user may choose not to customise anything
    self.doneButton.hidden = FALSE;
    self.saveOrDoneButtonLabel.text = NSLocalizedString(@"DONE", @"Save / Done button");
}

- (void) showSaveButton
{
    self.doneButton.hidden = TRUE;
    
    // We need to start off with the DONE button visible as user may choose not to customise anything
    self.saveButton.hidden = FALSE;
    self.saveOrDoneButtonLabel.text = NSLocalizedString(@"SAVE", @"Save / Done button");
}

- (void) highlightAll
{
    [self highlightChannelTitleFadingOthers: FALSE];
    [self highlightCoverCarouselFadingOthers: FALSE];
    [self highlightChannelDescriptionFadingOthers: FALSE];
}

- (void) highlightChannelTitleFadingOthers: (BOOL) fadeOthers
{
    self.channelTitleTextField.alpha = 1.0f;
    self.channelTitleTextField.enabled = TRUE;
    self.channelTitleHighlightImageView.alpha = 1.0f;
    
    if (fadeOthers == TRUE)
    {
        [self fadeCoverCarousel];
        [self fadeChannelDescription];
    }
}


- (void) fadeChannelTitle
{
    self.channelTitleTextField.alpha = 1.0f;
    self.channelTitleTextField.enabled = TRUE;
    self.channelTitleHighlightImageView.alpha = 1.0f;
}


- (void) highlightCoverCarouselFadingOthers: (BOOL) fadeOthers
{
    self.channelCoverCarouselCollectionView.alpha = 1.0f;
//    self.channelCoverCarouselCollectionView.enabled = TRUE;
    self.channelCoverCarouselCollectionView.hidden = FALSE;
    
    if (fadeOthers == TRUE)
    {
        [self fadeChannelTitle];
        [self fadeChannelDescription];
    }
}


- (void) fadeCoverCarousel
{
    self.channelTitleTextField.alpha = 1.0f;
//    self.channelCoverCarouselCollectionView.enabled = TRUE;
    self.channelTitleHighlightImageView.alpha = 1.0f;
}

- (void) highlightChannelDescriptionFadingOthers: (BOOL) fadeOthers
{
    if (fadeOthers == TRUE)
    {
        [self fadeChannelTitle];
        [self fadeCoverCarousel];
    }
}


- (void) fadeChannelDescription
{
}



#pragma mark - User Interaction

- (IBAction) userTouchedSaveButton: (id) sender
{
    NSLog (@"User touched save button");
}

- (IBAction) userTouchedDoneButton: (id) sender
{
    NSLog (@"User touched done button");
    
    SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SYNBottomTabViewController *bottomTabViewController = delegate.viewController;
    
    [bottomTabViewController popCurrentViewController: nil];
}

#pragma mark - Text Field delegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [self showSaveButton];
    
    return YES;
}

@end
