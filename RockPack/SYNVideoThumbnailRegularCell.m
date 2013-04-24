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

@end


@implementation SYNVideoThumbnailRegularCell

@synthesize viewControllerDelegate = _viewControllerDelegate;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
}

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                               placeHolderImage: nil];
}


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
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.imageView.image = nil;
}

@end
