//
//  SYNVideoThumbnailRegularCell.m
//  rockpack
//
//  Created by Nick Banks on 03/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface SYNVideoThumbnailRegularCell ()

@property (nonatomic, strong) IBOutlet UIButton *videoButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

@end


@implementation SYNVideoThumbnailRegularCell

@synthesize viewControllerDelegate = _viewControllerDelegate;
@synthesize displayMode = _displayMode;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
}


#pragma mark - Switch between display and edit modes

- (void) setDisplayMode: (kChannelThumbnailDisplayMode) displayMode
{
    _displayMode = displayMode;
    
    if (displayMode == kChannelThumbnailDisplayModeDisplay)
    {
        self.addItButton.hidden = NO;
        self.deleteButton.hidden = YES;
    }
    else if (displayMode == kChannelThumbnailDisplayModeEdit)
    {
        self.addItButton.hidden = YES;
        self.deleteButton.hidden = NO;
    }
    else if(displayMode == kChannelThumbnailDisplayModeDisplayFavourite)
    {
        self.addItButton.hidden = NO;
        self.deleteButton.hidden = YES;
    }
    else
    {
        AssertOrLog(@"Unexpected option");
    }
}


- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    // Add button targets
    
    [self.videoButton addTarget: self.viewControllerDelegate
                         action: @selector(videoButtonPressed:)
               forControlEvents: UIControlEventTouchUpInside];
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(videoAddButtonTapped:)
               forControlEvents: UIControlEventTouchUpInside];
    
    [self.deleteButton addTarget: self.viewControllerDelegate
                          action: @selector(videoDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    [self.imageView.layer removeAllAnimations];
    [self.imageView setImageWithURL:nil];
}

@end
