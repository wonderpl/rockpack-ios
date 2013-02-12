//
//  SYNChannelSelectorCell.m
//  rockpack
//
//  Created by Nick Banks on 28/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelSelectorCell.h"
#import "UIImageView+MKNetworkKitAdditions.h"

@interface SYNChannelSelectorCell ()

@end


@implementation SYNChannelSelectorCell




- (void) setChannelImageViewImage: (NSString*) imageURLString
{
    [self.imageView setImageFromURL: [NSURL URLWithString: imageURLString]
                   placeHolderImage: nil];
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    
    self.imageView.image = nil;
}

@end
