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
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.channelTitleTextField.alpha = 1.0f;
         self.channelTitleHighlightImageView.alpha = 1.0f;
     }
     completion: ^(BOOL finished)
     {
     }];

    if (fadeOthers == TRUE)
    {
        [self fadeDownBackground];
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
         self.channelTitleTextField.alpha = 0.5f;
         self.channelTitleHighlightImageView.alpha = 0.0f;
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) highlightCoverCarouselFadingOthers: (BOOL) fadeOthers
{
    self.channelCoverCarouselCollectionView.hidden = FALSE;
    
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.channelCoverCarouselCollectionView.alpha = 1.0f;
         self.channelTitleHighlightImageView.alpha = 1.0f;
     }
     completion: ^(BOOL finished)
     {
     }];
    
    if (fadeOthers == TRUE)
    {
        [self fadeDownBackground];
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
         self.channelCoverCarouselCollectionView.alpha = 0.5f;
         self.channelTitleHighlightImageView.alpha = 0.5f;
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) highlightChannelDescriptionFadingOthers: (BOOL) fadeOthers
{
    self.channelCoverCarouselCollectionView.hidden = FALSE;
    
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.channelCoverCarouselCollectionView.alpha = 1.0f;
         self.channelTitleHighlightImageView.alpha = 1.0f;
     }
                     completion: ^(BOOL finished)
     {
     }];
    
    if (fadeOthers == TRUE)
    {
        [self fadeDownBackground];
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
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) fadeUpBackground
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) fadeDownBackground
{
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
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
}

- (IBAction) userTouchedDoneButton: (id) sender
{
    NSLog (@"User touched done button");
    
    SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SYNBottomTabViewController *bottomTabViewController = delegate.viewController;
    
    [bottomTabViewController popCurrentViewController: nil];
}

#pragma mark - UITextField delegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [self showSaveButton];
    
    return YES;
}

#pragma mark - Growable UITextView delegates

- (void) growingTextViewDidBeginEditing: (HPGrowingTextView *) growingTextView
{
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = FALSE;
    
    [self highlightChannelDescriptionFadingOthers: YES];
}


- (void) growingTextViewDidEndEditing: (HPGrowingTextView *) growingTextView
{
    self.collectionHeaderView.channelDescriptionHightlightView.hidden = TRUE;
    [self.collectionHeaderView.channelDescriptionTextView scrollRangeToVisible: NSMakeRange (0,0)];
    [self.collectionHeaderView.channelDescriptionTextView resignFirstResponder];
    
    if ([growingTextView.text isEqualToString: @""])
    {
        //        growingTextView.text = @"Describe your channel...";
    }
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
    
    [self showSaveButton];
}



@end
