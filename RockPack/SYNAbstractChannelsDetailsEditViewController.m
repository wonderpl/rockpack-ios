//
//  SYNtChannelsDetailsCreationViewController.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "HPGrowingTextView.h"
#import "SYNAbstractChannelsDetailsEditViewController.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"
#import "SYNChannelHeaderView.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNTextField.h"
#import "SYNOAuth2Credential.h"
#import "UIImageView+MKNetworkKitAdditions.h"

@interface SYNAbstractChannelsDetailsEditViewController ()

@end

@implementation SYNAbstractChannelsDetailsEditViewController

#pragma mark - UI Helpers

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionHeaderView.viewControllerDelegate = self;
}

- (void) showDoneButton
{
    self.saveButton.hidden = YES;
    
    // We need to start off with the DONE button visible as user may choose not to customise anything
    self.doneButton.hidden = NO;
    self.saveOrDoneButtonLabel.text = NSLocalizedString(@"DONE", @"Save / Done button");
    
    self.buyButton.hidden = YES;
    self.buyEditLabel.hidden = YES;
    // Need also to hide our carousel
    
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.channelCoverCarouselCollectionView.alpha = 0.0f;
         self.selectACoverLabel.alpha = 0.0f;
     }
     completion: ^(BOOL finished)
     {
     }];
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
    self.changeCoverButton.alpha = 1.0f;
    self.changeCoverLabel.alpha = 1.0f;
    
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.changeCoverButton.alpha = 1.0f;
         self.changeCoverLabel.alpha = 1.0f;
         self.channelCoverCarouselCollectionView.alpha = 0.0f;
         self.selectACoverLabel.alpha = 0.0f;
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
         self.headerBarView.alpha = 0.0;
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
         self.coverSelectionView.alpha = 0.0f;
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
        self.videoThumbnailCollectionView.alpha = 0.0;
     }
                     completion: ^(BOOL finished)
     {
     }];
}


#pragma mark - User Interaction

- (IBAction) userTouchedSaveButton: (id) sender
{
    if (self.coverSelectionView.alpha == 1.0f)
    {
            self.changeCoverLabel.text = @"CHANGE COVER";
    }
    
    [self highlightAll];
    [self showDoneButton];
    [self.channelTitleTextField resignFirstResponder];
    [self.collectionHeaderView.channelDescriptionTextView resignFirstResponder];

}

- (void) updateVideosForChannel: (NSString *) channelId
{
    
}

