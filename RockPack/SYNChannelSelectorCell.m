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

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNChannelSelectorCell"
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
