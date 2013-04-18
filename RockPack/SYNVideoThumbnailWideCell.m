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

@property (nonatomic, strong) IBOutlet UIImageView *highlightedBackgroundView;
@property (nonatomic, strong) IBOutlet UIButton *channelButton;
@property (nonatomic, strong) IBOutlet UIButton *profileButton;
@property (nonatomic, strong) IBOutlet UIButton *videoButton;
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
    
    self.videoTitle.font = [UIFont boldRockpackFontOfSize: 15.0f];
    
    self.fromLabel.font = [UIFont rockpackFontOfSize: 13.0f];
    self.channelName.font = [UIFont rockpackFontOfSize: 13.0f];
    
    self.usernameLabel.font = [UIFont rockpackFontOfSize: 13.0f];
    self.byLabel.font = [UIFont rockpackFontOfSize: 13.0f];
    
    self.numberOfViewLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.dateAddedLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.durationLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.highlightedBackgroundView.hidden = TRUE;
    
    self.displayMode = kDisplayModeChannel; // default is channel
    
//    UIColor *shadowColor = [UIColor colorWithWhite: 232.0f/ 255.0f
//                                       alpha: 1.0f];
//    
//    self.channelImageView.layer.shadowColor = [shadowColor CGColor];
//    self.channelImageView.layer.shadowRadius = 1.0f;
//    self.channelImageView.layer.shadowOpacity = 1.0f;
//    self.channelImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
//    self.channelImageView.layer.masksToBounds = NO;
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

    // Add button targets
    
    [self.videoButton addTarget: self.viewControllerDelegate
                         action: @selector(displayVideoViewerFromView:)
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


- (void) setUsernameText: (NSString *) text
{
    CGSize bySize = [self.byLabel.text sizeWithFont:self.byLabel.font];
    CGFloat maxWidth = self.channelInfoView.frame.size.width - 19.0f - bySize.width;
    CGSize stringSize = [text sizeWithFont:self.usernameLabel.font];
    CGRect currentFrame = self.usernameLabel.frame;
    currentFrame.size = stringSize;
    currentFrame.size.width = MIN(currentFrame.size.width,maxWidth);
    currentFrame.origin.x = self.channelInfoView.frame.size.width - 15.0 - currentFrame.size.width;
    self.usernameLabel.frame = currentFrame;
    self.usernameLabel.text = text;
    
    CGRect byFrame = self.byLabel.frame;
    byFrame.size = bySize;
    byFrame.origin.x = currentFrame.origin.x - byFrame.size.width - 4.0;
    self.byLabel.frame = byFrame;
}

- (void) setChannelNameText:(NSString *)channelNameText
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

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.videoImageView.image = nil;
    self.channelImageView.image = nil;
}


@end
