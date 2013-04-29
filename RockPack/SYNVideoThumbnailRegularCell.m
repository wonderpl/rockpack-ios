//
//  SYNVideoThumbnailRegularCell.m
//  rockpack
//
//  Created by Nick Banks on 03/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "UIImageView+MKNetworkKitAdditions.h"

@interface SYNVideoThumbnailRegularCell ()

@property (nonatomic, strong) IBOutlet UIButton *videoButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
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
    
    if (displayMode == kChannelThumbnailDisplayModeStandard)
    {
        self.addButton.hidden = NO;
        self.deleteButton.hidden = YES;
    }
    else if (displayMode == kChannelThumbnailDisplayModeEdit)
    {
        self.addButton.hidden = YES;
        self.deleteButton.hidden = NO;
    }
    else
    {
        AssertOrLog(@"Unexpected option");
    }
}

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                               placeHolderImage: nil];
//    
//    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: @"http://i.ytimg.com/vi/1qNQHv6jdyY/mqdefault.jpg"]
//                               placeHolderImage: nil];
}


- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    // Add button targets
    
    [self.videoButton addTarget: self.viewControllerDelegate
                         action: @selector(displayVideoViewerFromView:)
               forControlEvents: UIControlEventTouchUpInside];
    
    [self.addButton addTarget: self.viewControllerDelegate
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
    self.imageView.image = nil;
}

@end
