//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNVideoThumbnailWideCell ()

@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *highlightedBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *longPressView;
@property (nonatomic, strong) IBOutlet UIButton *channelButton;
@property (nonatomic, strong) IBOutlet UIButton *profileButton;

@end

@implementation SYNVideoThumbnailWideCell

@synthesize viewControllerDelegate = _viewControllerDelegate;
@synthesize displayMode = _displayMode;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.videoTitle.font = [UIFont boldRockpackFontOfSize: 14.0f];
    self.channelName.font = [UIFont rockpackFontOfSize: 15.0f];
    self.displayName.font = [UIFont rockpackFontOfSize: 12.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.numberOfViewLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.dateAddedLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.durationLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.highlightedBackgroundView.hidden = TRUE;
    
    self.displayMode = kDisplayModeChannel; // default is channel
}


#pragma mark - Switch Between Modes

-(void)setDisplayMode:(kDisplayMode)displayMode
{
    if (displayMode == kDisplayModeChannel) {
        self.videoInfoView.hidden = YES;
        self.channelInfoView.hidden = NO;
    } else if (displayMode == kDisplayModeYoutube) {
        self.channelInfoView.hidden = YES;
        self.videoInfoView.hidden = NO;
    }
}

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    [self.videoImageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                                    placeHolderImage: nil];
}

- (void) setChannelImageViewImage: (NSString*) imageURLString
{    
    [self.channelImageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                                      placeHolderImage: nil];
}


#pragma mark - Cell focus 

- (void) setFocus: (BOOL) focus
{
    if (focus)
    {
        self.highlightedBackgroundView.hidden = FALSE;
    }
    else
    {
        self.highlightedBackgroundView.hidden = TRUE;
    }
}


// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    // Add dragging to video thumbnail view
    UILongPressGestureRecognizer *longPressOnThumbnailGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self.viewControllerDelegate
                                                                                                                        action: @selector(longPressThumbnail:)];
    
    [self.longPressView addGestureRecognizer: longPressOnThumbnailGestureRecognizer];
    
    // Allow tapping to show video player
    UITapGestureRecognizer *tapOnThumbnailGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self.viewControllerDelegate
                                                                                                      action: @selector(displayVideoViewerFromView:)];
    [self.longPressView addGestureRecognizer: longPressOnThumbnailGestureRecognizer];
    
    [self.longPressView addGestureRecognizer: tapOnThumbnailGestureRecognizer];

    // Add button targets
    [self.rockItButton addTarget: self.viewControllerDelegate
                          action: @selector(userTouchedVideoStarItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [self.shareItButton addTarget: self.viewControllerDelegate
                         action: @selector(userTouchedVideoShareItButton:)
               forControlEvents: UIControlEventTouchUpInside];
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(userTouchedVideoAddItButton:)
               forControlEvents: UIControlEventTouchUpInside];
    
    // User touches channel thumbnail
    [self.channelButton addTarget: self.viewControllerDelegate
                           action: @selector(userTouchedChannelButton:)
                 forControlEvents: UIControlEventTouchUpInside];
    
    // User touches user details
    [self.profileButton addTarget: self.viewControllerDelegate
                           action: @selector(userTouchedProfileButton:)
                 forControlEvents: UIControlEventTouchUpInside];
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.videoImageView.image = nil;
    self.channelImageView.image = nil;
}


@end
