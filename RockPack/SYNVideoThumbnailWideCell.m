//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "MKNetworkKit.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNVideoThumbnailWideCell ()

@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *highlightedBackgroundView;
@property (nonatomic, strong) IBOutlet UIButton *showVideoButton;

@end

@implementation SYNVideoThumbnailWideCell

@synthesize viewControllerDelegate = _viewControllerDelegate;

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNVideoThumbnailWideCell"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![arrayOfViews[0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = arrayOfViews[0];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.videoTitle.font = [UIFont boldRockpackFontOfSize: 14.0f];
    self.channelName.font = [UIFont rockpackFontOfSize: 15.0f];
    self.userName.font = [UIFont rockpackFontOfSize: 12.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.highlightedBackgroundView.hidden = TRUE;
}


#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    [self.videoImageView setImageFromURL: [NSURL URLWithString: imageURLString]
                        placeHolderImage: nil];
}

- (void) setChannelImageViewImage: (NSString*) imageURLString
{    
    [self.channelImageView setImageFromURL: [NSURL URLWithString: imageURLString]
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
    
    [self.videoImageView addGestureRecognizer: longPressOnThumbnailGestureRecognizer];
    
    // Add button targets
    [self.rockItButton addTarget: self.viewControllerDelegate
                          action: @selector(userTouchedVideoRockItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [self.shareItButton addTarget: self.viewControllerDelegate
                         action: @selector(userTouchedVideoShareItButton:)
               forControlEvents: UIControlEventTouchUpInside];
    
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(userTouchedVideoAddItButton:)
               forControlEvents: UIControlEventTouchUpInside];
    
    [self.showVideoButton addTarget: self.viewControllerDelegate
                             action: @selector(displayVideoViewerFromButton:)
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
