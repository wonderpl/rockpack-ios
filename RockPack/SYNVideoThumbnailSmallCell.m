//
//  SYNVideoThumbnailSmallCell.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailSmallCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"


@interface SYNVideoThumbnailSmallCell ()

@property (nonatomic, strong) IBOutlet UIView *mainView;

@end


@implementation SYNVideoThumbnailSmallCell

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 10.0f];
}

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    if (self.isColour == TRUE)
    {
        self.mainView.alpha = 1.0f;
        [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                       placeHolderImage: nil
                            usingEngine: nil
                              animation: YES
                             monochrome: FALSE];
    }
    else
    {
        self.mainView.alpha = 0.5f;
        [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                       placeHolderImage: nil
                            usingEngine: nil
                              animation: YES
                             monochrome: TRUE];
    }
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.imageView.image = nil;
    self.isColour = FALSE;
}

@end
