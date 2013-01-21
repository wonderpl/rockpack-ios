//
//  SYNFriendThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 21/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "MKNetworkKit.h"
#import "SYNAppDelegate.h"
#import "SYNFriendThumbnailCell.h"
#import "SYNNetworkEngine.h"
#import "UICollectionViewCell+AsyncImage.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNFriendThumbnailCell ()

@property (nonatomic, strong) MKNetworkOperation* friendImageLoadingOperation;
@property (nonatomic, strong) NSString* loadingFriendImageViewURLString;

@end

@implementation SYNFriendThumbnailCell

@synthesize viewControllerDelegate = _viewControllerDelegate;

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNFriendThumbnailWideCell"
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
    
    self.forename.font = [UIFont boldRockpackFontOfSize: 13.0f];
    self.surname.font = [UIFont boldRockpackFontOfSize: 13.0f];
}


#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    self.loadingFriendImageViewURLString = imageURLString;
    
    [self loadAndCacheImageInView: self.friendImageView
                    withURLString: self.loadingFriendImageViewURLString
         andImageLoadingOperation: self.friendImageLoadingOperation];
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
    [self.friendImageLoadingOperation cancel];
}


@end
