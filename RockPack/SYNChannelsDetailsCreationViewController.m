//
//  SYNtChannelsDetailsCreationViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "HPGrowingTextView.h"
#import "SYNAppDelegate.h"
#import "SYNBottomTabViewController.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import "SYNChannelHeaderView.h"
#import "SYNTextField.h"
#import "Channel.h"

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
    
    self.channelTitleTextField.enabled = TRUE;
    self.collectionHeaderView.viewControllerDelegate = self;

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
    
    // As we don't actually have a real channel at the moment, fake up the channel description
    self.channel.channelDescription = @"Describe your channel...";
}

//- (void) viewDidAppear: (BOOL) animated
//{
//    [super viewDidAppear: animated];
//    self.channel.channelDescription = @"Describe your channel...";
//}


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
    
    self.changeCoverButton.enabled = TRUE;
    
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.changeCoverButton.alpha = 1.0f;
         self.changeCoverLabel.alpha = 1.0f;
        self.channelCoverCarouselCollectionView.alpha = 0.0f;
     }
                     completion: ^(BOOL finished)
     {
     }];

}

- (void) highlightChannelTitleFadingOthers: (BOOL) fadeOthers
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.headerBarView.alpha = 1.0;
         self.videoThumbnailCollectionView.alpha = 1.0;
     }
     completion: ^(BOOL finished)
     {
     }];

    if (fadeOthers == TRUE)
    {
        [self fadeCoverCarousel];
        [self fadeChannelDescription];
    }
}




- (void) fadeChannelTitle
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.headerBarView.alpha = 0.5;
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) highlightCoverCarouselFadingOthers: (BOOL) fadeOthers
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.coverSelectionView.alpha = 1.0f;
     }
     completion: ^(BOOL finished)
     {
     }];
    
    if (fadeOthers == TRUE)
    {
        [self fadeChannelTitle];
        [self fadeChannelDescription];
    }
}


- (void) fadeCoverCarousel
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.coverSelectionView.alpha = 0.5f;
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) highlightChannelDescriptionFadingOthers: (BOOL) fadeOthers
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.videoThumbnailCollectionView.alpha = 1.0;
     }
                     completion: ^(BOOL finished)
     {
     }];
    
    if (fadeOthers == TRUE)
    {
        [self fadeChannelTitle];
        [self fadeCoverCarousel];
    }
}


- (void) fadeChannelDescription
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
        self.videoThumbnailCollectionView.alpha = 0.5;
     }
                     completion: ^(BOOL finished)
     {
     }];
}


#pragma mark - User Interaction

- (IBAction) userTouchedSaveButton: (id) sender
{
    [self highlightAll];
    [self showDoneButton];
    [self.channelTitleTextField resignFirstResponder];
    [self.collectionHeaderView.channelDescriptionTextView resignFirstResponder];
}

- (IBAction) userTouchedDoneButton: (id) sender
{
    NSLog (@"User touched done button");
    
    SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SYNBottomTabViewController *bottomTabViewController = delegate.viewController;
    
    [bottomTabViewController popCurrentViewController: nil];
}

- (IBAction) userTouchedChangeCoverButton: (id) sender
{
    self.channelCoverCarouselCollectionView.hidden = FALSE;
    self.channelCoverCarouselCollectionView.alpha = 0.0f;
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.channelCoverCarouselCollectionView.alpha = 1.0f;
         self.channelTitleHighlightImageView.alpha = 1.0f;
         self.changeCoverButton.alpha = 0.0;
         self.changeCoverLabel.alpha = 0.0;
     }
                     completion: ^(BOOL finished)
     {
         self.changeCoverButton.enabled = FALSE;
     }];
    
    [self highlightCoverCarouselFadingOthers: YES];
    [self showSaveButton];
}


#pragma mark - UITextField delegate

- (BOOL) textFieldShouldBeginEditing: (UITextField *) textField
{
    // Only enable editing if we have the focus
    if (self.channelTitleTextField.alpha == 1.0f)
    {
        if ([textField.text isEqualToString: @"NAME YOUR CHANNEL..."])
        {
            textField.text = @"";
        }
        
        [self highlightChannelTitleFadingOthers: YES];
        [self showSaveButton];
        
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    if ([textField.text isEqualToString: @""])
    {
        textField.text = @"NAME YOUR CHANNEL...";
    }
    
    [self showDoneButton];
    [self.channelTitleTextField resignFirstResponder];
    [self highlightAll];
    
    return YES;
}

#pragma mark - Growable UITextView delegates

- (void) growingTextViewDidChange: (HPGrowingTextView *) growingTextView
{
    NSLog (@"Changed");
}

- (void) growingTextViewDidBeginEditing: (HPGrowingTextView *) growingTextView
{
    [growingTextView becomeFirstResponder];
//    self.collectionHeaderView.channelDescriptionHightlightView.hidden = FALSE;
    [self highlightChannelDescriptionFadingOthers: YES];
    [self showSaveButton];
    
    if ([growingTextView.text isEqualToString: @"Describe your channel..."])
    {
        growingTextView.text = @"";
    }
}


- (void) growingTextViewDidEndEditing: (HPGrowingTextView *) growingTextView
{
//    self.collectionHeaderView.channelDescriptionHightlightView.hidden = TRUE;
    [self.collectionHeaderView.channelDescriptionTextView scrollRangeToVisible: NSMakeRange (0,0)];
    [self.collectionHeaderView.channelDescriptionTextView resignFirstResponder];
    
    if ([growingTextView.text isEqualToString: @""])
    {
        growingTextView.text = @"Describe your channel...";
    }
    
    [self showDoneButton];
    [self.channelTitleTextField resignFirstResponder];
    [self highlightAll];
}


- (void) growingTextView: (HPGrowingTextView *) growingTextView
        willChangeHeight: (float) height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect containerViewFrame = self.collectionHeaderView.channelDescriptionTextContainerView.frame;
    containerViewFrame.size.height -= diff;
    //    containerViewFrame.origin.y += diff;
	self.collectionHeaderView.channelDescriptionTextContainerView.frame = containerViewFrame;
}





@end
