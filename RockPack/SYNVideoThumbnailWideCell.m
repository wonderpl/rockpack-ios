//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

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
    
    self.videoTitle.font = [UIFont boldRockpackFontOfSize: self.videoTitle.font.pointSize];
    
    self.fromLabel.font = [UIFont rockpackFontOfSize: self.fromLabel.font.pointSize];
    self.channelName.font = [UIFont boldRockpackFontOfSize: self.channelName.font.pointSize];
    
    self.usernameLabel.font = [UIFont rockpackFontOfSize: self.usernameLabel.font.pointSize];
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    
    self.numberOfViewLabel.font = [UIFont rockpackFontOfSize: self.numberOfViewLabel.font.pointSize];
    self.youTubeUserLabel.font = [UIFont rockpackFontOfSize: self.youTubeUserLabel.font.pointSize];
    self.dateAddedLabel.font = [UIFont rockpackFontOfSize: self.dateAddedLabel.font.pointSize];
    self.durationLabel.font = [UIFont rockpackFontOfSize: self.durationLabel.font.pointSize];
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
        AssertOrLog(@"Unexpected option");
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
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        //CGRect byFrame = self.byLabel.frame;
        CGRect usernameFrame = self.usernameLabel.frame;
        
        if ([SYNDeviceManager.sharedInstance isLandscape])
        {
            // Landscape
            //byFrame.origin.x = 78.0f;
            usernameFrame.origin.x = 78.0f;
            //byFrame.origin.y = 66.0f;
            usernameFrame.origin.y = 66.0f;
            usernameFrame.size.width = 160.0f;
        }
        else
        {
            // Portrait
            //byFrame.origin.x = 10.0f;
            usernameFrame.origin.x = 10.0f;
            //byFrame.origin.y = 86.0f;
            usernameFrame.origin.y = 86.0f;
            usernameFrame.size.width = 108.0f;
        }
        
        // Update label positions
        //self.byLabel.frame = byFrame;
        self.usernameLabel.frame = usernameFrame;
        
        self.usernameLabel.text = [NSString stringWithFormat: @"%@\n\n", text]; 
    }
    else
    {
        self.usernameLabel.text = text;
    }
}


- (void) setChannelNameText:(NSString *)channelNameText
{
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        CGRect currentFrame = self.channelName.frame;
        CGFloat defaultWidth = currentFrame.size.width;
        UIView *referenceView = self.channelImageView.hidden ? self.usernameLabel : self.channelImageView;
        CGFloat maxHeight = referenceView.frame.origin.y - self.channelName.frame.origin.y;
        self.channelName.text = channelNameText;
        [self.channelName sizeToFit];
        currentFrame = self.channelName.frame;
        currentFrame.size.width = defaultWidth;
        currentFrame.size.height = MIN(currentFrame.size.height, maxHeight);
        self.channelName.frame = currentFrame;
    }
    else
    {
        self.channelName.text = channelNameText;
    }
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.videoImageView.image = nil;
    self.channelImageView.image = nil;
}

@end
