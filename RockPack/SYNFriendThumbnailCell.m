//
//  SYNFriendThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 21/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "SYNAppDelegate.h"
#import "SYNFriendThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNFriendThumbnailCell

@synthesize viewControllerDelegate = _viewControllerDelegate;


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.forename.font = [UIFont boldRockpackFontOfSize: 13.0f];
    self.forename.shadowColor = [UIColor blackColor];
    self.forename.shadowOffset = CGSizeMake (1,1);
    self.surname.font = [UIFont boldRockpackFontOfSize: 13.0f];
    self.surname.shadowColor = [UIColor blackColor];
    self.surname.shadowOffset = CGSizeMake (1,1);
    
}


#pragma mark - Asynchronous image loading support

- (void) setFriendImageViewImage: (NSString*) imageURLString
{
    [self.friendImageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                                     placeHolderImage: nil];
}


// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    // Add dragging to video thumbnail view
    UILongPressGestureRecognizer *longPressOnThumbnailGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self.viewControllerDelegate
                                                                                                                        action: @selector(longPressThumbnail:)];
    
    [self.friendImageView addGestureRecognizer: longPressOnThumbnailGestureRecognizer];
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.friendImageView.image = nil;
    self.favouriteButton.selected = FALSE;
    self.favouriteButton.hidden = FALSE;
}


@end
