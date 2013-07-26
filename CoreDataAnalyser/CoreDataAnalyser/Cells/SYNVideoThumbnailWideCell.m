//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNVideoThumbnailWideCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface SYNVideoThumbnailWideCell ()

@property (nonatomic, strong) IBOutlet UIButton *channelButton;
@property (nonatomic, strong) IBOutlet UIButton *profileButton;
@property (nonatomic, strong) IBOutlet UIButton *videoButton;
@property (nonatomic, strong) IBOutlet UIImageView *highlightedBackgroundView;
@property (nonatomic, strong) IBOutlet UILabel* byLabel;
@property (nonatomic, strong) IBOutlet UILabel* fromLabel;

@end

@implementation SYNVideoThumbnailWideCell

@synthesize viewControllerDelegate = _viewControllerDelegate;
@synthesize displayMode = _displayMode;
@synthesize usernameText;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.highlightedBackgroundView.hidden = TRUE;
    
    self.displayMode = kVideoThumbnailDisplayModeChannel; // default is channel
    
    
}



#pragma mark - Switch Between Modes

- (void) setDisplayMode: (kVideoThumbnailDisplayMode) displayMode
{
    _displayMode = displayMode;
    
    if (displayMode == kVideoThumbnailDisplayModeChannel)
    {
        self.videoInfoView.hidden = YES;
        self.channelInfoView.hidden = NO;
    }
    else if (displayMode == kVideoThumbnailDisplayModeYoutube)
    {
        self.channelInfoView.hidden = YES;
        self.videoInfoView.hidden = NO;
    }
    else
    {
        NSLog(@"Unexpected option");
    }
}


#pragma mark - Asynchronous image loading support

// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;

    // Add button targets
    
    [self.videoButton addTarget: self.viewControllerDelegate
                         action: @selector(displayVideoViewerFromView:)
               forControlEvents: UIControlEventTouchUpInside];
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(videoAddButtonTapped:)
               forControlEvents: UIControlEventTouchUpInside];
    
    // User touches channel thumbnail
    [self.channelButton addTarget: self.viewControllerDelegate
                           action: @selector(channelButtonTapped:)
                 forControlEvents: UIControlEventTouchUpInside];
    
    // User touches user details
    [self.profileButton addTarget: self.viewControllerDelegate
                           action: @selector(profileButtonTapped:)
                 forControlEvents: UIControlEventTouchUpInside];
}


- (void) setUsernameText: (NSString *) text
{
    
    
        self.usernameLabel.text = text;
    
}


- (void) setChannelNameText:(NSString *)channelNameText
{

        self.channelName.text = channelNameText;
    
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    [self.layer removeAllAnimations];
    
    [self.videoImageView.layer removeAllAnimations];
    [self.videoImageView setImageWithURL:nil];
    
    [self.channelImageView.layer removeAllAnimations];
    [self.channelImageView setImageWithURL:nil];
}

@end