- (IBAction) userTouchedDoneButton: (id) sender
{
    NSLog (@"User touched done button");
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteShowTabBar
                                                        object: self];
    
    self.editButton.hidden = NO;
    self.buyEditLabel.hidden = NO;
    self.buyEditLabel.text = @"EDIT";
    self.shareButton.hidden = NO;
    self.saveOrDoneButtonLabel.text = @"SHARE";
    self.saveButton.hidden = TRUE;
    
    self.categoryButton.hidden = YES;
    self.categoryStaticLabel.hidden = NO;
    self.privateImageView.hidden = YES;
    
    self.doneButton.hidden = YES;
    
    self.coverSelectionView.hidden = YES;
    
    // Remove text field highlightes
    self.channelTitleHighlightImageView.hidden = YES;
    self.channelDescriptionHightlightView.hidden = YES;
    
    // Disable text fields until edit button selected
    self.channelTitleTextField.enabled = NO;
    
    CGRect labelFrame = self.categoryLabel.frame;
    labelFrame.origin.x = 536;
    labelFrame.origin.y = 31;
    self.categoryLabel.frame = labelFrame;
    self.categoryLabel.textAlignment = NSTextAlignmentLeft;
    
    [self updateCategoryLabel];
    
    // TODO: Fix coverart id and public
    //    {
    //        "title": "channel title",
    //        "description": "channel description",
    //        "category": 1,
    //        "cover": "COVERARTID",
    //        "public": true
    //    }
    
    // Do we create a new channel, or just update an existing one
    if ([self.channel.uniqueId isEqualToString: kNewChannelPlaceholderId])
    {
        // Create a new channel
        [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentUser.uniqueId
                                                         title: self.channelTitleTextField.text
                                                   description: self.collectionHeaderView.channelDescriptionTextView.text
                                                      category: @"123"
                                                         cover: @""
                                                      isPublic: TRUE
                                             completionHandler: ^(NSDictionary *responseDictionary) {
                                                 
             DebugLog(@"Channel creation successful");
             
             NSString *newChannelId = responseDictionary[@"id"];
             
             if (newChannelId != nil && ([newChannelId isEqualToString: @""] == FALSE))
             {
                 // Set our channel Id to the one returned from the server
                 self.channel.uniqueId = newChannelId;
                 
                 // Now upload the list of videos for the channel
                 [appDelegate.oAuthNetworkEngine updateVideosForChannelForUserId: appDelegate.currentUser.uniqueId
                                                                       channelId: newChannelId
                                                                videoInstanceSet: self.channel.videoInstancesSet
                                                               completionHandler: ^(NSDictionary *responseDictionary) {
                                                                   
                                                                   [[NSNotificationCenter defaultCenter]
                                                                    postNotificationName:kVideoQueueChannelCreated object:self];
                                                                   
                                                                   DebugLog(@"Channel video array update successful");
                                                                   
                                                               } errorHandler: ^(NSDictionary* errorDictionary) {
                                                                   
                                                                   DebugLog(@"Channel video array update failed");
                                                               }];
                }
             
             else
             {
                 AssertOrLog(@"No channel Id returned after channel creation");
             }
         }
         errorHandler: ^(NSDictionary* errorDictionary)
         {
             DebugLog(@"Channel creation failed");
             NSDictionary* formErrors = [errorDictionary objectForKey: @"form_errors"];
             
             if(formErrors)
             {
                 // TODO: Show errors in channel creation
                 //           [self showRegistrationError:formErrors];
             }
         }];
    }
    else
    {
        // Update an existing channel
        [appDelegate.oAuthNetworkEngine updateChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     channelId: self.channel.uniqueId
                                                         title: self.channelTitleTextField.text
                                                   description: self.collectionHeaderView.channelDescriptionTextView.text
                                                      category: @"123"
                                                         cover: @""
                                                      isPublic: TRUE
         completionHandler: ^(NSDictionary *responseDictionary)
         {
             DebugLog(@"Channel update successful");

             // Now upload the list of videos for the channel
             [appDelegate.oAuthNetworkEngine updateVideosForChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                                   channelId: self.channel.uniqueId
                                                            videoInstanceSet: self.channel.videoInstancesSet
                                                           completionHandler: ^(NSDictionary *responseDictionary) {
                                                               
                                                               DebugLog(@"Channel video array update successful");
                                                               
                                                               [[NSNotificationCenter defaultCenter]
                                                                postNotificationName:kVideoQueueChannelCreated object:self];
                                                           
                                                           } errorHandler: ^(NSDictionary* errorDictionary) {
                                                                    DebugLog(@"Channel video array update failed");
                                                            }];
         }
         errorHandler: ^(NSDictionary* errorDictionary)
         {
             DebugLog(@"Channel creation failed");
             NSDictionary* formErrors = [errorDictionary objectForKey: @"form_errors"];
             
             if(formErrors)
             {
                 // TODO: Show errors in channel creation
                 //           [self showRegistrationError:formErrors];
             }
         }];
    }
}

- (IBAction) userTouchedChangeCoverButton: (id) sender
{
    self.channelCoverCarouselCollectionView.hidden = FALSE;
    self.channelCoverCarouselCollectionView.alpha = 0.0f;
    self.selectACoverLabel.alpha = 0.0f;
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.channelCoverCarouselCollectionView.alpha = 1.0f;
         self.selectACoverLabel.alpha = 1.0f;
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
    [self.channelCoverCarouselCollectionView reloadData];
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



-(IBAction)tappedOnUserAvatar:(UIButton*)sender
{
    // override
}
- (IBAction) userTouchedEditButton: (UIButton *) sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected)
    {
        // Enter edit mode
        // Hide share button (as that is where the save / done buttons appear
        self.shareButton.hidden = TRUE;
        
        // Show save or done buttons and hide cover selection carousel
        self.saveOrDoneButtonLabel.hidden = FALSE;
        self.doneButton.hidden = FALSE;
        self.coverSelectionView.hidden = FALSE;
        
        // Add text field highlightes
        self.channelTitleHighlightImageView.hidden = FALSE;
        self.channelDescriptionHightlightView.hidden = FALSE;
        
        // Enable text fields until edit button selected
        self.channelTitleTextField.enabled = TRUE;
        self.collectionHeaderView.channelDescriptionTextView.editable = TRUE;
    }
    else
    {
        // Leave edit mode
        // Show share button (as that is where the save / done buttons appear
        self.shareButton.hidden = FALSE;
        
        // Hide save or done buttons and hide cover selection carousel
        self.saveOrDoneButtonLabel.hidden = TRUE;
        self.doneButton.hidden = TRUE;
        self.coverSelectionView.hidden = TRUE;
        
        // Remove text field highlightes
        self.channelTitleHighlightImageView.hidden = TRUE;
        self.channelDescriptionHightlightView.hidden = TRUE;
        
        // Disable text fields until edit button selected
        self.channelTitleTextField.enabled = FALSE;
        self.collectionHeaderView.channelDescriptionTextView.editable = FALSE;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

@end
