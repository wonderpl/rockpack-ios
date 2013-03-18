//
//  SYNChannelThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"

@interface SYNChannelThumbnailCell ()

@end

@implementation SYNChannelThumbnailCell



- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.displayNameLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.rockItNumberLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
}


- (void) setChannelImageViewImage: (NSString*) imageURLString
{
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                               placeHolderImage: nil];
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{

    self.imageView.image = nil;
}

@end
