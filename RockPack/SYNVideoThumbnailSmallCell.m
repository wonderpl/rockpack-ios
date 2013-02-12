//
//  SYNVideoThumbnailSmallCell.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailSmallCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNVideoThumbnailSmallCell



- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
}

#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    [self.imageView setImageFromURL: [NSURL URLWithString: imageURLString]
                   placeHolderImage: nil];
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    self.imageView.image = nil;
}

@end
